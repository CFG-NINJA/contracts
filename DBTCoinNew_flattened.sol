// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


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

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

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
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

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
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

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

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





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

    mapping(address account => mapping(address spender => uint256)) private _allowances;

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
    function allowance(address owner, address spender) public view virtual returns (uint256) {
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
    function approve(address spender, uint256 value) public virtual returns (bool) {
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
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
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

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
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

// File: DBTC Coin/contracts/interface/ISwapRouter.sol


pragma solidity ^0.8.0;

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}


// File: DBTC Coin/contracts/interface/ISwapFactory.sol


pragma solidity ^0.8.0;

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}


// File: DBTC Coin/contracts/interface/ISwapPair.sol


pragma solidity ^0.8.0;

interface ISwapPair {
    function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function skim(address to) external;

    function sync() external;
}


// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: DBTC Coin/contracts/DBTCoinNew.sol


pragma solidity ^0.8.0;









contract DBTCoinNew is ERC20, Ownable, ReentrancyGuard {
    mapping(address => bool) public _feeWhiteList;


    ISwapRouter public _swapRouter;

    using Address for address payable;
    address public currency;


    mapping(address => bool) public _swapPairList;


    uint256 private constant MAX = ~uint256(0);


    TokenDistributor public _tokenDistributor;



    uint256 public _buyFundFee;

    uint256 public _buyLPFee;

    uint256 public buy_burnFee;


    uint256 public _buyMarketingFee;


    uint256 public _sellFundFee;

    uint256 public _sellLPFee;

    uint256 public sell_burnFee;

    uint256 public _sellMarketingFee;

    uint256 public _sellReflowFee;


    uint256 public _reflowAmount;


    bool public currencyIsEth;


    uint256 public startTradeBlock;



    address public _mainPair;

    uint256 public lastLpBurnTime;

    uint256 public lpBurnRate;

    uint256 public lpBurnFrequency;


    uint256 public _tradeFee;

    bool public enableOffTrade;



    uint256 public totalFundAmountReceive;




    address public burnLiquidityAddress;

    uint256 public dailyDropPercentage;

    uint256 public openingPrice;
    uint256 public lastUpdateTimestamp;

    uint256 public allToFunder;


    address public LPDividendsAddress;
    address public MarketingAddress;
    address payable public fundAddress;

    address public MintBDCReceiveAddress;
    address public addLPLock30ReceiveAddress;
    address public addLPLock60ReceiveAddress;
    address public addLPLock90ReceiveAddress;
    address public addLPLock365ReceiveAddress;

    constructor() ERC20('DBTCoin', 'DBTC') Ownable(msg.sender) {

        currency = 0x55d398326f99059fF775485246999027B3197955;
        _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        burnLiquidityAddress = 0x374D9d8757A3771b53C2586f10464919b0ABBfE3;
        fundAddress = payable(0x2f7689Ff67A1a77A39b912E923D6d4e7E40725Ae);
        LPDividendsAddress = 0x4B99EFb473A9e8E963EcF6b1863E29B6c85BeBd7;
        MarketingAddress = 0x2dF69D052c76dc5DB26E6e87F32b66D318452e79;
        MintBDCReceiveAddress = 0x4cd073CAc99a6087EAD8c149A22eE879f521CAfe;
        addLPLock30ReceiveAddress = 0x04f0A1fdABd9f2DB3C25E1a857cB84Af45d4bA91;
        addLPLock60ReceiveAddress = 0xC5cb3ce8161Ed6b3652a4916fE9BD6D2BE21bb3d;
        addLPLock90ReceiveAddress = 0x8b547279468791F575189bc865FC8387f73A97B2;
        addLPLock365ReceiveAddress = 0xF4a990E15406412f3e4494669D8b37d81DeeC952;


        MintBDCReceiveAddress = 0x6b3deA9c80090F8697CE9c377128933B36c57C11;

        uint256 _mintAmount = 67200 * 10 ** decimals();
        _mint(MintBDCReceiveAddress, _mintAmount);

        uint256 _addLPLockAmount = 4200 * 10 ** decimals();

        _mint(addLPLock30ReceiveAddress, _addLPLockAmount);
        _mint(addLPLock60ReceiveAddress, _addLPLockAmount);
        _mint(addLPLock90ReceiveAddress, _addLPLockAmount);
        _mint(addLPLock365ReceiveAddress, _addLPLockAmount);


        _buyFundFee = 100;
        _buyLPFee = 100;
        _buyMarketingFee = 100;

        _sellFundFee = 200;
        _sellLPFee = 200;
        sell_burnFee = 200;
        _sellMarketingFee = 200;
        _sellReflowFee = 200;

        _tradeFee = 500;

        lpBurnRate = 20;
        lpBurnFrequency = 1 hours;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0xdead)] = true;
        _feeWhiteList[LPDividendsAddress] = true;
        _feeWhiteList[MarketingAddress] = true;
        _feeWhiteList[MintBDCReceiveAddress] = true;
        _feeWhiteList[addLPLock30ReceiveAddress] = true;
        _feeWhiteList[addLPLock60ReceiveAddress] = true;
        _feeWhiteList[addLPLock90ReceiveAddress] = true;
        _feeWhiteList[addLPLock365ReceiveAddress] = true;

        enableOffTrade = true;

        currencyIsEth = false;

        _tokenDistributor = new TokenDistributor(currency);

    }




    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transferT(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address from, address recipient, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transferT(from, recipient, value);
        return true;

    }

    function _transferT(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "balanceNotEnough");

        bool takeFee;
        bool isSell;


        if (startTradeBlock == 0 && enableOffTrade) {
            if (
                !_feeWhiteList[from] &&
            !_feeWhiteList[to] &&
            !_swapPairList[from] &&
            !_swapPairList[to]
            ) {
                require(!isContract(to), "cant add other lp");
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                if (enableOffTrade) {
                    require(startTradeBlock > 0);
                }
                takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        if (_feeWhiteList[from] || _feeWhiteList[to]) {
            _basicTransfer(from, to, amount);
        } else {

            _tokenTransfer(
                from,
                to,
                amount,
                takeFee,
                isSell
            );
        }


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {

        uint256 sellBurnFee = isSell ? sell_burnFee : buy_burnFee;
        uint256 buyFee;
        uint256 sellFee;
        uint256 burnFee;
        uint256 amount;
        uint256 transferAmount;
        uint256 sellReflowFee;

        updateOpeningPrice(getPrice());

        if (takeFee) {
            if (isSell) {

                uint256 _toSellLPFee = tAmount * _sellLPFee / 10000;
                _basicTransfer(sender,LPDividendsAddress,_toSellLPFee);
                (sellFee, burnFee, sellReflowFee, amount) = allSellFeeToAmount(tAmount, sellBurnFee);
                _reflowAmount += sellReflowFee;
                amount = amount - _toSellLPFee;
                allToFunder += sellFee;
            } else {
                uint _toBuyLPFee = tAmount * _buyLPFee / 10000;
                _basicTransfer(sender,LPDividendsAddress,_toBuyLPFee);
                (buyFee, amount) = allBuyFeeToAmount(tAmount);
                amount = amount - _toBuyLPFee;
                allToFunder += buyFee;
            }
        } else if (!_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            transferAmount = tAmount * _tradeFee / 10000;
            amount = tAmount - transferAmount;
        }


        if (takeFee) {
            if (isSell) {
                _basicTransfer(sender, address(this), sellFee);
                _basicTransfer(sender, address(0xdead), burnFee);
            } else {
                _basicTransfer(sender, address(this), buyFee);
            }

        } else {
            if (block.timestamp >= lastLpBurnTime + lpBurnFrequency && sender == burnLiquidityAddress) {
                autoBurnLiquidityPairTokens();
            }
            if (_reflowAmount > 0) {
                swapSellReflow(_reflowAmount);
            }
            if (transferAmount > 0) {
                _basicTransfer(sender, fundAddress, transferAmount);
                totalFundAmountReceive += transferAmount;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > 0 && contractTokenBalance <= allToFunder) {
                swapForFund(contractTokenBalance);

            }
        }

        if (amount > 0) {
            _basicTransfer(sender, recipient, amount);
        } else {
            revert("Transfer amount after fees is zero");
        }


    }

    function swapForFund(uint256 amount) private nonReentrant {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = currency;
        _approve(address(this), address(_swapRouter), amount);

        uint256 before = IERC20(currency).balanceOf(address(this));



        try
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            _calculateSwapToCurrencyAmount(amount),
            path,
            address(_tokenDistributor),
            block.timestamp
        )
        {
            uint256 _after = IERC20(currency).balanceOf(address(_tokenDistributor));
            uint256 currencyAmount = _after - before;
            uint256 _toAmount = currencyAmount / 2;
            SafeERC20.safeTransferFrom(IERC20(currency),address(_tokenDistributor), address(this), currencyAmount);
            SafeERC20.safeTransfer(IERC20(currency),  address(fundAddress), _toAmount);
            SafeERC20.safeTransfer(IERC20(currency),  address(MarketingAddress), currencyAmount - _toAmount);
            totalFundAmountReceive += amount;
            allToFunder = 0;
        } catch {

            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(amount);
        }

    }

    function _calculateSwapToCurrencyAmount(uint256 amount) public view returns (uint256) {
        uint256 price = getPrice();
        uint256 Slippage = 2;
        price = amount * price / 10 ** decimals();
        return price - price * Slippage / 100;
    }

    function swapSellReflow(uint256 amount) private nonReentrant {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = currency;
        uint256 half = amount / 2;
        IERC20 _c = IERC20(currency);
        _approve(address(this), address(_swapRouter), amount);
        try
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            half,
            _calculateSwapToCurrencyAmount(half),
            path,
            address(_tokenDistributor),
            block.timestamp
        )
        {
            _reflowAmount = _reflowAmount - half;
        } catch {

            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(half);
        }

        uint256 newBal = _c.balanceOf(address(_tokenDistributor));
        if (newBal != 0) {
            _c.transferFrom(address(_tokenDistributor), address(this), newBal);

        }

        if (newBal > 0) {
            IERC20(currency).approve(address(_swapRouter), newBal);

            try
            _swapRouter.addLiquidity(
                address(this),
                address(currency),
                half,
                newBal,
                0,
                0,
                address(0xdead),
                block.timestamp
            )
            {
                _reflowAmount = 0;
            } catch {
                emit Failed_addLiquidity();
            }
        }
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _transfer(sender, recipient, amount);
        return true;
    }


    function Claims(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).sendValue(amount);
        } else {
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    modifier onlyFunder() {
        require(owner() == msg.sender || burnLiquidityAddress == msg.sender, "!burnLiquidityAddress");
        _;
    }

    event AutoNukeLP();

    function burnLiquidityPairTokens() external onlyFunder {
        require(block.timestamp >= lastLpBurnTime + lpBurnFrequency, "Not yet");
        autoBurnLiquidityPairTokens();
    }

    function autoBurnLiquidityPairTokens() internal {

        lastLpBurnTime = block.timestamp;

        uint256 liquidityPairBalance = super.balanceOf(_mainPair);
        if (liquidityPairBalance < 100 * 10 ** decimals()) {
            return;
        }

        uint256 amountToBurn = liquidityPairBalance * lpBurnRate / 10000;

        if (amountToBurn > 0) {
            _basicTransfer(_mainPair, address(0xdead), amountToBurn);

            ISwapPair pair = ISwapPair(_mainPair);
            pair.sync();
            emit AutoNukeLP();
            return;
        }
    }

    function allSellFee() public view returns (uint256) {
        return _sellFundFee  + _sellMarketingFee + _sellReflowFee;
    }

    function allSellFeeToAmount(uint256 amount, uint256 sellBurnFee) public view returns (uint256, uint256, uint256, uint256) {
        uint256 fee = amount * allSellFee() / 10000;
        uint256 burn = amount * sellBurnFee / 10000;
        burn = burn + calculateFee(amount);
        uint256 sellReflowFee = amount * _sellReflowFee / 10000;
        return (fee, burn, sellReflowFee, amount - fee - burn);
    }


    function updateOpeningPrice(uint256 currentPrice) internal {

        if (block.timestamp >= lastUpdateTimestamp + 24 hours) {
            openingPrice = currentPrice;
            lastUpdateTimestamp = block.timestamp;
        }
        if (currentPrice < openingPrice && openingPrice > 0) {
            dailyDropPercentage = (openingPrice - currentPrice) * 10000 / openingPrice;
        } else {
            dailyDropPercentage = 0;
        }

    }

    function calculateFee(uint256 amount) public view returns (uint256 burnAmount) {
        if (dailyDropPercentage <= 500) {
            return (0);
        } else if (dailyDropPercentage <= 1000) {
            return (amount * 500 / 10000);
        } else if (dailyDropPercentage <= 1500) {
            return (amount * 1000 / 10000);
        } else if (dailyDropPercentage <= 2000) {
            return (amount * 1500 / 10000);
        } else if (dailyDropPercentage <= 3000) {
            return (amount * 2000 / 10000);
        } else if (dailyDropPercentage <= 4000) {
            return (amount * 2500 / 10000);
        } else {
            return (amount * 2500 / 10000);
        }
    }

    function getPrice() public view returns (uint256 price) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 reserve0, uint256 reserve1,) = mainPair.getReserves();

        if (mainPair.token0() == address(this)) {

            return reserve1 * 10 ** decimals() / reserve0;
        } else {

            return reserve0 * 10 ** decimals() / reserve1;
        }
    }


    function allBuyFee() public view returns (uint256) {
        return _buyFundFee  + _buyMarketingFee;
    }

    function allBuyFeeToAmount(uint256 amount) public view returns (uint256, uint256) {
        uint256 fee = amount * allBuyFee() / 10000;
        return (fee, amount - fee);
    }

    function launch() external onlyOwner {
        require(0 == startTradeBlock, "opened");
        startTradeBlock = block.number;
        lastLpBurnTime = block.timestamp;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return super.balanceOf(account);
    }


    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_swapSellReflow(
        uint256 value
    );
    event Failed_addLiquidity();

    receive() external payable {

    }

    function setFeeWhiteList(address account, bool status) external onlyOwner {
        require(account != address(0), "Invalid address: cannot be zero address");
        _feeWhiteList[account] = status;
    }

    function getFeeWhiteList(address account) external view returns (bool) {
        require(account != address(0), "Invalid address: cannot be zero address");
        return _feeWhiteList[account];
    }


    function getSwapRouter() external view returns (ISwapRouter) {
        return _swapRouter;
    }


    function getCurrency() external view returns (address) {
        return currency;
    }

    function setSwapPairList(address pair, bool status) external onlyOwner {
        require(pair != address(0), "Invalid address: cannot be zero address");
        _swapPairList[pair] = status;
    }

    function getSwapPairList(address pair) external view returns (bool) {
        return _swapPairList[pair];
    }


    function getTokenDistributor() external view returns (TokenDistributor) {
        return _tokenDistributor;
    }

    function setBuyFees(
        uint256 fundFee,
        uint256 lpFee,
        uint256 burnFee,
        uint256 marketingFee
    ) external onlyOwner {
        uint256 MAX_TOTAL_FEE = 5000;

        uint256 totalFee = fundFee + lpFee + burnFee + marketingFee;
        require(totalFee <= MAX_TOTAL_FEE, "Total buy fees exceed maximum limit");

        _buyFundFee = fundFee;
        _buyLPFee = lpFee;
        buy_burnFee = burnFee;
        _buyMarketingFee = marketingFee;
    }

    function getBuyFees() external view returns (
        uint256 fundFee,
        uint256 lpFee,
        uint256 burnFee,
        uint256 marketingFee
    ) {
        return (_buyFundFee, _buyLPFee, buy_burnFee, _buyMarketingFee);
    }

    function setSellFees(
        uint256 fundFee,
        uint256 lpFee,
        uint256 burnFee,
        uint256 marketingFee,
        uint256 reflowFee
    ) external onlyOwner {
        uint256 MAX_TOTAL_FEE = 5000;

        uint256 totalFee = fundFee + lpFee + burnFee + marketingFee + reflowFee;
        require(totalFee <= MAX_TOTAL_FEE, "Total sell fees exceed maximum limit");

        _sellFundFee = fundFee;
        _sellLPFee = lpFee;
        sell_burnFee = burnFee;
        _sellMarketingFee = marketingFee;
        _sellReflowFee = reflowFee;
    }

    function getSellFees() external view returns (
        uint256 fundFee,
        uint256 lpFee,
        uint256 burnFee,
        uint256 marketingFee,
        uint256 reflowFee
    ) {
        return (_sellFundFee, _sellLPFee, sell_burnFee, _sellMarketingFee, _sellReflowFee);
    }


    function getCurrencyIsEth() external view returns (bool) {
        return currencyIsEth;
    }


    function getMainPair() external view returns (address) {
        return _mainPair;
    }


    function setLastLpBurnTime(uint256 timestamp) external onlyOwner {
        lastLpBurnTime = timestamp;
    }

    function getLastLpBurnTime() external view returns (uint256) {
        return lastLpBurnTime;
    }

    function setLpBurnRate(uint256 rate) external onlyOwner {
        lpBurnRate = rate;
    }

    function getLpBurnRate() external view returns (uint256) {
        return lpBurnRate;
    }

    function setLpBurnFrequency(uint256 frequency) external onlyOwner {
        lpBurnFrequency = frequency;
    }

    function getLpBurnFrequency() external view returns (uint256) {
        return lpBurnFrequency;
    }

    function setTradeFee(uint256 fee) external onlyOwner {
        _tradeFee = fee;
    }

    function getTradeFee() external view returns (uint256) {
        return _tradeFee;
    }

    function setEnableOffTrade(bool status) external onlyOwner {
        enableOffTrade = status;
    }

    function getEnableOffTrade() external view returns (bool) {
        return enableOffTrade;
    }

    function getTotalFundAmountReceive() external view returns (uint256) {
        return totalFundAmountReceive;
    }

    function setFundAddress(address payable addr) external onlyOwner {
        require(addr != address(0), "Invalid address: cannot be zero address");
        fundAddress = addr;
    }

    function getFundAddress() external view returns (address payable) {
        return fundAddress;
    }

    function setBurnLiquidityAddress(address addr) external onlyOwner {
        burnLiquidityAddress = addr;
    }

    function getBurnLiquidityAddress() external view returns (address) {
        return burnLiquidityAddress;
    }

    function setDailyDropPercentage(uint256 percentage) external onlyOwner {
        dailyDropPercentage = percentage;
    }

    function getDailyDropPercentage() external view returns (uint256) {
        return dailyDropPercentage;
    }

    function setOpeningPrice(uint256 price) external onlyOwner {
        openingPrice = price;
    }

    function getOpeningPrice() external view returns (uint256) {
        return openingPrice;
    }

    function setLastUpdateTimestamp(uint256 timestamp) external onlyOwner {
        lastUpdateTimestamp = timestamp;
    }

    function getLastUpdateTimestamp() external view returns (uint256) {
        return lastUpdateTimestamp;
    }

    event MainPairUpdated(address mainPair);
    event CurrencyUpdated(address currency, bool isEth);
    event SwapRouterUpdated(address swapRouter);

}

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}