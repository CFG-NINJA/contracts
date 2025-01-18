//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 9;
    }


    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }


    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }


    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }


    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }


    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }


    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }


    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract TradeLightFactory is Ownable{

    event Creation(address creation);
    address deployFeeWallet = 0xd4a0aB5A7eEC664F5CFC9e5D85Ad6841Dfa5587C;
    uint256 deployFee = 0.1 ether;
    constructor () Ownable(msg.sender) {}
    receive() external payable {}

    function deployTradeLight(uint[] memory numbers, address[] memory addresses, string[] memory names) external payable returns (address){
        require(msg.value >= deployFee, "Insufficinet deploy Fee");
        TradeLight _newContract;
        _newContract =  new TradeLight(numbers, addresses, names);
        emit Creation(address(_newContract));
        (bool temp, ) = payable(deployFeeWallet).call{value: (deployFee)}("");
        assert(temp);
        return address(_newContract);
    }

    function updateDeployFeeWallet(address _deployFeeWallet) external onlyOwner {
        require(_deployFeeWallet != address(0),"Fee wallets must not be the ZERO address");
        deployFeeWallet = _deployFeeWallet;
    }

    function updateDeployFee(uint256 _deployFee) external onlyOwner {
        require(_deployFee <= 0.2 ether ,"Deploy fees must not be more than 0.2 eth");
        deployFee = _deployFee;
    }
}


