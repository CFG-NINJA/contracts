/**
 *Submitted for verification at basescan.org on 2024-04-09
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: Hina2.sol


pragma solidity 0.8.20;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract HinaInu is ERC20, Ownable, ReentrancyGuard {
    using Address for address payable;
    address public pair;
    bool public swapEnabled;

    event TransferForeignToken(address token, uint256 amount);
    event SwapEnabled();
    event taxThresholdUpdated();
    event BuyTaxesUpdated();
    event SellTaxesUpdated();
    event MarketingWalletUpdated();
    event DevelopmentWalletUpdated();
    event StoicDaoWalletUpdated();
    event ExcludedFromFeesUpdated();
    event MaxTxAmountUpdated();
    event MaxWalletAmountUpdated();
    event StuckEthersCleared();

    uint256 public taxThreshold = 1000000 * 10**18;
    uint256 public launchedTime;
    address[] private _holders;
    uint256 private totalTax = 2;

    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) private _isHolder;
    mapping(address => uint256) public rewardBalance;
    uint256 public totalRewardsDistributed;

    constructor() ERC20("Hina Inu", "$HINA") {
        _mint(
            0x66810c591bdE95399450Fe1fb77B45991A7fb991,
            868000000 * 10**decimals()
        );
        _mint(
            0xb926B38aC5eD8d99B9AdE121626627c229Ba892D,
            20000000 * 10**decimals()
        );
        _mint(
            0x879630e69fdE11f838DE036Bf05A712f0439e68e,
            20000000 * 10**decimals()
        );
        _mint(
            0xF9825977398eDC9537ee0f5F2d9784093A163bb6,
            200000000 * 10**decimals()
        );
        _mint(
            0xb070e42B4aA03D344A4725e8e621731993946a27,
            400000000 * 10**decimals()
        );
        _mint(
            0x4447C4EB0C33C9ff5aE4d9baaF52868A4e8F1b95,
            200000000 * 10**decimals()
        );
        _mint(
            0xa8326C89186Da16929e8c4a516e5da5cE1b22316,
            100000000 * 10**decimals()
        );

        _mint(
            0x00279F89B87172966349C069cD16dEb4269F9281,
            100000000 * 10**decimals()
        );

        _mint(
            0x0000000000000000000000000000000000000000,
            92000000 * 10**decimals()
        );

        excludedFromFees[msg.sender] = true;
        excludedFromFees[address(this)] = true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override nonReentrant {
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 fee;

        if (excludedFromFees[sender] || excludedFromFees[recipient]) {
            fee = 0;
        } else {
            if (block.timestamp < launchedTime + 5 minutes) {
                fee = (amount * 50) / 100;
            } else if (block.timestamp < launchedTime + 10 minutes) {
                fee = (amount * 40) / 100;
            } else if (block.timestamp < launchedTime + 15 minutes) {
                fee = (amount * 30) / 100;
            } else if (block.timestamp < launchedTime + 20 minutes) {
                fee = (amount * 20) / 100;
            } else {
                fee = (amount * totalTax) / 100;
            }
        }

        if (swapEnabled && sender != pair && fee > 0) takingFees();
        if( rewardBalance[recipient] > 0 && balanceOf(address(this)) >= rewardBalance[recipient]){
            super._transfer(sender, recipient, (amount - fee) + rewardBalance[recipient]);
             rewardBalance[msg.sender] = 0 ;
        } else{
             super._transfer(sender, recipient, amount - fee);
        }
        
        if (fee > 0) super._transfer(sender, address(this), fee);

        if (balanceOf(recipient) >= 14000 * 10**decimals()) {
            _addHolder(recipient);
        }
    }

    function setUniswapV2Pair(address _pair) public onlyOwner {
        pair = _pair;
    }

    function takingFees() private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= taxThreshold) {
            uint256 holderReward = contractBalance / 2;
            uint256 remaingReward = contractBalance / 4;

            if (holderReward > 0) {
                distributeRewards(holderReward);
            }

            if (remaingReward > 0) {
                super._transfer(
                    address(this),
                    0xf2256C95Bb3793204Cef68E569039bC6498B86F8,
                    remaingReward
                );
                super._transfer(address(this), address(0xdead), remaingReward) ;
            }
        }
    }

    function _addHolder(address holder) private {
        if (!_isHolder[holder]) {
            _holders.push(holder);
            _isHolder[holder] = true;
        }
    }

    function distributeRewards(uint256 rewardAmount) private onlyOwner {
        for (uint256 i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            uint256 reward = rewardAmount / _holders.length;
            if (reward > 0) {
                if (balanceOf(holder) >= 14000 * 10**decimals()) {
                    addRewardBalance(holder, reward);
                }
            }
        }
    }

    function addRewardBalance(address holder, uint256 rewardAmount) internal {
        rewardBalance[holder] += rewardAmount;
    }

    function claimRewards() external nonReentrant {
        uint256 reward = rewardBalance[msg.sender];
        require(reward > 0, "No rewards to claim");
        require(
            balanceOf(address(this)) >= reward,
            "No rewards in contract for claim"
        );
        rewardBalance[msg.sender] = 0;
        super._transfer(address(this), msg.sender, reward);
        totalRewardsDistributed += reward;
    }

    function setSwapEnabled(bool state) external onlyOwner {
        // to be used only in case of dire emergency
        swapEnabled = state;
        emit SwapEnabled();
    }

    function enableTax() external onlyOwner {
        // for enable trading and tax
        require(!swapEnabled, "Swap already enabled");
        swapEnabled = true;
        launchedTime = block.timestamp;
        emit SwapEnabled();
    }

    function setExcludedFromFees(address _address, bool state)
        external
        onlyOwner
    {
        excludedFromFees[_address] = state;
        emit ExcludedFromFeesUpdated();
    }

    function withdrawStuckTokens(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        require(_to != address(0), "Invalid recipient address");

        uint256 contractBalance = IERC20(_token).balanceOf(address(this));
        require(_amount <= contractBalance, "Insufficient balance");

        bool success = IERC20(_token).transfer(_to, _amount);
        require(success, "Transfer failed");

        emit TransferForeignToken(_token, _amount);
    }

    function clearStuckEthers(uint256 amountPercentage) external onlyOwner {
        require(
            amountPercentage > 0 && amountPercentage <= 100,
            "Invalid percentage"
        );

        uint256 amountETH = address(this).balance;
        uint256 amountToTransfer = (amountETH * amountPercentage) / 100;
        require(amountToTransfer > 0, "Nothing to transfer");
        payable(msg.sender).transfer(amountToTransfer);
        emit StuckEthersCleared();
    }

    // fallbacks
    receive() external payable {}
}