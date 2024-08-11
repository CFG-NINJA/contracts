// SPDX-License-Identifier: MIT
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

// File: contracts/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

// import {IERC20} from "../IERC20.sol";


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

// File: contracts/Context.sol


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

// File: contracts/ERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;


// import "@openzeppelin/contracts/utils/Context.sol";


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// File: contracts/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}
// File: contracts/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// File: contracts/SafeTransferLib.sol


pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// File: contracts/BTFToken.sol


pragma solidity 0.8.20;






// Binding coin is used to bind the relationship between superiors and subordinates
contract BtfToken is ERC20, Ownable, ERC20Burnable {
    KingContract public kingContract;
    mapping(address => address[]) private priInviteRecords;
    mapping(address => address) private priParents;
    mapping(address => uint256) private priInviteNumRecords;

    mapping(address => address[]) private inviteRecords;
    mapping(address => address) private parents;
    mapping(address => uint256) private inviteNumRecords;

    bool public pp = true;

    constructor() ERC20("BindToken", "BTK003") {
        uint256 totalSupply = 100_000_000_000 * 1e18;
        _mint(msg.sender, totalSupply);
    }

    function updateKingAddress(address kingcontract) public {
        kingContract = KingContract(kingcontract);
    }

    // Invite user events
    event invteUser(address user, address invite);

    // Binding parent events
    event bindParent(address user, address parent);

    function getInviteParent(address myAddress)
        public
        view
        returns (address parent)
    {
        return parents[myAddress];
    }
}

// File: contracts/KingContract.sol


pragma solidity 0.8.20;




