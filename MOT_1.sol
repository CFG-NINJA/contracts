// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {OAppSender, MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import {OAppReceiver, Origin} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppReceiver.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {OAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";

contract Xmore is ERC20, Ownable, OAppSender, OAppReceiver {
    using OptionsBuilder for bytes;

    enum ActionType {
        MintTokensForBurn,
        BurnTokensForMint
    }

    struct ActionData {
        ActionType actionType;
        address account;
        uint256 amount;
    }

    struct PoolInfo {
        uint256 maxSupply;
        uint256 mintPrice;
        uint256 totalMinted;
    }

    // Custom Events

    event MessageSent(string message, uint32 dstEid);
    event MessageReceived(
        string message,
        uint32 senderEid,
        bytes32 sender,
        uint64 nonce
    );

    event SwappedEtherForTokens(
        address indexed account,
        uint256 indexed amount,
        uint8 indexed poolNumber,
        uint256 timestamp
    );

    event UnsoldTokensRefunded(address indexed account, uint256 indexed amount);

    event UnifiedTotalMintedUpdated(uint256 amount, uint256 timestamp);

    // Custom Errors
    error UnifiedMaxSupplyReached();
    error MintPriceNotMet();
    error MintAmountExceedsRemainingSupply();
    error LocalTransferNotAllowed();
    error MintingDisabled();
    error InsufficientBalance();
    error UnauthorizedParty();
    error InvalidAmount();
    error InvalidAddress();
    error RefundTransferFailed();
    error WithdrawalTransferFailed();
    error InvalidActionType();
    error InvalidExecutorGas();
    error OracleFeeNotMet();
    error OracleFundingFailed();
    error InvalidPoolNumber();
    error PoolIsFull();
    error OnlyOneMintPerPool();
    error PoolsTotalSupplyMustMatchUnifiedSupply();

    // State Variables

    uint256 public unifiedMaxSupply;
    uint256 public lastOracleUpdate;
    uint256 public updateThreshold;
    uint256 public oracleFee;

    bool public mintingEnabled = true;
    bool public allowLocalTransfer = false;
    bool public refundEnabled = false;
    bool public checkAuthorizedParty = false;

    address public oracle;

    address[] minters;

    mapping(address => uint256) mintersIndex;
    mapping(address => bool) public authorizedParties;
    mapping(address => uint256)[4] public pools;
    mapping(address => bool)[5] public unifiedMintersPerPool;

    uint256[4] public mintQuantityPerPool;

    uint256[5] public unifiedPoolsTotalMinted;

    PoolInfo[5] public poolsInfo;

    constructor(
        address _initialOwner,
        uint256 _unifiedMaxSupply,
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        uint256[4] memory _mintPrices,
        uint256[4] memory _maxSupplies,
        uint256[4] memory _mintQuantityPerPool
    )
        ERC20(_name, _symbol)
        Ownable(_initialOwner)
        OAppCore(_lzEndpoint, _initialOwner)
    {
        unifiedMaxSupply = _unifiedMaxSupply * (10 ** decimals());

        oracleFee = 20000000000;

        oracle = _initialOwner;

        uint256 totalMaxSupply = 0;

        for (uint8 i = 1; i <= 4; i++) {
            mintQuantityPerPool[i - 1] = _mintQuantityPerPool[i - 1];
            poolsInfo[i].mintPrice = _mintPrices[i - 1];
            poolsInfo[i].maxSupply = _maxSupplies[i - 1] * (10 ** decimals());

            totalMaxSupply += _maxSupplies[i - 1];
        }

        if (totalMaxSupply != _unifiedMaxSupply) {
            revert PoolsTotalSupplyMustMatchUnifiedSupply();
        }
    }

    // override for lz version
    function oAppVersion()
        public
        view
        override(OAppSender, OAppReceiver)
        returns (uint64 senderVersion, uint64 receiverVersion)
    {
        (senderVersion, ) = OAppSender.oAppVersion();

        (, receiverVersion) = OAppReceiver.oAppVersion();
    }

    // override for totalSupply
    function totalSupply() public view override returns (uint256) {
        return _getUnifiedTotalMinted();
    }

    // override for transfer
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        if (allowLocalTransfer) {
            return super.transfer(to, value);
        } else {
            revert LocalTransferNotAllowed();
        }
    }

    // override for transferFrom
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (allowLocalTransfer) {
            return super.transferFrom(from, to, value);
        } else {
            revert LocalTransferNotAllowed();
        }
    }

    // transfer to another chain
    function transferToChain(
        uint32 _dstEid,
        address _to,
        uint256 _amount,
        uint128 _executorGas
    ) external payable {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        if (_executorGas == 0) {
            revert InvalidExecutorGas();
        }

        ActionData memory actionData = ActionData({
            actionType: ActionType.MintTokensForBurn,
            account: _to,
            amount: _amount
        });

        bytes memory _encodedMessage = abi.encode(actionData);

        _localBurn(msg.sender, _amount);

        bytes memory _options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(_executorGas, 0);

        _lzSend(
            _dstEid,
            _encodedMessage,
            _options,
            // Fee in native gas and ZRO token.
            MessagingFee(msg.value, 0),
            // Refund address in case of failed source message.
            payable(msg.sender)
        );

        emit MessageSent(string(_encodedMessage), _dstEid);
    }

    function getCurrentPool() external view returns (uint8) {
        uint8 _poolNumber = 0;

        // change to next pool if current pool is full

        for (uint8 i = 1; i <= 4; i++) {
            if (unifiedPoolsTotalMinted[i] < poolsInfo[i].maxSupply) {
                _poolNumber = i;
                break;
            }
        }

        return _poolNumber;
    }

    // Minting Function

    function swapEtherForTokens() public payable {
        uint8 _poolNumber = 0;

        // change to next pool if current pool is full

        for (uint8 i = 1; i <= 4; i++) {
            if (unifiedPoolsTotalMinted[i] < poolsInfo[i].maxSupply) {
                _poolNumber = i;
                break;
            }
        }

        if (_poolNumber == 0) {
            revert UnifiedMaxSupplyReached();
        }

        if (msg.sender == address(0)) {
            revert InvalidAddress();
        }

        if (_getPoolBalance(_poolNumber, msg.sender) > 0) {
            revert OnlyOneMintPerPool();
        }

        if (unifiedMintersPerPool[_poolNumber][msg.sender]) {
            revert OnlyOneMintPerPool();
        }

        if (
            poolsInfo[_poolNumber].totalMinted >=
            poolsInfo[_poolNumber].maxSupply
        ) {
            revert PoolIsFull();
        }

        if (
            unifiedPoolsTotalMinted[_poolNumber] >=
            poolsInfo[_poolNumber].maxSupply
        ) {
            revert PoolIsFull();
        }

        if (msg.value == 0) {
            revert InvalidAmount();
        }

        uint256 totalMinted = _getUnifiedTotalMinted();

        if (totalMinted == unifiedMaxSupply) {
            revert UnifiedMaxSupplyReached();
        }

        if (!mintingEnabled) {
            revert MintingDisabled();
        }

        uint256 mintPrice = poolsInfo[_poolNumber].mintPrice;

        if (msg.value < (mintPrice + oracleFee)) {
            revert MintPriceNotMet();
        }

        uint256 value = msg.value - oracleFee;

        uint256 mintAmount = _getMintAmount(value, mintPrice);

        uint256 thresholdAmount = mintQuantityPerPool[_poolNumber - 1] *
            (10 ** decimals());

        if (mintAmount != thresholdAmount) {
            revert InvalidAmount();
        }

        if (
            (poolsInfo[_poolNumber].totalMinted + mintAmount) >
            poolsInfo[_poolNumber].maxSupply
        ) {
            revert MintAmountExceedsRemainingSupply();
        }

        if (
            unifiedPoolsTotalMinted[_poolNumber] + mintAmount >
            poolsInfo[_poolNumber].maxSupply
        ) {
            revert MintAmountExceedsRemainingSupply();
        }

        if (totalMinted + mintAmount > unifiedMaxSupply) {
            revert MintAmountExceedsRemainingSupply();
        }

        uint256 mintValue = (mintAmount / (10 ** decimals())) * mintPrice;

        uint256 oracleFund = msg.value - value;

        if (
            oracle != address(0) &&
            oracleFund > 0 &&
            oracleFund <= address(this).balance
        ) {
            (bool success, ) = oracle.call{value: oracleFund}("");

            if (!success) {
                revert OracleFundingFailed();
            }
        }

        if (refundEnabled) {
            uint256 refund = value - mintValue;

            if (refund > 0 && refund <= address(this).balance) {
                (bool success, ) = msg.sender.call{value: refund}("");

                if (!success) {
                    revert RefundTransferFailed();
                }
            }
        }

        poolsInfo[_poolNumber].totalMinted += mintAmount;

        _setPoolBalance(_poolNumber, msg.sender, mintAmount);

        _mint(msg.sender, mintAmount);

        uint minterIndex = mintersIndex[msg.sender];

        if (minterIndex == 0) {
            minters.push(msg.sender);
            mintersIndex[msg.sender] = minters.length;
        }

        if (!unifiedMintersPerPool[_poolNumber][msg.sender]) {
            unifiedMintersPerPool[_poolNumber][msg.sender] = true;
        }

        emit SwappedEtherForTokens(
            msg.sender,
            mintAmount,
            _poolNumber,
            block.timestamp
        );
    }

    function getLocalTotalSwapped() public view returns (uint256) {
        return
            poolsInfo[1].totalMinted +
            poolsInfo[2].totalMinted +
            poolsInfo[3].totalMinted +
            poolsInfo[4].totalMinted;
    }

    // utilities functions

    function _getPoolBalance(
        uint8 _poolNumber,
        address _account
    ) internal view returns (uint256) {
        if (_poolNumber < 1 || _poolNumber > 4) {
            revert InvalidPoolNumber();
        }

        if (_account == address(0)) {
            revert InvalidAddress();
        }

        return pools[_poolNumber - 1][_account];
    }

    function _setPoolBalance(
        uint8 _poolNumber,
        address _account,
        uint256 _amount
    ) internal {
        if (_poolNumber < 1 || _poolNumber > 4) {
            revert InvalidPoolNumber();
        }

        if (_account == address(0)) {
            revert InvalidAddress();
        }

        pools[_poolNumber - 1][_account] = _amount;
    }

    function getUnifiedPoolsTotalMinted() public view returns (uint256) {
        return
            unifiedPoolsTotalMinted[1] +
            unifiedPoolsTotalMinted[2] +
            unifiedPoolsTotalMinted[3] +
            unifiedPoolsTotalMinted[4];
    }

    function _getUnifiedTotalMinted() internal view returns (uint256) {
        uint256 localTotalSwapped = getLocalTotalSwapped();

        uint256 unifiedTotalMinted = getUnifiedPoolsTotalMinted();

        if (localTotalSwapped > unifiedTotalMinted) {
            return localTotalSwapped;
        }

        return unifiedTotalMinted;
    }

    function _getMintAmount(
        uint256 _value,
        uint256 _mintPrice
    ) internal view returns (uint256) {
        return (_value / _mintPrice) * (10 ** decimals());
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function bytes32ToAddress(bytes32 _b) internal pure returns (address) {
        return address(uint160(uint256(_b)));
    }

    // invalidate a minter's mint for a particular pool

    function _invalidateMint(uint8 _poolNumber, address _minter) internal {
        uint256 balance = _getPoolBalance(_poolNumber, _minter);

        if (balance > 0) {
            _burn(_minter, balance);

            _setPoolBalance(_poolNumber, _minter, 0);

            if (poolsInfo[_poolNumber].totalMinted >= balance) {
                poolsInfo[_poolNumber].totalMinted -= balance;
            }

            uint256 refundAmount = (balance / (10 ** decimals())) *
                poolsInfo[_poolNumber].mintPrice;

            if (refundAmount > 0 && refundAmount <= address(this).balance) {
                (bool success, ) = _minter.call{value: refundAmount}("");

                if (!success) {
                    revert RefundTransferFailed();
                }

                emit UnsoldTokensRefunded(_minter, refundAmount);
            }

            // if  minter has no balance in any pool, remove from minters array

            if (
                _getPoolBalance(1, _minter) == 0 &&
                _getPoolBalance(2, _minter) == 0 &&
                _getPoolBalance(3, _minter) == 0 &&
                _getPoolBalance(4, _minter) == 0 &&
                minters.length > 0
            ) {
                uint256 index = mintersIndex[_minter];

                if (index != 0 && index < minters.length) {
                    minters[index] = minters[minters.length - 1];
                    mintersIndex[minters[minters.length - 1]] = index;

                    minters.pop();
                    delete mintersIndex[_minter];
                }
            }
        }
    }

    // function to unsell tokens and refund ether in case the unifiedMaxSupply is exceeded before oracle updates callback functions to update unifiedTotalMinted
    // keeps unselling until localTotalSwapped is equal to unifiedTotalMinted

    function _correctTokenOverSupply(bool[4] memory _poolsToCorrect) internal {
        // check through each pool needing correction and refund the surplus tokens to the minter

        for (uint8 i = 1; i <= 4; i++) {
            if (
                _poolsToCorrect[i - 1] &&
                unifiedPoolsTotalMinted[i] > poolsInfo[i].maxSupply
            ) {
                uint256 surplus = unifiedPoolsTotalMinted[i] -
                    poolsInfo[i].maxSupply;

                // start from the last minter to refund the surplus tokens

                for (uint256 j = minters.length - 1; j >= 0; j--) {
                    address minter = minters[j];

                    uint256 refundAmount = 0;

                    uint256 balance = _getPoolBalance(i, minter);

                    if (balance > 0) {
                        uint256 amount = balance;

                        if (balance > surplus) {
                            amount = surplus;
                        }

                        _burn(minter, amount);

                        _setPoolBalance(i, minter, balance - amount);

                        surplus -= amount;

                        poolsInfo[i].totalMinted -= amount;

                        if (
                            _getPoolBalance(1, minter) == 0 &&
                            _getPoolBalance(2, minter) == 0 &&
                            _getPoolBalance(3, minter) == 0 &&
                            _getPoolBalance(4, minter) == 0 &&
                            minters.length > 0
                        ) {
                            uint256 index = mintersIndex[minter];
                            if (index != 0 && index < minters.length) {
                                minters[index] = minters[minters.length - 1];
                                mintersIndex[
                                    minters[minters.length - 1]
                                ] = index;

                                minters.pop();
                                delete mintersIndex[minter];
                            }
                        }

                        refundAmount =
                            (amount / (10 ** decimals())) *
                            poolsInfo[i].mintPrice;
                    }

                    if (
                        refundAmount > 0 &&
                        refundAmount <= address(this).balance
                    ) {
                        (bool success, ) = minter.call{value: refundAmount}("");

                        if (!success) {
                            revert RefundTransferFailed();
                        }

                        emit UnsoldTokensRefunded(minter, refundAmount);
                    }

                    if (surplus == 0) {
                        break;
                    }
                }
            }
        }
    }

    function _registerUnifiedMinter(
        uint8 _poolNumber,
        address _minter
    ) internal {
        if (!unifiedMintersPerPool[_poolNumber][_minter]) {
            unifiedMintersPerPool[_poolNumber][_minter] = true;
        }
    }

    // Oracle updates callback functions

    function enforceMinterRules(
        address[][4] memory _invalidMinters,
        address[][4] memory _newMinters
    ) external {
        if (oracle != address(0) && msg.sender != oracle) {
            revert UnauthorizedParty();
        }

        // invalidate minters in each pool if its not empty

        for (uint8 i = 1; i <= 4; i++) {
            for (uint256 j = 0; j < _invalidMinters[i - 1].length; j++) {
                _invalidateMint(i, _invalidMinters[i - 1][j]);
            }
        }

        // register new minters in each pool

        for (uint8 i = 1; i <= 4; i++) {
            for (uint256 j = 0; j < _newMinters[i - 1].length; j++) {
                _registerUnifiedMinter(i, _newMinters[i - 1][j]);
            }
        }
    }

    function enforceSupplyRules(
        uint256[4] memory _amounts,
        bool[4] memory _poolsToCorrect
    ) external {
        // Only update if the amount is different

        uint256 _amount = _amounts[0] + _amounts[1] + _amounts[2] + _amounts[3];

        bool isEqual = (_amounts[0] == unifiedPoolsTotalMinted[1] &&
            _amounts[1] == unifiedPoolsTotalMinted[2] &&
            _amounts[2] == unifiedPoolsTotalMinted[3] &&
            _amounts[3] == unifiedPoolsTotalMinted[4]);

        if (isEqual) {
            revert InvalidAmount();
        }

        // if (_amount > unifiedMaxSupply) {
        //     revert UnifiedMaxSupplyReached();
        // }

        if (oracle != address(0) && msg.sender != oracle) {
            revert UnauthorizedParty();
        }

        // update each pool if the amount is different

        for (uint8 i = 1; i <= 4; i++) {
            if (_amounts[i - 1] != unifiedPoolsTotalMinted[i]) {
                unifiedPoolsTotalMinted[i] = _amounts[i - 1];
            }
        }

        _correctTokenOverSupply(_poolsToCorrect);

        emit UnifiedTotalMintedUpdated(_amount, block.timestamp);
    }

    // LayerZero Functions

    function quote(
        uint32 _dstEid,
        string memory _message,
        bool _payInLzToken,
        uint128 _executorGas
    ) public view returns (MessagingFee memory fee) {
        bytes memory _options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(_executorGas, 0);

        bytes memory payload = abi.encode(_message);
        fee = _quote(_dstEid, payload, _options, _payInLzToken);
    }

    function send(
        uint32 _dstEid,
        bytes memory _encodedMessage,
        uint128 _executorGas
    ) external payable {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        if (_executorGas == 0) {
            revert InvalidAmount();
        }

        bytes memory _options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(_executorGas, 0);

        _lzSend(
            _dstEid,
            _encodedMessage,
            _options,
            // Fee in native gas and ZRO token.
            MessagingFee(msg.value, 0),
            // Refund address in case of failed source message.
            payable(msg.sender)
        );

        emit MessageSent(string(_encodedMessage), _dstEid);
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 /*_guid*/,
        bytes calldata message,
        address /*executor*/, // Executor address as specified by the OApp.
        bytes calldata /*_extraData*/ // Any extra data or options to trigger on receipt.
    ) internal override {
        // check if authorized party is enabled and if the sender is authorized

        // address _sender = bytes32ToAddress(_origin.sender);

        if (checkAuthorizedParty && !authorizedParties[msg.sender]) {
            revert UnauthorizedParty();
        }

        _handleOnMessageReceive(message);

        // Emit the event with the decoded message and sender's EID
        emit MessageReceived(
            string(message),
            _origin.srcEid,
            _origin.sender,
            _origin.nonce
        );
    }

    function _handleOnMessageReceive(bytes memory _encodedMessage) internal {
        ActionData memory actionData = abi.decode(
            _encodedMessage,
            (ActionData)
        );

        if (actionData.actionType == ActionType.BurnTokensForMint) {
            _localBurn(actionData.account, actionData.amount);
        } else if (actionData.actionType == ActionType.MintTokensForBurn) {
            _localMint(actionData.account, actionData.amount);
        } else {
            revert InvalidActionType();
        }
    }

    // Admin Functions

    function refundMinter(
        uint8 _poolNumber,
        address _minter
    ) external onlyOwner {
        _invalidateMint(_poolNumber, _minter);
    }

    function refundAmountToMinter(
        uint8 _poolNumber,
        address _minter,
        uint256 _amount
    ) external onlyOwner {
        uint256 balance = _getPoolBalance(_poolNumber, _minter);

        if (_amount == 0 || _amount > balance) {
            revert InvalidAmount();
        }

        _burn(_minter, _amount);

        _setPoolBalance(_poolNumber, _minter, balance - _amount);

        if (poolsInfo[_poolNumber].totalMinted >= _amount) {
            poolsInfo[_poolNumber].totalMinted -= _amount;
        }

        uint256 refundAmount = (_amount / (10 ** decimals())) *
            poolsInfo[_poolNumber].mintPrice;

        if (refundAmount > 0 && refundAmount <= address(this).balance) {
            (bool success, ) = _minter.call{value: refundAmount}("");

            if (!success) {
                revert RefundTransferFailed();
            }

            emit UnsoldTokensRefunded(_minter, refundAmount);
        }

        if (
            _getPoolBalance(1, _minter) == 0 &&
            _getPoolBalance(2, _minter) == 0 &&
            _getPoolBalance(3, _minter) == 0 &&
            _getPoolBalance(4, _minter) == 0 &&
            minters.length > 0
        ) {
            uint256 index = mintersIndex[_minter];

            if (index != 0 && index < minters.length) {
                minters[index] = minters[minters.length - 1];
                mintersIndex[minters[minters.length - 1]] = index;

                minters.pop();
                delete mintersIndex[_minter];
            }
        }
    }

    function setMintQuantityPerPool(
        uint256[4] memory _quantities
    ) external onlyOwner {
        for (uint8 i = 0; i < 4; i++) {
            mintQuantityPerPool[i] = _quantities[i];
        }
    }

    function setOracle(address _oracle, uint256 _oracleFee) public onlyOwner {
        if (_oracle == address(0)) {
            revert InvalidAddress();
        }

        if (_oracleFee == 0) {
            revert InvalidAmount();
        }

        oracle = _oracle;
        oracleFee = _oracleFee;
    }

    function setPoolInfo(
        uint8 _poolNumber,
        uint256 _mintPrice,
        uint256 _maxSupply
    ) public onlyOwner {
        if (_poolNumber < 1 || _poolNumber > 4) {
            revert InvalidPoolNumber();
        }

        if (_mintPrice == 0) {
            revert InvalidAmount();
        }

        poolsInfo[_poolNumber].mintPrice = _mintPrice;
        poolsInfo[_poolNumber].maxSupply = _maxSupply * (10 ** decimals());
    }

    function setMintingEnabled(bool _mintingEnabled) public onlyOwner {
        mintingEnabled = _mintingEnabled;
    }

    function setAllowLocalTransfer(bool _allowLocalTransfer) public onlyOwner {
        allowLocalTransfer = _allowLocalTransfer;
    }

    function setRefundEnabled(bool _refundEnabled) public onlyOwner {
        refundEnabled = _refundEnabled;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");

        if (!success) {
            revert WithdrawalTransferFailed();
        }
    }

    function withdrawTo(address _to, uint256 _amount) public onlyOwner {
        if (_to == address(0)) {
            revert InvalidAddress();
        }

        if (_amount == 0 || _amount > address(this).balance) {
            revert InsufficientBalance();
        }

        (bool success, ) = _to.call{value: _amount}("");

        if (!success) {
            revert WithdrawalTransferFailed();
        }
    }

    function setCheckAuthorizedParty(
        bool _checkAuthorizedParty
    ) public onlyOwner {
        checkAuthorizedParty = _checkAuthorizedParty;
    }

    function addAuthorizedParty(address _party) public onlyOwner {
        authorizedParties[_party] = true;
    }

    function removeAuthorizedParty(address _party) public onlyOwner {
        authorizedParties[_party] = false;
    }

    // mint and burn function that can be called by authorized parties (LZ Executors) to facilitate interchain transfers

    function _localMint(address _to, uint256 _amount) internal {
        if (_amount == 0) {
            revert InvalidAmount();
        }

        if (_to == address(0)) {
            revert InvalidAddress();
        }

        _mint(_to, _amount);
    }

    function _localBurn(address _from, uint256 _amount) internal {
        if (_amount == 0) {
            revert InvalidAmount();
        }

        // check if _from has enough balance

        if (balanceOf(_from) < _amount) {
            revert InsufficientBalance();
        }

        _burn(_from, _amount);
    }

    // Fallback function

    receive() external payable {
        swapEtherForTokens();
    }
}
