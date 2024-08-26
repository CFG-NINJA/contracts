
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

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys a `value` amount of tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
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

// File: Slurmium/contract_0x3cf585A1DBa0D63017d717264a89d1bB5f6DbEd9/contracts/slurmiumufo.sol


pragma solidity ^0.8.26;





contract SlurmiumTokenBEP20 is ERC20Burnable, Ownable, ReentrancyGuard {
    using Address for address;

    // Constants
    uint256 private constant DIVIDEND_POOL_ALLOCATION = 6; // 6% of total supply
    uint256 private constant STAKING_POOL_ALLOCATION = 9; // 9% of total supply
    uint256 private constant TEAM_WALLET_ALLOCATION = 10; // 10% of total supply
    uint256 private constant RESERVE_FUND_ALLOCATION = 10; // 10% of total supply
    uint256 private constant BURN_POOL_ALLOCATION = 10; // 10% of total supply for burn pool
    uint256 private constant TEAM_VESTING_DURATION = 62_208_000; // 2 years (24 months)
    uint256 private constant TEAM_VESTING_CLIFF = 15_552_000; // 6 months cliff before vesting starts
    uint256 private constant TEAM_VESTING_MONTHLY_RELEASE = 4.2 * 10**16; // 4.2% monthly (with 18 decimals for precision)
    uint256 private constant RESERVE_VESTING_DURATION = 155_520_000; // 5 years (60 months)
    uint256 private constant RESERVE_VESTING_CLIFF = 15_552_000; // 6 months cliff before vesting starts
    uint256 private constant RESERVE_VESTING_MONTHLY_RELEASE = 2 * 10**16; // 2% monthly (with 18 decimals for precision)
    uint256 private constant INITIAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens, 18 decimals

    uint256 public dividendPool;
    uint256 public stakingPoolRewards;
    uint256 public burnPool;

    address public teamWallet;
    address public reserveFund;

    uint256 private teamVestingStartTime;
    uint256 private teamVestingReleasedAmount;

    uint256 private reserveVestingStartTime;
    uint256 private reserveVestingReleasedAmount;

    address public constant DEAD_WALLET = address(0xdead);

    bool public paused;

    struct Commit {
        bytes32 commitHash;
        uint256 timestamp;
        bool revealed;
    }

    mapping(uint256 => Commit) public commits;
    uint256 public commitCounter;
    uint256 public commitRevealTimeLimit = 1 days;

    event CommitMade(uint256 indexed commitId, bytes32 commitHash);
    event RevealMade(uint256 indexed commitId, address destination, uint256 value, bytes data);

    constructor(
        address[] memory _owners,
        uint256 _numConfirmationsRequired,
        address _teamWallet,
        address _reserveFund
    ) ERC20("Slurmium", "SLURM") Ownable(_msgSender()) {
        require(_owners.length > 0, "Owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid number of required confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;

        _mint(_msgSender(), INITIAL_SUPPLY);

        dividendPool = (INITIAL_SUPPLY * DIVIDEND_POOL_ALLOCATION) / 100;
        stakingPoolRewards = (INITIAL_SUPPLY * STAKING_POOL_ALLOCATION) / 100;
        burnPool = (INITIAL_SUPPLY * BURN_POOL_ALLOCATION) / 100;

        teamWallet = _teamWallet;
        reserveFund = _reserveFund;

        teamVestingStartTime = block.timestamp;
        reserveVestingStartTime = block.timestamp;

        _mint(address(this), dividendPool + stakingPoolRewards + burnPool);
        _mint(teamWallet, (INITIAL_SUPPLY * TEAM_WALLET_ALLOCATION) / 100);
        _mint(reserveFund, (INITIAL_SUPPLY * RESERVE_FUND_ALLOCATION) / 100);
    }

    // Function to make a commit with storage optimization
    function commitTransaction(bytes32 _commitHash) external {
        commits[commitCounter] = Commit({
            commitHash: _commitHash,
            timestamp: block.timestamp,
            revealed: false
        });
        emit CommitMade(commitCounter, _commitHash);
        commitCounter++;
    }

    // Function to reveal the transaction details with storage cleanup
    function revealTransaction(
        uint256 _commitId,
        address _destination,
        uint256 _value,
        bytes memory _data,
        bytes32 _nonce
    ) external {
        require(_commitId < commitCounter, "Invalid commit ID");
        Commit storage userCommit = commits[_commitId];
        require(!userCommit.revealed, "Transaction already revealed");

        // Ensure reveal occurs within the time window
        require(block.timestamp >= userCommit.timestamp, "Cannot reveal too early");
        require(block.timestamp <= userCommit.timestamp + commitRevealTimeLimit, "Reveal period expired");

        // Ensure the hash matches the committed hash and include a strong nonce
        bytes32 hashCheck = keccak256(abi.encodePacked(_destination, _value, _data, _nonce));
        require(userCommit.commitHash == hashCheck, "Commit-reveal mismatch");

        // Mark as revealed before proceeding to prevent replay attacks
        userCommit.revealed = true;

        // Execute the transaction logic
        (bool success, ) = _destination.call{value: _value}(_data);
        require(success, "Transaction failed");

        emit RevealMade(_commitId, _destination, _value, _data);

        // Clean up storage after revealing
        delete commits[_commitId];
    }

    // A helper function to generate the commit hash off-chain with optimized input
    function generateCommitHash(
        address _destination,
        uint256 _value,
        bytes memory _data,
        bytes32 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_destination, _value, _data, _nonce));
    }

    // Function to delete a commit after the reveal time limit has expired to optimize storage
    function deleteExpiredCommit(uint256 _commitId) external onlyOwner {
        require(_commitId < commitCounter, "Invalid commit ID");
        Commit storage userCommit = commits[_commitId];
        require(!userCommit.revealed, "Transaction already revealed");
        require(block.timestamp > userCommit.timestamp + commitRevealTimeLimit, "Reveal period has not expired");

        delete commits[_commitId];
    }

    // Function to burn tokens from the burn pool
    function burnFromPool(uint256 amount) external onlyOwner {
        require(amount <= burnPool, "Insufficient burn pool balance");

        burnPool -= amount;
        _transfer(address(this), DEAD_WALLET, amount);
    }

    // Override to block transfers from the Burn Pool for any other purpose
    function customTransfer(address sender, address recipient, uint256 amount) public nonReentrant onlyOwner {
        if (sender == address(this)) {
            require(recipient == teamWallet || recipient == reserveFund || recipient == DEAD_WALLET, "Locked tokens, cannot be transferred");
        }
        _transfer(sender, recipient, amount); // Chiamata alla funzione _transfer di ERC20 senza eseguire l'override
    }

    // Vesting function for the Team Wallet
    function releaseTeamVestedTokens() external onlyOwner {
        require(block.timestamp >= teamVestingStartTime + TEAM_VESTING_CLIFF, "Vesting period not started");

        uint256 monthsPassed = (block.timestamp - teamVestingStartTime) / 30 days;
        uint256 totalVestedAmount = (INITIAL_SUPPLY * TEAM_WALLET_ALLOCATION / 100) * monthsPassed * TEAM_VESTING_MONTHLY_RELEASE / 10**18;

        uint256 unreleased = totalVestedAmount - teamVestingReleasedAmount;
        require(unreleased > 0, "No tokens to release");

        teamVestingReleasedAmount += unreleased;
        _transfer(address(this), teamWallet, unreleased);
    }

    // Vesting function for the Reserve Fund
    function releaseReserveVestedTokens() external onlyOwner {
        require(block.timestamp >= reserveVestingStartTime + RESERVE_VESTING_CLIFF, "Vesting period not started");

        uint256 monthsPassed = (block.timestamp - reserveVestingStartTime) / 30 days;
        uint256 totalVestedAmount = (INITIAL_SUPPLY * RESERVE_FUND_ALLOCATION / 100) * monthsPassed * RESERVE_VESTING_MONTHLY_RELEASE / 10**18;

        uint256 unreleased = totalVestedAmount - reserveVestingReleasedAmount;
        require(unreleased > 0, "No tokens to release");

        reserveVestingReleasedAmount += unreleased;
        _transfer(address(this), reserveFund, unreleased);
    }

    // Multi-signature functionality
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public numConfirmationsRequired;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);

        if (transaction.numConfirmations >= numConfirmationsRequired) {
            _executeTransaction(_txIndex);
        }
    }


    // Multi-signature variables and other functionalities

    
    // Multi-signature variables


   

    event SubmitTransaction(address indexed owner, uint256 indexed txIndex, address indexed destination, uint256 value, bytes data);
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    uint256 private _initialSupply = 1_000_000_000 * 10**18; // 1 billion tokens, 18 decimals
    uint256 public burnRate = 1; // Burn rate percentage (1%)
    uint256 public rewardRate = 1; // Redistribution rate percentage (1%)
    uint256 public ownerShareRate = 1; // Owner's share rate percentage (1%)
    uint256 public transferDelay = 1 minutes; // Delay between transfers of an address
    uint256 public dailyInterestRate = 0.01 * 10**18; // 0.01% daily interest rate (10^18 for precision)
    uint256 public constant SECONDS_IN_DAY = 86400; // Number of seconds in a day
    uint256 public rewardDistributionInterval = 30 days; // Interval for reward distribution

    uint256 public maxWalletAmount = 5_000_000 * 10**18; // Maximum token limit per wallet (5 million)
    uint256 public maxTransferAmount = 1_000_000 * 10**18; // Maximum token limit per transfer (1 million)
    uint256 public maxSellAmount = 500_000 * 10**18; // Maximum sellable token amount (500,000 tokens)
    uint256 public sellInterval = 1 hours; // Interval to limit sales

    uint256 public minimumTokenForEligibility = 60_000 * 10**18; // 60,000 tokens

    mapping(address => bool) private _eligibleForRewards;
    mapping(address => bool) private _hasBeenDrawn; // Mapping to check if an address has been drawn
    address[] private _eligibleAddresses;

    mapping(address => uint256) private _lastSellTimestamp;
    mapping(address => uint256) private _lastSellAmount;

    uint256 private _lastRewardDistribution;

    // Linked List for Transaction Mixing
    struct TransactionMixing {
        address recipient;
        uint256 amount;
        bool processed; // Mark if the transaction has been processed
    }

    uint256 private _mixingHead;
    uint256 private _mixingTail;
    uint256 private _mixingCount;
    mapping(uint256 => TransactionMixing) private _pendingTransactions;

    uint256 private _mixingThreshold = 100_000 * 10**18; // Threshold to activate mixing (100,000 tokens)
    uint256 private _mixingRounds = 3; // Number of mixing rounds

    mapping(address => bool) private _isExcludedFromTax;
    mapping(address => uint256) private _lastTransferTimestamp;

    mapping(address => bool) private _knownBEP20Addresses; // Mapping for known BEP20 addresses
    event TokensMixed(address indexed recipient, uint256 amount);
    event DividendsDistributed(address indexed recipient, uint256 amount);

    // Staking Variables
    uint256 public constant MINIMUM_STAKE_AMOUNT = 60_000 * 10**18; // 60,000 token
    uint256 public annualPercentageYield = 15 * 10**16; // 15% annual with 18 decimals for precision
    uint256 public constant SECONDS_IN_YEAR = 31536000; // Number of seconds in a year (365 days)

    mapping(address => uint256) private _stakedAmounts;
    mapping(address => uint256) private _lastClaimTimestamp;
    mapping(address => bool) private _isEligibleForDividends;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);

     // Purchase Tax Variables
    uint256 public purchaseTaxRate = 3; // 3% total purchase tax (1% owner, 1% stake pool, 1% dividend pool)

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "Tx already confirmed");
        _;
    }

    // Modifier to check if the contract is not paused
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // Function to pause the contract
    function pause() external onlyOwner {
        paused = true;
    }

    // Function to unpause the contract
    function unpause() external onlyOwner {
        paused = false;
    }

    // Commit-Reveal mechanism for front-running protection
    function commitTransaction(uint256 _txIndex, bytes32 _commitHash) public onlyOwner {
        require(commits[_txIndex].commitHash == 0, "Transaction already committed");
        commits[_txIndex] = Commit({
            commitHash: _commitHash,
            timestamp: block.timestamp, // Necessary
            revealed: false
        });
    }

    function revealTransaction(uint256 _txIndex, address _destination, uint256 _value, bytes memory _data) 
        public 
        onlyOwner 
    {
        require(commits[_txIndex].commitHash != 0, "No commit found for this transaction");
        require(!commits[_txIndex].revealed, "Transaction already revealed");

        // Ensure the hash matches
        bytes32 hashCheck = keccak256(abi.encodePacked(_destination, _value, _data));
        require(commits[_txIndex].commitHash == hashCheck, "Commit-reveal mismatch");

        commits[_txIndex].revealed = true;

        // Execute the transaction or further process it as needed
        submitTransaction(_destination, _value, _data);
    }

  // Modified submitTransaction function
