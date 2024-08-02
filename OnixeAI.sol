// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

// src/interface/IUniswapV2.sol

interface IUniswapRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapRouter02 is IUniswapRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256))
        private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
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

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/GoodTrouble.sol

// OPENZEPPELIN IMPORTS

// UNISWAP INTERFACES

/**
 * @title Good Trouble
 * @author AssureDefi
 * @notice This is the token for Good Trouble on the ETH chain. It is an ERC20 token with a fixed supply.
 * Total Init Supply: 100,000,000 GTRB
 * Decimals: 18
 * Symbol: GTRB
 * Name: Good Trouble
 * This contract contains editable taxes for GTRB
 * Buy and Sell taxes will start at 40% and decrease by 5% every 5 minutes until it reaches 5%
 * Majority of taxes is converted to ETH, a small portion is kept to create liquidity, others are split between
 * marketing, dev, and buyback wallets.
 */
contract GoodTrouble is ERC20, Ownable {
    //-------------------------------------------------------------------------
    // Errors
    //-------------------------------------------------------------------------
    error GTRB__InvalidNewTax();
    error GTRB__InvalidValue();
    error GTRB__MaxTxExceeded();
    error GTRB__MaxWalletExceeded();
    error GTRB__InvalidListLength();
    error GTRB__OnlyDevWallet();
    error GTRB__OnlyMktWallet();
    error GTRB__OnlyBBWallet();
    error GTRB_NativeTransferFailed();
    error GTRB__NoBalance();
    error GTRB__AlreadySwapping();
    //-------------------------------------------------------------------------
    // STATE VARIABLES
    //-------------------------------------------------------------------------
    mapping(address => bool) public isExcludedFromTax;
    mapping(address => bool) public isMaxWalletExcluded;
    mapping(address => bool) public isMaxTxExcluded;
    // We can add more pairs to tax them when necessary
    mapping(address => bool) public isPair;

    address public devWallet;
    address public marketingWallet;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;
    IUniswapRouter02 public router;
    IUniswapPair public pair;

    uint public sellThreshold;
    uint public startTaxTime;
    uint public maxTx;
    uint public maxWallet;

    uint16 public mktShare = 375;
    uint16 public devShare = 125;
    uint16 private totalShares = 500;

    uint8 public buyTax = 5;
    uint8 public sellTax = 5;
    uint8 private swapping = 1;

    uint private constant _TAX_INTERVAL = 5 minutes;
    uint private constant MAX_TAX_TIME = 40 minutes;
    uint256 private constant _INIT_SUPPLY = 100_000_000 ether;
    uint256 private constant PERCENTILE = 100;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------
    event UpdateSellTax(uint tax);
    event UpdateBuyTax(uint tax);
    event UpdateDevWallet(
        address indexed prevWallet,
        address indexed newWallet
    );
    event UpdateMarketingWallet(
        address indexed prevWallet,
        address indexed newWallet
    );
    event UpdateBuybackWallet(
        address indexed prevWallet,
        address indexed newWallet
    );
    event UpdateTaxExclusionStatus(address indexed account, bool status);
    event UpdateMaxTxExclusionStatus(address indexed account, bool status);
    event UpdateMaxWalletExclusionStatus(address indexed account, bool status);
    event UpdateMaxTx(uint maxTx);
    event UpdateMaxWallet(uint maxWallet);
    event UpdateThreshold(uint threshold);
    event SetNewPair(address indexed pair);
    event UpdateShares(uint16 mktShare, uint16 devShare);
    event UpdateUniswapRouter(address indexed router);

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------
    constructor(
        address _devWallet,
        address _marketingWallet
    ) ERC20("Good Trouble", "GTRB") Ownable(_devWallet) {
        // Sell Threshold is 0.1% of the total supply
        sellThreshold = _INIT_SUPPLY / (10 * PERCENTILE);
        // Setup PancakeSwap Contracts
        router = IUniswapRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        IUniswapFactory factory = IUniswapFactory(router.factory());
        pair = IUniswapPair(factory.createPair(address(this), router.WETH()));
        isPair[address(pair)] = true;
        _approve(address(this), address(router), type(uint256).max);

        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[owner()] = true;
        isMaxWalletExcluded[owner()] = true;
        isMaxWalletExcluded[address(this)] = true;
        isMaxWalletExcluded[address(router)] = true;
        isMaxWalletExcluded[deadWallet] = true;
        isMaxWalletExcluded[address(pair)] = true;
        isMaxTxExcluded[owner()] = true;
        isMaxTxExcluded[address(this)] = true;
        isMaxTxExcluded[address(router)] = true;
        isMaxTxExcluded[address(0)] = true;
        devWallet = _devWallet;
        marketingWallet = _marketingWallet;
        maxTx = _INIT_SUPPLY / PERCENTILE; // 1% of total supply
        maxWallet = _INIT_SUPPLY / PERCENTILE; // 1% of total supply

        _mint(owner(), _INIT_SUPPLY);
    }

    //-------------------------------------------------------------------------
    // EXTERNAL / PUBLIC FUNCTIONS
    //-------------------------------------------------------------------------
    // Allow contract to receive Native tokens
    receive() external payable {}

    fallback() external payable {}

    //-------------------------------------------------------------------------
    // Owner Functions
    //-------------------------------------------------------------------------
    /**
     * @notice This function is called to edit the buy tax for INVA
     * @param _buyTax The new buy tax to set
     * @dev the tax can only be a max of 40%
     */
    function setBuyTax(uint8 _buyTax) external onlyOwner {
        if (_buyTax > 40) {
            revert GTRB__InvalidNewTax();
        }
        buyTax = _buyTax;
        emit UpdateBuyTax(_buyTax);
    }

    /**
     * @notice This function is called to edit the buy tax for INVA
     * @param _sellTax The new buy tax to set
     * @dev the tax can only be a max of 40%
     */
    function setSellTax(uint8 _sellTax) external onlyOwner {
        if (_sellTax > 40) {
            revert GTRB__InvalidNewTax();
        }
        sellTax = _sellTax;
        emit UpdateBuyTax(_sellTax);
    }

    /**
     * @notice Changes the tax exclusion status for an address
     * @param _address The address to set the tax exclusion status for
     * @param _status The exclusion status, TRUE for excluded, FALSE for not excluded
     */
    function setTaxExclusionStatus(
        address _address,
        bool _status
    ) external onlyOwner {
        isExcludedFromTax[_address] = _status;
        emit UpdateTaxExclusionStatus(_address, _status);
    }

    /**
     * @notice Changes the tax exclusion status for multiple addresses
     * @param addresses The list of addresses to set the tax exclusion status for
     * @param _status The exclusion status, TRUE for excluded, FALSE for not excluded for all addresses
     */
    function setMultipleTaxExclusionStatus(
        address[] calldata addresses,
        bool _status
    ) external onlyOwner {
        if (addresses.length == 0) {
            revert GTRB__InvalidListLength();
        }
        for (uint256 i = 0; i < addresses.length; i++) {
            isExcludedFromTax[addresses[i]] = _status;
            emit UpdateTaxExclusionStatus(addresses[i], _status);
        }
    }

    /**
     * @notice changes the max tx exclusion status for an address
     * @param _address The address to change the exclusion of max tx status of
     * @param _status The new exclusion status for the address || TRUE for excluded, FALSE for not excluded
     */
    function setMaxTxExclusionStatus(
        address _address,
        bool _status
    ) external onlyOwner {
        isMaxTxExcluded[_address] = _status;
        emit UpdateMaxTxExclusionStatus(_address, _status);
    }

    /**
     * @notice changes the max wallet exclusion status for an address
     * @param _address The address to change the exclusion of max wallet status of
     * @param _status The new exclusion status for the address || TRUE for excluded, FALSE for not excluded
     */
    function setMaxWalletExclusionStatus(
        address _address,
        bool _status
    ) external onlyOwner {
        // Can't change the status of a pair since it'll always be excluded from max wallet
        if (isPair[_address]) revert GTRB__InvalidValue();
        isMaxWalletExcluded[_address] = _status;
        emit UpdateMaxWalletExclusionStatus(_address, _status);
    }

    /**
     * @notice sets the max transaction amount for INVA
     * @param _maxTx The new max transaction amount to set
     * @dev the max transaction amount cannot be less than 0.2% of the total supply
     */
    function setMaxTx(uint _maxTx) external onlyOwner {
        if (_maxTx < _INIT_SUPPLY / 500) revert GTRB__InvalidValue();
        maxTx = _maxTx;
        emit UpdateMaxTx(_maxTx);
    }

    /**
     * @notice sets the max wallet amount for INVA
     * @param _maxWallet The new max wallet amount to set
     * @dev the max wallet amount cannot be less than 1% of the total supply
     */
    function setMaxWallet(uint _maxWallet) external onlyOwner {
        if (_maxWallet < _INIT_SUPPLY / 100) revert GTRB__InvalidValue();
        maxWallet = _maxWallet;
        emit UpdateMaxWallet(_maxWallet);
    }

    /**
     * @notice Set a different wallet to receive the swapped out funds
     * @param _devWallet The new wallet to receive buy funds
     * @dev ONLY CURRENT BUY TAX WALLET AND OWNER CAN CHANGE THIS
     */
    function updateDevWallet(address _devWallet) external {
        if (msg.sender != devWallet && msg.sender != owner())
            revert GTRB__OnlyDevWallet();
        if (_devWallet == address(0)) revert GTRB__InvalidValue();
        emit UpdateDevWallet(devWallet, _devWallet);
        devWallet = _devWallet;
    }

    /**
     * @notice Set a different wallet to receive the swapped out funds for marketing
     * @param _marketingwallet The new sell wallet to receive sell funds
     * @dev ONLY CURRENT MARKETING WALLET AND OWNER CAN CHANGE THIS
     */
    function updateMarketingWallet(address _marketingwallet) external {
        if (msg.sender != marketingWallet && msg.sender != owner())
            revert GTRB__OnlyMktWallet();
        if (_marketingwallet == address(0)) revert GTRB__InvalidValue();
        emit UpdateMarketingWallet(marketingWallet, _marketingwallet);
        marketingWallet = _marketingwallet;
    }

    /**
     * @notice The sell threshold is the amount of INVA that needs to be collected before a sell for Native happens
     * @param _sellThreshold The new sell threshold to set
     */
    function updateSellThreshold(uint _sellThreshold) external onlyOwner {
        // Sell threshold cannot be more than 0.1% of the total supply
        // or less than 0.0001% of the total supply
        if (
            _sellThreshold > _INIT_SUPPLY / 1000 ||
            _sellThreshold < _INIT_SUPPLY / 100000
        ) revert GTRB__InvalidValue();
        sellThreshold = _sellThreshold;
        emit UpdateThreshold(_sellThreshold);
    }

    /**
     * @notice regardless of the collected amount, the contract will swap, liquidate and transfer the funds to the respective wallets
     */
    function manualSwap() external onlyOwner {
        if (swapping != 1) revert GTRB__AlreadySwapping();
        uint balance = balanceOf(address(this));
        _swapAndTransfer(balance);
    }

    /**
     * @notice sets an address as a new pair to charge taxes on it
     * @param _pair The pair to add to the list of pairs to tax
     */
    function addPair(address _pair) external onlyOwner {
        if (_pair == address(0)) revert GTRB__InvalidValue();
        isPair[_pair] = true;
        isMaxWalletExcluded[_pair] = true;
        emit SetNewPair(_pair);
    }

    /**
     * @notice updates the shares for tax spread
     * @param _mktShare Amount to be shared to the marketing wallet
     * @param _devShare Amount to be shared to the dev wallet
     */
    function updateShares(
        uint16 _mktShare,
        uint16 _devShare
    ) external onlyOwner {
        totalShares = _mktShare + _devShare;
        // Total Shares cannot be zero
        if (totalShares == 0) revert GTRB__InvalidValue();
        mktShare = _mktShare;
        devShare = _devShare;
        emit UpdateShares(_mktShare, _devShare);
    }

    function updateUniswapRouter(address _router) external onlyOwner {
        if (router.WETH() != IUniswapRouter02(_router).WETH())
            revert GTRB__InvalidValue();
        router = IUniswapRouter02(_router);
        emit UpdateUniswapRouter(_router);
    }

    function recoverNative(address _to, uint _amount) external onlyOwner {
        (bool success, ) = payable(_to).call{value: _amount}("");
        if (!success) revert GTRB_NativeTransferFailed();
    }

    function recoverERC20(address _token, address _to) external onlyOwner {
        uint amount = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(_to, amount);
    }

    //-------------------------------------------------------------------------
    // INTERNAL/PRIVATE FUNCTIONS
    //-------------------------------------------------------------------------
    /**
     * @notice This function overrides the ERC20 `_transfer` function to apply taxes and swap and transfer.
     * @param from Address that is sending tokens
     * @param to Address that is receiving tokens
     * @param amount Amount of tokens being transfered
     * @dev Although this is an override, it still uses the original `_transfer` function from the ERC20 contract to finalize the updatess
     * @dev On first adding liquidity, the contract will enable the high tax timer
     */
    function _update(address from, address to, uint amount) internal override {
        bool isBuy = isPair[from];
        bool isSell = isPair[to];
        bool anyExcluded = isExcludedFromTax[from] || isExcludedFromTax[to];

        // check max tx if sender or receiver are excluded or amount surpasses max tx revert
        if (!isMaxTxExcluded[from] && !isMaxTxExcluded[to] && amount > maxTx)
            revert GTRB__MaxTxExceeded();

        uint currentINVABalance = balanceOf(address(this));
        if (
            !isBuy &&
            currentINVABalance > sellThreshold &&
            !anyExcluded &&
            swapping == 1
        ) {
            _swapAndTransfer(currentINVABalance);
        }

        uint fee = 0;
        if (!anyExcluded) {
            uint8 tax = _getTimedTax(isBuy, isSell);
            fee = (amount * tax) / PERCENTILE;
            if (fee > 0) {
                amount -= fee;
                super._update(from, address(this), fee);
            }
        }
        if (isSell && startTaxTime == 0) {
            startTaxTime = block.timestamp;
        }
        // check max wallet
        if (!isMaxWalletExcluded[to] && balanceOf(to) + amount > maxWallet)
            revert GTRB__MaxWalletExceeded();

        // Transfer rest
        super._update(from, to, amount);
    }

    function _swapAndTransfer(uint balance) private {
        swapping <<= 1;
        if (balance == 0) revert GTRB__NoBalance();
        // Sell half of liqAmount to ETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint minAmount = router.getAmountsOut(balance, path)[1];
        minAmount = (minAmount * 7) / 10;
        // Sell rest
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            balance,
            minAmount,
            path,
            address(this),
            block.timestamp
        );
        // Distribute to rest
        uint nativeBalance = address(this).balance;
        if (totalShares == 0) return;
        uint mktAmount = (nativeBalance * mktShare) / totalShares;
        uint devAmount = (nativeBalance * devShare) / totalShares;
        // Transfer to wallets
        if (mktAmount > 0) {
            (bool success, ) = payable(marketingWallet).call{value: mktAmount}(
                ""
            );
            if (!success) revert GTRB_NativeTransferFailed();
        }
        if (devAmount > 0) {
            (bool success, ) = payable(devWallet).call{value: devAmount}("");
            if (!success) revert GTRB_NativeTransferFailed();
        }

        swapping >>= 1;
    }

    /**
     * @notice This function is called to get the tax for the current block
     * @param isBuy dictates if the tax is for a buy
     * @param isSell dictates if the tax is for a sell
     * @return the tax to be applied %
     * @dev the tax will decrease by 5% every 5 minutes until it reaches 5%
     */
    function _getTimedTax(
        bool isBuy,
        bool isSell
    ) private view returns (uint8) {
        // if startTaxTime is not set or both isBuy and isSell are false, return 0
        if ((!isBuy && !isSell) || startTaxTime == 0) return 0;

        uint timePassed = block.timestamp - startTaxTime;
        // If above max tax time, return the minimum tax
        if (timePassed >= MAX_TAX_TIME) {
            if (isBuy) return buyTax;
            if (isSell) return sellTax;
            return 0;
        }
        // it'll decrease by 5% every 5 minutes
        return uint8(40 - (5 * (timePassed / _TAX_INTERVAL)));
    }
}