contract KingContract is Ownable {
  struct User {
    address me;
    uint256 minePower;
    uint256 pushPower;
    uint256 pushNumber;
    address teamLeader;
    uint256 teamPower;
    uint256 mincome;
    uint256 dincome;
    uint256 sell;
    uint256 padding;
  }

  struct PPriWet {
    uint256 gnwet;
    uint256 gmwet;
    uint256 snwet;
    uint256 enwet;
  }

  struct UPower {
    address account;
    uint256 power;
    uint256 pushPower;
    uint256 teamPower;
  }

  struct Rank {
    address account;
    uint256 power;
  }

  BtfToken private btfContract;
  address private constant zeroAddress = address(0);
  uint256 private price;
  address private ktoken;
  address private btoken;
  mapping(address => PPriWet) public pweis;
  mapping(address => User) public users;
  address[] private ukeys;
  // 9%
  address[] private funds;
  // 4%
  address[] private tteam;
  // 8%
  address[] private genesisNode;
  // 3%
  address[] private genesisMedal;
  // 5%
  address[] private eliteNode;
  // 2%
  address[] private superNode;
  // 2%
  address[] private marketTycoon;
  // 9%
  address[] private federatedNode;
  //  35%
  // address[] private directPush;
  // 10%
  Rank[] private bronzeAward;
  Rank[] private tmpBronzeAward; // Temporary storage
  // 7%
  Rank[] private silverAward;
  Rank[] private tmpSilverAward; // Temporary storage
  // 6%
  Rank[] private goldAward;
  Rank[] private tmpGoldAward; // Temporary storage
  Rank[] private teamDaily;

  // uint256 totalUsers;
  uint256 private totalPower;
  uint256 private pushPower;
  uint256 private dailyPower;
  uint256 private maxDailyPower;
  uint256 private totalMiningPool;
  uint256 private dividendPool;
  uint256 private times;
  uint256 private day;
  uint256 private daypp;
  uint256 private basePower;
  uint256 private minInvAmount;
  bool private limitSell;
  uint256 private destoryAmount;

  event ore(address account, uint256 amount);
  event nextOre(bool next);
  event divCoin(address account, uint256 amount, uint256 dtype);
  event nextPushCoin(bool next);
  event nextIncome(bool next);

  constructor() {
    maxDailyPower = 6 * 1e6;
    totalMiningPool = 19600 * 1e18;
    dividendPool = 8400 * 1e18;
    times = 1;
    day = 1;
    daypp = 40;
    totalPower = 0;
    pushPower = 0;
    basePower = 1 * 1e3;
    minInvAmount = 150000;
    limitSell = false;
  }

  function getPrice() public view returns (uint256) {
    return price;
  }


  function getTimes() public view returns (uint256) {
    return times;
  }

  function updateDay(uint256 newDay) public onlyOwner {
    day = newDay;
  }

  // 19600 / (2^n) / 40
  function outputToken() public view returns (uint256) {
    return totalMiningPool / (2 ** times) / daypp;
  }

  // Number of coins produced per 1T computing power
  function outputTokenByOne() private view returns (uint256) {
    return (totalMiningPool / (2 ** times) / daypp) / totalPower / 1000;
  }

  // 8400 / (2^n) / 40
  function dividendToken() public view returns (uint256) {
    return dividendPool / (2 ** times) / daypp;
  }

  function addSell(address account, uint256 amount) public {
    if (msg.sender == ktoken || msg.sender == owner()) {
      if (users[account].me != zeroAddress) {
        users[account].sell += amount;
      }
    }
  }

  function addPower(address account, uint256 amount) public {
    if (msg.sender == ktoken || msg.sender == owner()) {
      require((dailyPower + amount) < maxDailyPower, 'Max Power');
      uint256 _p = calcBasePower(amount);
      if (users[account].me == zeroAddress) {
        require(amount >= minInvAmount, 'Amount too small');
        totalPower += _p;
        ukeys.push(account);
        users[account] = User(account, _p, 0, 0, account, 0, 0, 0, 0, 0);
      } else {
        users[account].minePower += _p;
        address invaddress = btfContract.getInviteParent(account);
        User memory invite = users[invaddress];
        invite.pushPower += _p;
        pushPower += _p;
        if (invite.pushPower >= 5000) {
          if (!exists(federatedNode, invite.me)) {
            federatedNode.push(invite.me);
          }
        } else if (invite.pushPower >= 50000) {
          if (!exists(marketTycoon, invite.me)) {
            marketTycoon.push(invite.me);
          }
        }
        if (invite.me != invite.teamLeader) {
          users[invite.teamLeader].teamPower += _p;
          addTeamDaily(invite.teamLeader, _p);
          addTmpSA(invite.teamLeader, _p);
          addTmpGA(invite.teamLeader, _p);
        } else {
          invite.teamPower += _p;
          addTeamDaily(invite.me, _p);
          addTmpSA(invite.me, _p);
          addTmpGA(invite.me, _p);
        }
        users[invaddress] = invite;
        addTmpBA(invite.me, invite.pushPower);
      }
      dailyPower += amount;
    }
  }

  function addAccount(address account) public {
    if (msg.sender == btoken || msg.sender == owner()) {
      if (users[account].me == zeroAddress) {
        ukeys.push(account);
        users[account] = User(account, 0, 0, 0, account, 0, 0, 0, 0, 0);
      }
    }
  }

  function updateRelation(address account, address invaddress) public {
    if (msg.sender == btoken || msg.sender == owner()) {
      User memory mine = users[account];
      User memory invite = users[invaddress];
      if (mine.teamLeader != invaddress) {
        mine.teamLeader = invite.teamLeader;
        invite.pushNumber += 1;
        invite.pushPower += mine.minePower;
        pushPower += mine.minePower;
        if (invite.pushPower >= 5000) {
          if (!exists(federatedNode, invite.me)) {
            federatedNode.push(invite.me);
          }
        } else if (invite.pushPower >= 50000) {
          if (!exists(marketTycoon, invite.me)) {
            marketTycoon.push(invite.me);
          }
        }
        if (invite.me != invite.teamLeader) {
          users[invite.teamLeader].teamPower += mine.minePower;

          addTmpSA(invite.teamLeader, mine.minePower);
          addTmpGA(invite.teamLeader, mine.minePower);
        } else {
          invite.teamPower += mine.minePower;
          addTmpSA(invite.me, mine.minePower);
          addTmpGA(invite.me, mine.minePower);
        }
        users[account] = mine;
        users[invaddress] = invite;

        addTmpBA(invite.me, invite.pushPower);
      }
    }
  }

  function addTeamDaily(address account, uint256 power) private {
    bool _f;
    uint256 _i;
    (_f, _i) = indexof(teamDaily, account);
    if (_f) {
      teamDaily[_i].power += power;
    } else {
      teamDaily.push(Rank(account, power));
    }
  }

  function addTmpBA(address account, uint256 power) private {
    bool _f;
    uint256 _i;
    (_f, _i) = indexof(tmpBronzeAward, account);
    if (_f) {
      tmpBronzeAward[_i].power += power;
    } else {
      tmpBronzeAward.push(Rank(account, power));
    }
  }

  function addTmpSA(address account, uint256 power) private {
    bool _exists = exists(genesisNode, account);
    if (_exists) {
      bool _f;
      uint256 _i;
      (_f, _i) = indexof(tmpSilverAward, account);
      if (_f) {
        tmpSilverAward[_i].power += power;
      } else {
        tmpSilverAward.push(Rank(account, power));
      }
    }
  }

  function addTmpGA(address account, uint256 power) private {
    bool _exists = exists(genesisNode, account);
    if (_exists) {
      bool _f;
      uint256 _i;
      (_f, _i) = indexof(tmpGoldAward, account);
      if (_f) {
        tmpGoldAward[_i].power += power;
      } else {
        tmpGoldAward.push(Rank(account, power));
      }
    }
  }

  function calcBasePower(uint256 amount) public view returns (uint256) {
    return ((amount / 3) * (basePower + (25 * (day - 1)))) / 10000;
  }

  function exists(
    address[] memory accounts,
    address one
  ) private pure returns (bool) {
    for (uint8 i = 0; i < accounts.length; i++) {
      if (accounts[i] == one) {
        return true;
      }
    }
    return false;
  }

  function indexof(
    Rank[] memory accounts,
    address one
  ) private pure returns (bool, uint256) {
    for (uint8 i = 0; i < accounts.length; i++) {
      Rank memory elem = accounts[i];
      if (elem.account == one) {
        return (true, i);
      }
    }
    return (false, 0);
  }

  function indexof2(uint8[] memory arr, uint8 one) private pure returns (bool) {
    for (uint8 i = 0; i < arr.length; i++) {
      if (arr[i] == one) {
        return true;
      }
    }
    return false;
  }

  function rankingSort(
    Rank[] memory items
  ) private pure returns (Rank[] memory) {
    for (uint8 i = 1; i < items.length; i++)
      for (uint8 j = 0; j < i; j++)
        if (items[i].power >= items[j].power) {
          Rank memory x = items[i];
          items[i] = items[j];
          items[j] = x;
        }
    return items;
  }
}

