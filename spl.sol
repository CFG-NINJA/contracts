/**
 *Submitted for verification at BscScan.com on 2024-05-08
*/

// Sources flattened with hardhat v2.22.3 https://hardhat.org

// SPDX-License-Identifier: MIT AND No

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/SPL.sol

/**
 *Submitted for verification at BscScan.com on 2024-04-01
 */

// Original license: SPDX_License_Identifier: No

pragma solidity ^0.8.24;


interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint
    );

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address lpPair);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

//--- Contract v3 ---//
contract SPL is Context, Ownable, IERC20 {
    function totalSupply() external pure returns (uint256) { return _totalSupply; }
    function decimals() external pure  returns (uint8) { return _decimals; }
    function symbol() external pure  returns (string memory) { return _symbol; }
    function name() external pure  returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private liquidityAdd;
    mapping (address => bool) private isLpPair;
    mapping (address => bool) private isPresaleAddress;
    mapping (address => uint256) private balance;


    uint8 constant private _decimals = 18;
    uint256 constant public _totalSupply = 140_000_000 * (10 ** _decimals);
    uint256 public swapThreshold = 14000 * (10 ** _decimals);
    uint256 public minSwapThreshold = 140 * (10 ** _decimals);
    uint256 public buyfee = 50; //5%
    uint256 public sellfee = 50; //5%
    uint256 constant public transferfee = 0; // 0%
    address public stakingContract;
    uint256 constant public fee_denominator = 1_000;
    bool private canSwapFees = true;
    address payable private devWallet;

    uint256 private devAllocation = 100;
    uint256 private liquidityAllocation = 0;


    IRouter02 public swapRouter;
    string constant private _name = "SocialPal";
    string constant private _symbol = "SPL";
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address immutable public lpPair;
    bool public isTradingEnabled = false;
    bool private inSwap;

    modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }


    event _enableTrading();
    event _setPresaleAddress(address account, bool enabled);
    event _toggleCanSwapFees(bool enabled);
    event _changeThreshold(uint256 newThreshold);
    event _changeDevWallet(address newSell);
    event _disableSwapFees();
    event _setStakingAddress(address staking);
    event _swapAndLiquify();
    event _changeFeeAllocations(uint256 dev, uint256 liquify);
    event _internalSwap();
    event _setNoFeeWallet(address indexed addr, bool enabled);

    constructor (address _devWallet) Ownable(address(msg.sender)) {
        require(devAllocation + liquidityAllocation == 100,"MUST_BE_100");
        require(_devWallet != address(0), "INVALID_WALLET");
        devWallet = payable(_devWallet);
        _noFee[msg.sender] = true;
        
        if (block.chainid == 56) {
            swapRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            swapRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 42161) {
            swapRouter = IRouter02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        } else if (block.chainid == 5) {
            swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else {
            revert("INVALID_CHAIN");
        }

        liquidityAdd[msg.sender] = true;
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        
        lpPair = IFactoryV2(swapRouter.factory()).createPair(swapRouter.WETH(), address(this));
        isLpPair[lpPair] = true;
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isNoFeeWallet(address account) external view returns(bool) {
        return _noFee[account];
    }

    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        require(_noFee[account] != enabled, "NO_CHANGE");
        _noFee[account] = enabled;
        emit _setNoFeeWallet(account, enabled);
    }
    
    function isLimitedAddress(address ins, address out) internal view returns (bool) {

        bool isLimited = ( ins != owner() && ins != stakingContract)
            && ( out != owner() && out != stakingContract)
            && msg.sender != owner()
            && !liquidityAdd[ins]  && !liquidityAdd[out] && out != address(0) && out != address(this);
        
        return isLimited;
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
    }

    function is_sell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

    function canSwap(address ins, address out) internal view returns (bool) {
        bool canswap = canSwapFees && !isPresaleAddress[ins] && !isPresaleAddress[out];
        return canswap;
    }

    function toggleCanSwapFees(bool yesno) external onlyOwner {
        require(canSwapFees != yesno,"NO_CHANGE");
        canSwapFees = yesno;
        emit _toggleCanSwapFees(yesno);
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isLimitedAddress(from,to)) {
            require(isTradingEnabled,"TRADING_NOT_ENABLED");
        }


        if(is_sell(from, to) &&  !inSwap && canSwap(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= swapThreshold) { 
                
                if(devAllocation > 0) {
                    internalSwap((contractTokenBalance * devAllocation) / 100);
                }
                
                if(liquidityAllocation > 0) {
                    swapAndLiquify(contractTokenBalance * liquidityAllocation / 100);
                }
             }
        }

        if (_noFee[from] || _noFee[to]){
            takeFee = false;
        }
        balance[from] -= amount; 
        uint256 amountAfterFee = (takeFee) ? takeTaxes(from, is_buy(from, to), is_sell(from, to), amount) : amount;
        balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function changeDevWallet(address newDev) external onlyOwner {
        require(newDev != address(0),"ZERO_ADDR");
        devWallet = payable(newDev);
        emit _changeDevWallet(newDev);
    }

    function disableSwapFees() external onlyOwner {
        require(buyfee != 0 || sellfee != 0);
        buyfee = 0;
        sellfee = 0;
        emit _disableSwapFees();
    }

    function takeTaxes(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy) {
            fee = buyfee;
        }    
        else if (issell) {
              fee = sellfee; 
        } else {
             fee = transferfee; 
        }

        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal inSwapFlag {
        uint256 firstmath = contractTokenBalance / 2;
        uint256 secondMath = contractTokenBalance - firstmath;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            firstmath,
            0, 
            path,
            address(this),
            block.timestamp) {} catch {return;}
        
        uint256 newBalance = address(this).balance - initialBalance;

        try swapRouter.addLiquidityETH{value: newBalance}(
            address(this),
            secondMath,
            0,
            0,
            DEAD,
            block.timestamp
        ){} catch {return;}

        emit _swapAndLiquify();
    }

    function internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }
        bool success;
        if(address(this).balance > 0) (success,) = devWallet.call{value: address(this).balance, gas: 35000}("");
        if(success)
        {
            emit _internalSwap();
        }
    }

    function setPresaleAddress(address presale, bool yesno) external onlyOwner {
        require(isPresaleAddress[presale] != yesno,"NO_CHANGE");
        isPresaleAddress[presale] = yesno;
        _noFee[presale] = yesno;
        liquidityAdd[presale] = yesno;
        emit _setPresaleAddress(presale, yesno);
    }

    function setStakingAddress(address staking) external onlyOwner {
        require(staking != address(0), "INVALID_ADDRESS");
        stakingContract = staking;
        emit _setStakingAddress(staking);
    }

    function enableTrading() external onlyOwner {
        require(!isTradingEnabled, "TRADING_ENABLED");
        isTradingEnabled = true;
        emit _enableTrading();
    }

    function changeFeeAllocations(uint256 _devAllocation, uint256 _swapLiquifyAllocation) external onlyOwner {
        require(_devAllocation + _swapLiquifyAllocation == 100, "MUST_BE_100");
        devAllocation = _devAllocation;
        liquidityAllocation = _swapLiquifyAllocation;
        emit _changeFeeAllocations(devAllocation, liquidityAllocation);
    }

    function changeSwapThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold * (10 ** _decimals) >= minSwapThreshold && _threshold * (10 ** _decimals) <= _totalSupply, "INVALID_THRESHOLD");
        swapThreshold = _threshold * ( 10 ** _decimals);
        emit _changeThreshold(swapThreshold);
    }

    function triggerInternalSwap() external onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0, "NO_FEE_BAL");
        require(devAllocation > 0, "INVALID_DEV_ALLOC");
        internalSwap((contractTokenBalance * devAllocation) / 100);
    }
}