function submitTransaction(address _destination, uint256 _value, bytes memory _data)
    public
    whenNotPaused
    onlyOwner
{
    uint256 txIndex = transactions.length;

    transactions.push(
        Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        })
    );

    emit SubmitTransaction(msg.sender, txIndex, _destination, _value, _data);
} // <- Chiusura corretta della funzione submitTransaction

// Function to execute a transaction
function _executeTransaction(uint256 _txIndex) internal txExists(_txIndex) notExecuted(_txIndex) {
    Transaction storage transaction = transactions[_txIndex];

    require(transaction.numConfirmations >= numConfirmationsRequired, "Cannot execute transaction");

    transaction.executed = true;

    (bool success, ) = transaction.destination.call{value: transaction.value}(transaction.data);
    require(success, "Tx failed");

    emit ExecuteTransaction(msg.sender, _txIndex);
} // <- Chiusura corretta della funzione _executeTransaction


    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        require(isConfirmed[_txIndex][msg.sender], "Tx not confirmed");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        require(block.timestamp >= _lastTransferTimestamp[_msgSender()] + transferDelay, "Transfer delay not met");
        require(amount <= maxTransferAmount, "Transfer amount exceeds limit");

        if (recipient == address(this)) {
            require(amount <= maxSellAmount, "Sell amount exceeds limit");
            require(block.timestamp >= _lastSellTimestamp[_msgSender()] + sellInterval, "Sell interval not met");

            _lastSellTimestamp[_msgSender()] = block.timestamp;
            _lastSellAmount[_msgSender()] = amount;
        }

        uint256 burnAmount = (amount * burnRate) / 100;
        if (_isExcludedFromTax[_msgSender()] || _isExcludedFromTax[recipient]) {
            super._transfer(_msgSender(), recipient, amount);
        } else if (isPurchase(_msgSender())) {
            // Apply purchase tax
            uint256 taxAmount = amount * purchaseTaxRate / 100;

            uint256 ownerShare = taxAmount / 3; // 1%
            uint256 stakePoolShare = taxAmount / 3; // 1%
            uint256 dividendPoolShare = taxAmount - ownerShare - stakePoolShare; // 1%

            // Distribute shares
            super._transfer(_msgSender(), owner(), ownerShare);
            stakingPoolRewards += stakePoolShare;
            dividendPool += dividendPoolShare;

            uint256 finalTransferAmount = amount - taxAmount;
            super._transfer(_msgSender(), recipient, finalTransferAmount);
        } else {
            uint256 taxAmount;
            uint256 dividendAmount;
            uint256 ownerShareAmount;
            uint256 stakingAmount;

            unchecked {
                if (block.timestamp <= _lastTransferTimestamp[_msgSender()] + 1 hours) {
                    taxAmount = (amount * 15) / 100;
                    dividendAmount = (taxAmount * 75) / 1000;
                    ownerShareAmount = (taxAmount * 325) / 1500;
                    stakingAmount = (taxAmount * 425) / 1500; 

                } else if (block.timestamp <= _lastTransferTimestamp[_msgSender()] + 1 days) {
                    taxAmount = (amount * 7) / 100;
                    dividendAmount = (taxAmount * 3) / 7;
                    ownerShareAmount = (taxAmount * 1) / 7;
                    stakingAmount = (taxAmount * 3) / 7;
                } else if (block.timestamp <= _lastTransferTimestamp[_msgSender()] + 2 weeks) {
                    taxAmount = (amount * 5) / 100;
                    dividendAmount = (taxAmount * 3) / 5;
                    stakingAmount = (taxAmount * 2) / 5;
                } else {
                    dividendAmount = 0;
                    ownerShareAmount = 0;
                    stakingAmount = 0;
                }
            }

            uint256 finalTransferAmount = amount - taxAmount;

            super._transfer(_msgSender(), address(this), finalTransferAmount);
            super._transfer(_msgSender(), address(0), burnAmount);
            super._transfer(_msgSender(), owner(), ownerShareAmount);

            dividendPool += dividendAmount;
            stakingPoolRewards += stakingAmount;
        }

        _lastTransferTimestamp[_msgSender()] = block.timestamp;

        require(balanceOf(recipient) <= maxWalletAmount, "Recipient balance exceeds wallet limit");

        return true;
    }

    function addMixingTransaction(address recipient, uint256 amount) external onlyOwner nonReentrant {
        require(amount >= _mixingThreshold, "Amount below mixing threshold");

        uint256 newTransactionIndex = _mixingCount;
        _pendingTransactions[newTransactionIndex] = TransactionMixing({
            recipient: recipient,
            amount: amount,
            processed: false
        });

        if (_mixingHead == 0) {
            _mixingHead = newTransactionIndex;
            _mixingTail = newTransactionIndex;
        } else {
            _pendingTransactions[_mixingTail].processed = true; // Mark as processed when moving to next
            _mixingTail = newTransactionIndex;
        }

        _mixingCount++;
    }

    function _performMixing(uint256 batchSize) external nonReentrant onlyOwner {
        require(_mixingHead != 0, "No transactions to process");

        uint256 processed = 0;
        uint256 current = _mixingHead;

        while (current < _mixingCount && processed < batchSize) {
            TransactionMixing storage txn = _pendingTransactions[current];

            if (!txn.processed) {
                if (balanceOf(address(this)) >= txn.amount) {
                    // Transfer using a memory-based variable
                    _transferMemory(address(this), txn.recipient, txn.amount);
                    emit TokensMixed(txn.recipient, txn.amount);
                }
                txn.processed = true; // Mark as processed
            }

            processed++;
            current++;
        }

        // Clear the list in one operation after processing
        if (processed == _mixingCount) {
            _clearMixingTransactions();
        }
    }

    function _clearMixingTransactions() internal {
        // Reset the mixing pointers
        _mixingHead = 0;
        _mixingTail = 0;
        _mixingCount = 0;
    }

    function _transferMemory(address sender, address recipient, uint256 amount) internal    nonReentrant {
        // Assuming a memory-based transfer operation for illustration.
        // This would actually involve standard ERC20 transfer logic.
        super._transfer(sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    function distributeDividends() external onlyOwner nonReentrant {
        uint256 totalSupplySnapshot = totalSupply();
        uint256 totalDividendPool = dividendPool;

        // Calculate the portion of the pool to be distributed (30% of the total)
        uint256 distributionAmount = totalDividendPool * 30 / 100;
        uint256 remainingPool = totalDividendPool - distributionAmount;

        // Batch size to process addresses in blocks
        uint256 batchSize = gasleft() / 10000;
        uint256 batches = (_eligibleAddresses.length + batchSize - 1) / batchSize;

        for (uint256 batch = 0; batch < batches; batch++) {
            uint256 startIdx = batch * batchSize;
            uint256 endIdx = startIdx + batchSize;
            if (endIdx > _eligibleAddresses.length) {
                endIdx = _eligibleAddresses.length;
            }

            for (uint256 i = startIdx; i < endIdx; i++) {
                address account = _eligibleAddresses[i];
                if (balanceOf(account) >= minimumTokenForEligibility) {
                    uint256 eligibleBalance = balanceOf(account);

                    // Calculate the user's dividend based on the eligible balance
                    uint256 dividend = (distributionAmount * eligibleBalance) / totalSupplySnapshot;

                    if (dividend > 0) {
                        super._transfer(address(this), account, dividend);
                        emit DividendsDistributed(account, dividend);
                    }
                }
            }
        }

        // Update the dividend pool with the remaining undistributed portion
        dividendPool = remainingPool;

        _lastRewardDistribution = block.timestamp;
    }

    function excludeFromTax(address account) external onlyOwner {
        _isExcludedFromTax[account] = true;
    }

    function includeInTax(address account) external onlyOwner {
        _isExcludedFromTax[account] = false;
    }

    function setBurnRate(uint256 newBurnRate) external onlyOwner {
        burnRate = newBurnRate;
    }

    function setRewardRate(uint256 newRewardRate) external onlyOwner {
        rewardRate = newRewardRate;
    }

    function setOwnerShareRate(uint256 newOwnerShareRate) external onlyOwner {
        ownerShareRate = newOwnerShareRate;
    }

    function setMaxAmounts(uint256 newMaxWalletAmount, uint256 newMaxTransferAmount) external onlyOwner {
        maxWalletAmount = newMaxWalletAmount;
        maxTransferAmount = newMaxTransferAmount;
    }

    function setAntiDumpParams(uint256 newMaxSellAmount, uint256 newSellInterval) external onlyOwner {
        maxSellAmount = newMaxSellAmount;
        sellInterval = newSellInterval;
    }

    function setMinimumTokenForEligibility(uint256 newMinimumTokenForEligibility) external onlyOwner {
        minimumTokenForEligibility = newMinimumTokenForEligibility;
    }

    function setTransferDelay(uint256 newTransferDelay) external onlyOwner {
        transferDelay = newTransferDelay;
    }

    function setDailyInterestRate(uint256 newDailyInterestRate) external onlyOwner {
        dailyInterestRate = newDailyInterestRate;
    }

    function setRewardDistributionInterval(uint256 newInterval) external onlyOwner {
        rewardDistributionInterval = newInterval;
    }

    function setMixingThreshold(uint256 newMixingThreshold) external onlyOwner {
        _mixingThreshold = newMixingThreshold;
    }

    function setMixingRounds(uint256 newMixingRounds) external onlyOwner {
        _mixingRounds = newMixingRounds;
    }

    function addEligibleAddress(address account) external onlyOwner {
        _eligibleForRewards[account] = true;
        _eligibleAddresses.push(account);
    }

    function removeEligibleAddress(address account) external onlyOwner {
        _eligibleForRewards[account] = false;
        for (uint256 i = 0; i < _eligibleAddresses.length; i++) {
            if (_eligibleAddresses[i] == account) {
                _eligibleAddresses[i] = _eligibleAddresses[_eligibleAddresses.length - 1];
                _eligibleAddresses.pop();
                break;
            }
        }
    }

    // Staking Functions
    function stake(uint256 amount) external     nonReentrant {
        require(amount >= MINIMUM_STAKE_AMOUNT, "Amount must be at least 60,000 tokens");
        
        // Update rewards before modifying staking
        _updateRewards(msg.sender);

        _transfer(msg.sender, address(this), amount);
        _stakedAmounts[msg.sender] += amount;
        _lastClaimTimestamp[msg.sender] = block.timestamp;
        _isEligibleForDividends[msg.sender] = true;

        emit Staked(msg.sender, amount);
    }

    function claimRewards() external     nonReentrant {
        _updateRewards(msg.sender);

        uint256 reward = _calculateReward(msg.sender);
        require(reward > 0, "No rewards available to claim");

        _lastClaimTimestamp[msg.sender] = block.timestamp;
        _mint(msg.sender, reward);

        emit Claimed(msg.sender, reward);
    }

    function unstake(uint256 amount) external     nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(_stakedAmounts[msg.sender] >= amount, "Not enough staked");

        _updateRewards(msg.sender);

        _stakedAmounts[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);

        if (_stakedAmounts[msg.sender] < MINIMUM_STAKE_AMOUNT) {
            _isEligibleForDividends[msg.sender] = false;
        }

        emit Unstaked(msg.sender, amount);
    }

    function _calculateReward(address user) internal view returns (uint256) {
        uint256 stakedAmount = _stakedAmounts[user];
        uint256 timeStaked = block.timestamp - _lastClaimTimestamp[user];

        uint256 reward = stakedAmount
            * annualPercentageYield
            * timeStaked
            / SECONDS_IN_YEAR
            / 10**18;

        return reward;
    }

    function _updateRewards(address user) internal {
        uint256 reward = _calculateReward(user);
        if (reward > 0) {
            _mint(user, reward);
            emit Claimed(user, reward);
        }
        _lastClaimTimestamp[user] = block.timestamp;
    }

    function getStakedAmount(address user) external view returns (uint256) {
        return _stakedAmounts[user];
    }

    function getLastClaimTimestamp(address user) external view returns (uint256) {
        return _lastClaimTimestamp[user];
    }

    function isEligibleForDividends(address user) external view returns (bool) {
        return _isEligibleForDividends[user];
    }

    // Function to determine if the sender is making a purchase
    function isPurchase(address sender) internal view returns (bool) {
        return _knownBEP20Addresses[sender];
    }

    // Function to update purchase tax rate
    function setPurchaseTaxRate(uint256 newRate) external onlyOwner {
        require(newRate <= 10, "Purchase tax rate too high"); // Limit purchase tax rate to a maximum of 10%
        purchaseTaxRate = newRate;
    }

    // Function to manage known BEP20 addresses
    function setKnownBEP20Address(address _address, bool _isKnown) external onlyOwner {
        _knownBEP20Addresses[_address] = _isKnown;
    }
}