// File: contracts/IPancakeFactory.sol

pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: contracts/IPancakePair.sol

pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/IPancakeRouter.sol

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/IPancakeRouter02.sol

pragma solidity >=0.6.2;


interface IPancakeRouter02 is IPancakeRouter01 {
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

// File: contracts/KingToken.sol


pragma solidity ^0.8.20;










contract KingToken is ERC20, Ownable, ERC20Burnable {
  using SafeTransferLib for address payable;

  IPancakeRouter02 public immutable pancakeV2Router;
  address public pancakeV2Pair;
  // Black Hole Address
  address public constant zeroAddress = address(0);
  address public constant deadAddress = address(0xdead);

  bool private swapping;

  // Purchase fee receiving address
  address public buyFeeWallet;
  // Selling fee receiving address
  address public sellFeeWallet;

  // Maximum transaction amount
  uint256 public maxBuyAmount;
  uint256 public maxSellAmount;
  uint256 public swapTokensAtAmount;

  uint256 public reserveOut;

  bool public channel = true;
  bool public limitsInEffect = true;
  bool public tradingActive = false;
  bool public swapEnabled = false;
  bool public stakingEnabled = false;
  // Abandon the blacklist
  bool public blacklistRenounced = false;
  mapping(address => bool) blacklisted;
  mapping(address => bool) channels;

  uint256 public tokensForBuy;
  uint256 public tokensForSell;

  mapping(address => bool) private _isExcludedFromFees;
  mapping(address => bool) public _isExcludedMaxTransactionAmount;

  mapping(address => bool) public automatedMarketMakerPairs;
  bool public preMigrationPhase = true;
  mapping(address => bool) public preMigrationTransferrable;

  KingContract public kingContract;
  uint256 public minWallet;

  event UpdatePancakeV2Router(
    address indexed newAddress,
    address indexed oldAddress
  );

  event ExcludeFromFees(address indexed account, bool isExcluded);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
  event buyFeeWalletUpdated(
    address indexed newWallet,
    address indexed oldWallet
  );
  event sellFeeWalletUpdated(
    address indexed newWallet,
    address indexed oldWallet
  );

  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiquidity
  );