contract TradeLight is ERC20, Ownable, ReentrancyGuard {
    uint256 public teamTaxPercentage; // Team tax percentage
    uint256 public marketingTaxPercentage; // Team tax percentage
    uint256 public referralTaxPercentage; // Referral tax percentage
    uint256 public transactionLimitPercentageX10; // Initial transaction limit percentage
    uint256 public referralCodeCounter = 0; // Total referalcodes counter
    uint256 public lockTimestamp;

    //Tax collection
    uint256 public teamTaxBalance = 0;
    uint256 public marketingTaxBalance = 0;

    address public teamWallet;
    address public marketingWallet;
    uint256 public startingLiquidityAmount;
    uint256 public totalLiquidity;
    uint256 public liqConst;
    bool public transactionLimitEnabled = true;
    bool public tradingLive = false;    

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => uint256) private referralCodes;
    mapping(address => uint256) private refereeCodes;
    mapping(uint256 => address) private referralAddresses;
    mapping(address => uint256) public referralRewards;
    mapping(address => uint256) public claimedReferralRewards;
    mapping(address => uint256) private _lastBuyBlock;
    mapping(address => bool) public isUnauthorized;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    event Buy(address indexed buyer, uint256 ethAmount, uint256 tokenOut, address indexed referrer, uint256 referrerBonus);
    event Sell(address indexed seller, uint256 amount, uint256 ethOut, address indexed referrer, uint256 referrerBonus);
    event FeesChanged(uint256 teamTaxPercentage, uint256 marketingTaxPercentage, uint256 referralTaxPercentage);
    event FeeWalletsUpdated(address teamFeeWallet, address marketingFeeWallet);
    event NewReferralCodeGenerated(uint256 referralCode);
    event tradingStarted(bool indexed enabled, uint256 indexed startTime);

        constructor(uint[] memory numbers, address[] memory addresses, string[] memory names) ERC20(names[0], names[1]) Ownable(addresses[0])  {
        uint256 _supply = numbers[0] * 10**decimals();
        uint256 devTokenAmount = (_supply * numbers[1]) / 100;
        teamTaxPercentage = numbers[2];
        marketingTaxPercentage = numbers[3];
        referralTaxPercentage = numbers[4];
        transactionLimitPercentageX10 = numbers[5];

        teamWallet = addresses[1];
        marketingWallet = addresses[2];
        isFeeExempt[msg.sender] = true;
        isFeeExempt[teamWallet] = true;
        isFeeExempt[marketingWallet] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[teamWallet] = true;
        isTxLimitExempt[marketingWallet] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(0)] = true;
        referralCodes[teamWallet] = 100000;
        referralAddresses[100000] = teamWallet;

        _mint(address(this), _supply - devTokenAmount);
        _mint(addresses[0], devTokenAmount);
    }

    function setTransactionLimitEnabled(bool enabled) external onlyOwner {
        transactionLimitEnabled = enabled;
    }

    function removeTransactionLimit() external onlyOwner {
        transactionLimitEnabled = false;
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }


    function getReferralCodeForAddress(address walletAddress) external view returns (uint256) {
        return referralCodes[walletAddress];
    }

    function getRefereeCodeForAddress(address walletAddress) external view returns (uint256) {
        return refereeCodes[walletAddress];
    }
    
    function getReferralAddressForCode(uint256 referralCode) external  view returns (address) {
        // Retrieve the stored address for the referral code
        return referralAddresses[referralCode];
    }

    function _getReferralAddress(uint256 referralCode) internal  view returns (address) {
        // Retrieve the stored address for the referral code
        return referralAddresses[referralCode];
    }

    function goLive() external payable onlyOwner{
        require(!tradingLive,"Trading already Enabled.");
        totalLiquidity = msg.value;
        liqConst = totalLiquidity * balanceOf(address(this));
        tradingLive = true;
        emit tradingStarted(tradingLive, block.timestamp);
    }
    function buy(uint256 minTokenOut, uint256 deadline, uint256 referralCode)
        public
        payable
        nonReentrant
        returns (bool)
    {
        // Check deadline
        require(block.timestamp <= deadline, "Transaction expired");

        // Frontrun Guard
        _lastBuyBlock[msg.sender] = block.number;
        
        // liquidity is set
        require(totalLiquidity > 0, "The token has no liquidity");

        require(msg.value > 0, "Invalid ETH amount");
        require(referralCode >= 100000 && referralCode <= (100000 + referralCodeCounter), "Invalid referral code");

        // Calculate taxes
        uint256 teamTax = 0;
        uint256 marketingTax = 0;
        uint256 referralTax = 0;
        if (!isFeeExempt[msg.sender]) {
            teamTax = (msg.value * teamTaxPercentage) / 100;
            marketingTax=(msg.value * marketingTaxPercentage) / 100;
            referralTax = (msg.value * referralTaxPercentage) / 100;
        }
        uint256 _buyamount = msg.value - teamTax - marketingTax - referralTax;

        // Calculate token amount based on provided ETH amount
        uint256 tokenAmount = balanceOf(address(this)) - (liqConst / (_buyamount + totalLiquidity));

        // Perform slippage check
        require(tokenAmount >= minTokenOut, "INSUFFICIENT OUTPUT AMOUNT");        

        // Check transaction limit
        if (transactionLimitEnabled) {
            require(tokenAmount <= (totalSupply() * transactionLimitPercentageX10) / 1000, "Transaction amount exceeds limit");
        }

        // Update liquidity after deducting taxes
        totalLiquidity += _buyamount;

        // Transfer tokens to buyer
        _transfer(address(this), msg.sender, tokenAmount);

        // Update referee codes and rewards
        if (refereeCodes[msg.sender] == 0) {
            refereeCodes[msg.sender] = referralCode;
        }
        address referralWallet = _getReferralAddress(refereeCodes[msg.sender]);
        teamTaxBalance += teamTax;
        marketingTaxBalance += marketingTax;
        referralRewards[referralWallet] += referralTax;

        // Emit buy event
        emit Buy(msg.sender, msg.value, tokenAmount, referralWallet, referralTax);
        return true;
    }

    function sell(uint256 tokenAmount, uint256 minETHOut, uint256 deadline)
        public nonReentrant returns (bool){
        require(!isUnauthorized[msg.sender], "Unauthorized seller");
        // Check deadline
        require(block.timestamp <= deadline, "Transaction expired");

        //Frontrun Guard
        require(
            _lastBuyBlock[msg.sender] != block.number,
            "Buying and selling in the same block is not allowed!"
        );

        // Check transaction limit
        if (transactionLimitEnabled) {
            require(tokenAmount <= (totalSupply() * transactionLimitPercentageX10) / 1000, "Transaction tokenAmount exceeds limit");
        }

        // Calculate ETH amount based on updated liquidity
        uint256 ethAmount = totalLiquidity - (liqConst / (balanceOf(address(this)) + tokenAmount));

        //slippage revert
        require(ethAmount >= minETHOut, "INSUFFICIENT OUTPUT AMOUNT");

        // Calculate and deduct taxes in ETH amount
        uint256 teamTax = 0;
        uint256 marketingTax = 0;
        uint256 referralTax = 0;
        if (!isFeeExempt[msg.sender]) {
            teamTax = (ethAmount * teamTaxPercentage) / 100;
            marketingTax =  (ethAmount * marketingTaxPercentage) / 100;
            referralTax = (ethAmount * referralTaxPercentage) / 100;
        }
        uint256 sellerETH = ethAmount - teamTax - marketingTax - referralTax;

        // Update liquidity and send ETH to seller after deducting taxes
        totalLiquidity -= ethAmount;
        (bool temp, ) = payable(msg.sender).call{value: sellerETH}("");
        assert(temp);

        // Transfer tokens from seller to contract
        _transfer(msg.sender, address(this), tokenAmount);

        // Update team tax and referral rewards in the contract
        teamTaxBalance += teamTax;
        marketingTaxBalance += marketingTax;

        // Update referee codes to marketing wallet if there is no referee.
        if (refereeCodes[msg.sender] == 0) {
            refereeCodes[msg.sender] = 100000;
        }
        address referralWallet = _getReferralAddress(refereeCodes[msg.sender]);
        referralRewards[referralWallet] += referralTax;

        // Emit sell event
        emit Sell(msg.sender, tokenAmount, sellerETH, referralWallet, referralTax);
        return true;
    }

    function generateReferralCode() external returns (uint256){
        require(referralCodes[msg.sender] == 0, "Already has a referee code");

        // Generate new referral code
        uint256 newReferralCode = 100001 + referralCodeCounter;

        // Store referral code
        referralCodes[msg.sender] = newReferralCode;
        referralAddresses[newReferralCode] = msg.sender;

        // Increment referral code counter
        referralCodeCounter++;
        emit NewReferralCodeGenerated(newReferralCode);
        return newReferralCode;
    }

    function withdrawReferralRewards() external {
        uint256 pendingReferralReward = referralRewards[msg.sender] - claimedReferralRewards[msg.sender];
        require(pendingReferralReward > 0, "No referral rewards available");
        (bool temp, ) = payable(msg.sender).call{value: (pendingReferralReward)}("");
        assert(temp);
        claimedReferralRewards[msg.sender] += pendingReferralReward;
    }

    function withdrawTeamTax() external onlyOwner {
        uint256 teamTaxAmount = teamTaxBalance;
        require(teamTaxAmount > 0, "No team tax available");

        (bool temp, ) = payable(teamWallet).call{value: (teamTaxAmount)}("");
        assert(temp);
        teamTaxBalance = 0;
    }

    function withdrawMarketingTax() external onlyOwner {
        uint256 marketingTaxAmount = marketingTaxBalance;
        require(marketingTaxAmount > 0, "No marketing tax available");
        (bool temp, ) = payable(marketingWallet).call{value: (marketingTaxAmount)}("");
        assert(temp);
        marketingTaxBalance = 0;
    }

    function getTotalLiquidity() public view returns (uint256) {
        return totalLiquidity;
    }

    function calculatePrice() public view returns (uint256) {
        require(totalLiquidity > 0, "No Liquidity");
        return (totalLiquidity * 1000000) / balanceOf(address(this));
    }

    function getMarketCap() external view returns (uint256) {
        return ((totalSupply() * calculatePrice()) / 1000000);
    }

    function addLiquidity() external payable onlyOwner {
        uint256 tokensToAdd = (balanceOf(address(this)) * msg.value) / totalLiquidity;
        require(balanceOf(msg.sender) > tokensToAdd, "Not enough tokens to add to liqudity");
        totalLiquidity += msg.value;
        _transfer(msg.sender, address(this), tokensToAdd);

        // Recalculate liqConst based on the updated reserves
        uint256 newTokenReserve = balanceOf(address(this));
        uint256 newETHReserve = address(this).balance;
        liqConst = newTokenReserve * newETHReserve;

        emit Transfer(msg.sender, address(this), tokensToAdd);
    }

    function getETHAmountOut(uint256 amountIn) public view returns (uint256) {
        uint256 ethBefore = totalLiquidity;
        uint256 ethAfter = liqConst / (balanceOf(address(this)) + amountIn);
        return ethBefore - ethAfter;
    }

    function getTokenAmountOut(uint256 ethAmountIn) public view returns (uint256) {
    uint256 tokenBefore = balanceOf(address(this));
    uint256 tokenAfter = liqConst / (totalLiquidity + ethAmountIn);
    return tokenBefore - tokenAfter;
    }

    function lockTheContract(uint256 _lockTimestamp) external onlyOwner {
        lockTimestamp = _lockTimestamp;
    }

    function withdrawLiquidityETH() external onlyOwner {
        require(block.timestamp >= lockTimestamp, "Contract is still locked.");
        uint256 contractBalance = address(this).balance;
        (bool temp, ) = payable(owner()).call{value: (contractBalance)}("");
        assert(temp);
    }

    function withdrawLiquidityPercentage(uint256 _liquidityPercentage) external onlyOwner {
        require(block.timestamp >= lockTimestamp, "Contract is still locked.");
        require(_liquidityPercentage <= 100, "Percentage cannot be more than 100%.");
        uint256 contractBalance = address(this).balance;
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 withdrawETH = (contractBalance * _liquidityPercentage) / 100;
        uint256 withdrawTokens = (contractTokenBalance * _liquidityPercentage) / 100;
        _transfer(address(this), msg.sender, withdrawTokens);
        (bool temp, ) = payable(owner()).call{value: (withdrawETH)}("");
        assert(temp);

        // Recalculate liqConst based on the updated reserves
        uint256 newTokenReserve = balanceOf(address(this));
        uint256 newETHReserve = address(this).balance;
        liqConst = newTokenReserve * newETHReserve;
    }


    function changeFees(uint256 _teamTaxPercentage, uint256 _marketingTaxPercentage, uint256 _referralTaxPercentage) external onlyOwner {
        require(_teamTaxPercentage + _marketingTaxPercentage + _referralTaxPercentage <= 20,"Fees are too high: Total fees should be below 20%.");

        teamTaxPercentage = _teamTaxPercentage;
        marketingTaxPercentage = _marketingTaxPercentage;
        referralTaxPercentage = _referralTaxPercentage;

        emit FeesChanged(_teamTaxPercentage, _marketingTaxPercentage, _referralTaxPercentage);
    }

    function updateFeeWallet(address _teamWallet, address _marketingWallet) external onlyOwner {
        require(_teamWallet != address(0),"Team fee wallet must not be the ZERO address");
        require(_marketingWallet != address(0),"Marketing fee wallet must not be the ZERO address");

        teamWallet = _teamWallet;
        marketingWallet = _marketingWallet;

        emit FeeWalletsUpdated(teamWallet, marketingWallet);
    }

    // Function to mark multiple unauthorized addresses.
    function unauthorize(address[] calldata addresses, bool _isUnauthorized) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            isUnauthorized[addresses[i]] = _isUnauthorized;
        }
    }
    
    receive() external payable {
        if (msg.sender != owner()) {
            uint256 _deadline = block.timestamp + 5 minutes;
            uint256 _referralCode = 100000;
            buy(0, _deadline, _referralCode);
        }
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        if (to == address(this)) {
            uint256 _deadline = block.timestamp + 5 minutes;
            sell(value, 0, _deadline); // Default minOut to 0 for direct sells.
        } else {
            address owner = _msgSender();
            _transfer(owner, to, value);
        }
        return true;
    }

}