  constructor() ERC20('KingToken', 'KGC') {
    IPancakeRouter02 _pancakeV2Router = IPancakeRouter02(
      0x10ED43C718714eb63d5aA57B78B54704E256024E
    );
    pancakeV2Router = _pancakeV2Router;

    uint256 totalSupply = 31000 * 1e18;
    swapTokensAtAmount = 1 * 1e18;

    reserveOut = 1 * 1e18;

    minWallet = 1 * 1e9;
    // Maximum transaction amount
    maxBuyAmount = 3 * 1e18;
    maxSellAmount = 5 * 1e17;

    excludeFromFees(owner(), true);
    excludeFromFees(address(this), true);

    preMigrationTransferrable[owner()] = true;

    _mint(msg.sender, totalSupply);
  }

  function updatePancakeV2Pair(address token) public {
    pancakeV2Pair = IPancakeFactory(pancakeV2Router.factory()).getPair(
      token,
      address(this)
    );
    _setAutomatedMarketMakerPair(address(pancakeV2Pair), true);
  }

  function updateKingAddress(address kingcontract) public {
    kingContract = KingContract(kingcontract);
  }

  receive() external payable {}

  function enableTrading() external onlyOwner {
    tradingActive = true;
    swapEnabled = true;
    preMigrationPhase = false;
  }

  function enableStaking() external onlyOwner {
    stakingEnabled = true;
  }

  function removeChannel() external onlyOwner {
    channel = false;
  }

  function removeLimits() external onlyOwner returns (bool) {
    limitsInEffect = false;
    return true;
  }

  function updateSwapTokensAtAmount(
    uint256 newAmount
  ) external onlyOwner returns (bool) {
    swapTokensAtAmount = newAmount;
    return true;
  }

  function updateMaxTxnAmount(
    uint256 newBuy,
    uint256 newSell
  ) external onlyOwner {
    maxBuyAmount = newBuy * (10 ** 17);
    maxSellAmount = newSell * (10 ** 17);
  }

  function excludeFromMaxTransaction(
    address updAds,
    bool isEx
  ) public onlyOwner {
    _isExcludedMaxTransactionAmount[updAds] = isEx;
  }

  function updateSwapEnabled(bool enabled) external onlyOwner {
    swapEnabled = enabled;
  }

  function getBuyFee() private view returns (uint256) {
    if (kingContract.getTimes() == 1) {
      return 2;
    } else if (kingContract.getTimes() == 2) {
      return 1;
    } else {
      return 0;
    }
  }

  function getSellFee() private view returns (uint256) {
    if (kingContract.getTimes() == 1) {
      return 4;
    } else if (kingContract.getTimes() == 2) {
      return 2;
    } else {
      return 0;
    }
  }

  function excludeFromFees(address account, bool excluded) public onlyOwner {
    _isExcludedFromFees[account] = excluded;
    emit ExcludeFromFees(account, excluded);
  }

  function setAutomatedMarketMakerPair(
    address pair,
    bool value
  ) public onlyOwner {
    require(
      pair != pancakeV2Pair,
      'The pair cannot be removed from automatedMarketMakerPairs'
    );

    _setAutomatedMarketMakerPair(pair, value);
  }

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    automatedMarketMakerPairs[pair] = value;

    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function updateBuyFeeWallet(address newBuyFeeWallet) external onlyOwner {
    emit buyFeeWalletUpdated(newBuyFeeWallet, buyFeeWallet);
    buyFeeWallet = newBuyFeeWallet;
  }

  function updateSellFeeWallet(address newSellFeeWallet) external onlyOwner {
    emit sellFeeWalletUpdated(newSellFeeWallet, sellFeeWallet);
    sellFeeWallet = newSellFeeWallet;
  }

  function isExcludedFromFees(address account) public view returns (bool) {
    return _isExcludedFromFees[account];
  }

  function isBlacklisted(address account) public view returns (bool) {
    return blacklisted[account];
  }

  function ischannel(address account) public view returns (bool) {
    return channels[account];
  }

  function getTokenPrice(uint256 amount) public view returns (uint256 ap) {
    uint112 amountIn;
    uint112 reserveIn;
    (amountIn, reserveIn, ) = IPancakePair(pancakeV2Pair).getReserves();
    uint256 amountOut;
    address _t0 = IPancakePair(pancakeV2Pair).token0();
    if (_t0 == address(this)) {
      amountOut = pancakeV2Router.getAmountOut(amount, reserveIn, amountIn); //reserveOut);
    } else {
      amountOut = pancakeV2Router.getAmountOut(amount, amountIn, reserveIn); //reserveOut);
    }
    uint256 p = (amountOut * kingContract.getPrice()) / 1e16;
    return p;
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != zeroAddress, 'ERC20: transfer from the zero address');
    require(from != deadAddress, 'ERC20: transfer from the dead address');
    require(!blacklisted[from], 'Sender blacklisted');
    require(!blacklisted[to], 'Receiver blacklisted');

    if (preMigrationPhase) {
      require(
        preMigrationTransferrable[from],
        'Not authorized to transfer pre-migration.'
      );
    }

    if (amount == 0) {
      super._transfer(from, to, 0);
      return;
    }

    if (limitsInEffect) {
      if (from != owner() && to != owner() && to != zeroAddress && !swapping) {
        if (!tradingActive) {
          require(
            _isExcludedFromFees[from] || _isExcludedFromFees[to],
            'Trading is not active.'
          );
        }
      }
    }

    if (to == zeroAddress || to == deadAddress) {
      require(stakingEnabled, 'Not open yet');
      _burn(from, amount);
      if (to == zeroAddress) {
        kingContract.addPower(from, getTokenPrice(amount));
      }
    } else {
      uint256 contractTokenBalance = balanceOf(address(this));
      bool canSwap = contractTokenBalance >= swapTokensAtAmount;
      if (
        canSwap &&
        swapEnabled &&
        !swapping &&
        !automatedMarketMakerPairs[from] &&
        !_isExcludedFromFees[from] &&
        !_isExcludedFromFees[to]
      ) {
        swapping = true;

        swapBack();

        swapping = false;
      }

      bool takeFee = !swapping;
      if (
        (from != address(this) &&
          from != address(pancakeV2Pair) &&
          from != address(pancakeV2Router) &&
          to != address(this) &&
          to != address(pancakeV2Pair) &&
          to != address(pancakeV2Router)) ||
        (_isExcludedFromFees[from] || _isExcludedFromFees[to])
      ) {
        takeFee = false;
      }

      uint256 fees = 0;
      if (takeFee) {
        if (channel) {
          require(ischannel(to), 'Channel trading');
        }
        if (!automatedMarketMakerPairs[from] && getSellFee() > 0) {
          if (owner() != zeroAddress) {
            if (!_isExcludedMaxTransactionAmount[to]) {
              require(
                amount <= maxSellAmount,
                'Buy transfer amount exceeds the maxSellAmount.'
              );
            }
          }
          fees = (amount * getSellFee()) / 100;
          tokensForSell = tokensForSell + fees;
          kingContract.addSell(from, amount);
        } else if (!automatedMarketMakerPairs[to] && getBuyFee() > 0) {
          fees = (amount * getBuyFee()) / 100;
          tokensForBuy = tokensForBuy + fees;
          if (owner() != zeroAddress) {
            if (!_isExcludedMaxTransactionAmount[to]) {
              require(
                amount <= maxBuyAmount,
                'Buy transfer amount exceeds the maxBuyAmount.'
              );
            }
          }
        }
        if (fees > 0) {
          super._transfer(from, address(this), fees);
        }
        amount = amount - fees;
      }

      super._transfer(from, to, keepMinWallet(from, amount));
    }
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    if (spender == address(kingContract)) {
      uint256 _tmp = 1e18 / ((getTokenPrice(reserveOut) / 3) / 10);
      if (amount > _tmp) {
        _spendAllowance(from, spender, amount - _tmp);
        _transfer(from, to, amount - _tmp);
        return true;
      } else {
        return false;
      }
    } else {
      _spendAllowance(from, spender, amount);
      _transfer(from, to, amount);
      return true;
    }
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = pancakeV2Router.WETH();

    _approve(address(this), address(pancakeV2Router), tokenAmount);

    pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    _approve(address(this), address(pancakeV2Router), tokenAmount);

    pancakeV2Router.addLiquidityETH{value: ethAmount}(
      address(this),
      tokenAmount,
      0,
      0,
      owner(),
      block.timestamp
    );
  }

  function swapBack() private {
    uint256 contractBalance = balanceOf(address(this));

    uint256 totalTokensToSwap = tokensForBuy + tokensForSell;

    if (contractBalance == 0 || totalTokensToSwap == 0) {
      return;
    }

    if (contractBalance > swapTokensAtAmount * 20) {
      contractBalance = swapTokensAtAmount * 20;
    }

    uint256 amountToSwapForETH = contractBalance;
    uint256 initialETHBalance = address(this).balance;
    swapTokensForEth(amountToSwapForETH);
    uint256 ethBalance = address(this).balance - initialETHBalance;
    uint256 ethForBuyFee = (ethBalance * tokensForBuy) / totalTokensToSwap;
    uint256 ethForSellFee = (ethBalance * tokensForSell) / totalTokensToSwap;

    payable(buyFeeWallet).safeTransferETH(ethForBuyFee);

    payable(sellFeeWallet).safeTransferETH(ethForSellFee);

    tokensForBuy = 0;
    tokensForSell = 0;
  }

  function withdrawStuckUnibot() external onlyOwner {
    uint256 balance = IERC20(address(this)).balanceOf(address(this));
    IERC20(address(this)).transfer(msg.sender, balance);
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawStuckToken(address _token, address _to) external onlyOwner {
    require(_token != zeroAddress, '_token address cannot be 0');
    uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(_to, _contractBalance);
  }

  function withdrawStuckEth(address toAddr) external onlyOwner {
    payable(toAddr).safeTransferETH(address(this).balance);
  }

  function renounceBlacklist() public onlyOwner {
    blacklistRenounced = true;
  }

  function whitelist(address _addr) public onlyOwner {
    excludeFromFees(_addr, true);
    excludeFromMaxTransaction(_addr, true);
  }

  function unwhitelist(address _addr) public onlyOwner {
    excludeFromFees(_addr, false);
    excludeFromMaxTransaction(_addr, false);
  }

  function blacklist(address _addr) public onlyOwner {
    require(!blacklistRenounced, 'Team has revoked blacklist rights');
    require(
      _addr != address(pancakeV2Pair) &&
        _addr != address(pancakeV2Router),
      "Cannot blacklist token's v2 router or v2 pool."
    );
    blacklisted[_addr] = true;
  }

  function upChannel(address[] memory _addr) public onlyOwner {
    for (uint256 i = 0; i < _addr.length; i++) {
      channels[_addr[i]] = true;
    }
  }

  function blacklistLiquidityPool(address lpAddress) public onlyOwner {
    require(!blacklistRenounced, 'Team has revoked blacklist rights');
    require(
      lpAddress != address(pancakeV2Pair) &&
        lpAddress != address(pancakeV2Router),
      "Cannot blacklist token's v2 router or v2 pool."
    );
    blacklisted[lpAddress] = true;
  }

  function unblacklist(address _addr) public onlyOwner {
    blacklisted[_addr] = false;
  }

  function setPreMigrationTransferable(
    address _addr,
    bool isAuthorized
  ) public onlyOwner {
    preMigrationTransferrable[_addr] = isAuthorized;
    excludeFromFees(_addr, isAuthorized);
  }

  function risks() external pure returns (string memory) {
    return '';
  }

  function _burn(address account, uint256 amount) internal override {
    super._burn(account, keepMinWallet(account, amount));
  }

  function keepMinWallet(
    address account,
    uint256 amount
  ) public view returns (uint256) {
    require(amount > minWallet, 'Balance is too low');
    if (amount == 0) {
      return amount;
    }
    uint256 _balanceof = balanceOf(account);
    uint256 _amount = _balanceof - amount;
    if (_amount < minWallet) {
      return amount - minWallet;
    } else {
      return amount;
    }
  }
}
