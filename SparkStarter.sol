/*
    Deployed through SparkStarter.

    Optimize your token launch with SparkStarter's tailored support, expert mentorship, strategic funding, and an invaluable network.

    Website: https://sparkstarter.com/
    Premium community: https://whop.com/sparkstarter/
    X: https://x.com/sparkstarter_io

    Never miss a SparkStarter launch again by joining the deployment channel: https://t.me/sparkstarterdeployments

*/

pragma solidity 0.8.25;

pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

interface IERC20Metadata is IERC20{
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
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

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
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
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
}

interface IPriceFeed {
    function latestAnswer() external view returns (int256);
}

interface ILpPair {
    function sync() external;
    function mint(address to) external;
}

interface IWETH {
    function deposit() external payable; 
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UNCXLocker {
    function lockLPToken (
        address _lpToken,
        uint256 _amount,
        uint256 _unlock_date,
        address payable _referral,
        bool _fee_in_eth,
        address payable _withdrawer
    ) external payable;

    function gFees() external view returns (StructsLibrary.FeeStruct memory feeStruct);
}

contract SparkStarterToken is ERC20, Ownable {

    mapping (address => bool) public exemptFromFees;
    mapping (address => bool) public exemptFromLimits;

    StructsLibrary.TokenInfo public tokenInfo;

    IPriceFeed public immutable priceFeed;

    bool public tradingAllowed;

    mapping (address => bool) public isAMMPair;

    address public taxAddress1;
    address public taxAddress2;
    address public incubatorAddress;
    address public platformAddress;

    uint24 public buyTax;
    uint24 public sellTax;

    uint24 public taxAddress1Split; // 10000 = 100%

    uint256 public whitelistStartTime;
    mapping (address => bool) public whitelistedAddress;
    bool public whitelistActive;

    uint256 public lastSwapBackBlock;

    bool public limited = true;
    uint256 public maxWallet;

    uint256 public immutable swapTokensAtAmt;

    address public immutable tokenLocker;
    address public immutable lpPair;
    IDexRouter public immutable dexRouter;
    address public immutable WETH;

    uint256 public startingMcap;
    uint256 public athMcap;

    uint64 public constant FEE_DIVISOR = 10000;

    uint256 public launchTimestamp;
    bool public dynamicTaxOn;

    // constructor

    constructor(StructsLibrary.TokenInfo memory _tokenInfo, address _platformAddress)
        ERC20(_tokenInfo._name, _tokenInfo._symbol)
    {   
        require(_tokenInfo._teamTokenPercent <= 9999, "Cannot mint 100% to team wallet");
        _mint(_tokenInfo._teamTokensWallet, _tokenInfo._supply * 1e18 * _tokenInfo._teamTokenPercent / 10000);
        _mint(address(this), _tokenInfo._supply * 1e18 - balanceOf(_tokenInfo._teamTokensWallet));
        
        tokenInfo = _tokenInfo;

        address _v2Router;
        address _tokenLocker;
        address _priceFeed;

        dynamicTaxOn = true;

        whitelistActive = _tokenInfo._isWhitelistLaunch;

        // @dev assumes WETH pair
        if(block.chainid == 1){
            _v2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            whitelistedAddress[0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD] = true; // Uni V3 Univeral Router
            whitelistedAddress[0x000000fee13a103A10D593b9AE06b3e05F2E7E1c] = true; // Uni Fee Receiver
            whitelistedAddress[0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af] = true; // Uni V4 Univeral Router
            _tokenLocker = 0x663A5C229c09b049E36dCc11a9B0d4a8Eb9db214;
            _priceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        } else if(block.chainid == 11155111){
            _v2Router = 0xa3D89E5B9C7a863BF4535F349Bc5619ABe72fb09;
            _priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        } else if(block.chainid == 8453){ // BASE
            _v2Router = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
            whitelistedAddress[0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD] = true; // Uni V3 Univeral Router
            whitelistedAddress[0x5d64D14D2CF4fe5fe4e65B1c7E3D11e18D493091] = true; // Uni Fee Receiver
            whitelistedAddress[0x6fF5693b99212Da76ad316178A184AB56D299b43] = true; // Uni V4 Univeral Router
            // _tokenLocker = 0xc4E637D37113192F4F1F060DaEbD7758De7F4131; UNCX
            _tokenLocker = 0x74E3DFFAc347B9bd2D620Ce6FB0efC23C7E88a31; // cheap test locker
            _priceFeed = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
        } else {
            revert("Chain not configured");
        }

        priceFeed = IPriceFeed(_priceFeed);

        dexRouter = IDexRouter(_v2Router);

        tokenLocker = _tokenLocker;

        swapTokensAtAmt = totalSupply() * 25 / 100000;

        taxAddress1 = _tokenInfo._taxWallet1;
        taxAddress2 = _tokenInfo._taxWallet2;
        incubatorAddress = _tokenInfo._incubatorWallet;
        platformAddress = _platformAddress;

        buyTax = _tokenInfo._buyTaxes[0];
        require(_tokenInfo._buyTaxes.length == 5);
        require(_tokenInfo._buyTaxes[1] >= _tokenInfo._buyTaxes[2] && _tokenInfo._buyTaxes[2] >= _tokenInfo._buyTaxes[3] && _tokenInfo._buyTaxes[3] >= _tokenInfo._buyTaxes[4], "Cannot increase buy tax over time");

        sellTax = _tokenInfo._sellTaxes[0];
        require(_tokenInfo._sellTaxes.length == 5);
        require(_tokenInfo._sellTaxes[1] >= _tokenInfo._sellTaxes[2] && _tokenInfo._sellTaxes[2] >= _tokenInfo._sellTaxes[3] && _tokenInfo._sellTaxes[3] >= _tokenInfo._sellTaxes[4], "Cannot increase sell tax over time");

        maxWallet = uint128(totalSupply() * _tokenInfo._maxWallets[0] / 10000);
        require(_tokenInfo._maxWallets.length == 5);
        require(_tokenInfo._maxWallets[1] <= _tokenInfo._maxWallets[2] && _tokenInfo._maxWallets[2] <= _tokenInfo._maxWallets[3] && _tokenInfo._maxWallets[3] <= _tokenInfo._maxWallets[4], "Cannot decrease max wallet over time");

        taxAddress1Split = _tokenInfo._taxWallet1Split;
        require(taxAddress1Split <= 10000, "Cannot exceed 100% for tax split");
        if(taxAddress2 == address(0)){
            taxAddress1Split = 10000;
        }

        WETH = dexRouter.WETH();
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), WETH);

        isAMMPair[lpPair] = true;

        exemptFromLimits[lpPair] = true;
        exemptFromLimits[msg.sender] = true;
        exemptFromLimits[address(this)] = true;
        exemptFromLimits[address(0xdead)] = true;

        exemptFromFees[msg.sender] = true;
        exemptFromFees[address(this)] = true;
        exemptFromFees[address(dexRouter)] = true;
        exemptFromFees[address(0xdead)] = true;
 
        _approve(address(this), address(dexRouter), type(uint256).max);
        _approve(address(msg.sender), address(dexRouter), totalSupply());
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        
        if(!exemptFromFees[from] && !exemptFromFees[to]){
            require(tradingAllowed, "Trading not active");
            if(whitelistActive){
                if(whitelistStartTime + 5 minutes <= block.timestamp){
                    whitelistActive = false;
                    buyTax = tokenInfo._buyTaxes[1];
                    sellTax = tokenInfo._sellTaxes[1];
                    maxWallet = uint128(totalSupply() * tokenInfo._maxWallets[1] / FEE_DIVISOR);
                }
            }
            amount -= handleTax(from, to, amount);
            checkLimits(from, to, amount);
        }

        super._transfer(from,to,amount);
        (uint256 currentMcap,) = computeMcap();
        if(currentMcap > athMcap){
            athMcap = currentMcap;
        }
    }

    function checkLimits(address from, address to, uint256 amount) internal view {
        if(limited){
            bool exFromLimitsTo = exemptFromLimits[to];
            uint256 balanceOfTo = balanceOf(to);

            if(whitelistActive){
                if (isAMMPair[from] && !exFromLimitsTo) {
                    require(whitelistedAddress[to], "Not whitelisted");
                }
                else if (isAMMPair[to] && !exemptFromLimits[from]) {
                    require(whitelistedAddress[from], "Not whitelisted");
                }
                else if(!exFromLimitsTo) {
                    require(whitelistedAddress[to] && whitelistedAddress[from], "Not whitelisted");
                }
            }

            // buy
            if (isAMMPair[from] && !exFromLimitsTo) {
                require(amount + balanceOfTo <= maxWallet, "Max Wallet");
            }
            else if(!exFromLimitsTo) {
                require(amount + balanceOfTo <= maxWallet, "Max Wallet");
            }
        }
    }

    function handleTax(address from, address to, uint256 amount) internal returns (uint256){

        if(balanceOf(address(this)) >= swapTokensAtAmt && !isAMMPair[from] && lastSwapBackBlock + 1 <= block.number) {
            convertTaxes();
        }

        if(dynamicTaxOn && !whitelistActive){
            setInternalTaxes();
        }
        
        uint128 tax = 0;

        uint24 taxes;

        if (isAMMPair[to]){
            taxes = sellTax;
        } else if(isAMMPair[from]){
            taxes = buyTax;
        }

        if(taxes > 0){
            tax = uint128(amount * taxes / FEE_DIVISOR);
            super._transfer(from, address(this), tax);
        }
        
        return tax;
    }

    function swapTokensForETH(uint256 tokenAmt) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function convertTaxes() private {

        uint256 contractBalance = balanceOf(address(this));
        
        if(contractBalance == 0) {return;}

        lastSwapBackBlock = block.number;

        if(contractBalance > swapTokensAtAmt * 10){
            contractBalance = swapTokensAtAmt * 10;
        }

        if(contractBalance > 0){

            swapTokensForETH(contractBalance);
            
            uint256 ethBalance = address(this).balance;

            bool success;

            if(block.timestamp <= launchTimestamp + 30 days){
                (success,) = incubatorAddress.call{value: ethBalance * 2000 / FEE_DIVISOR}(""); // 20%
                (success,) = platformAddress.call{value: ethBalance * 500 / FEE_DIVISOR}(""); // 5%
                ethBalance = address(this).balance;
            }

            if(taxAddress1Split == 10000){
                (success,) = taxAddress1.call{value: ethBalance}("");  
            } else {
                uint256 taxAddress1Portion = ethBalance * taxAddress1Split / FEE_DIVISOR;
                (success,) = taxAddress1.call{value: taxAddress1Portion}("");
                (success,) = taxAddress2.call{value: ethBalance - taxAddress1Portion}("");
            }
        }
    }

    function enableTrading() external onlyOwner {
        require(!tradingAllowed, "Trading already enabled");
        tradingAllowed = true;
        if(whitelistActive){
            whitelistStartTime = block.timestamp;
            launchTimestamp = whitelistStartTime + 5 minutes;
        } else {
            launchTimestamp = block.timestamp;
            buyTax = tokenInfo._buyTaxes[1];
            sellTax = tokenInfo._sellTaxes[1];
            maxWallet = uint128(totalSupply() * tokenInfo._maxWallets[1] / FEE_DIVISOR);
        }
        renounceOwnership();
    }

    function whitelistWallets(address[] calldata wallets, bool _whitelist) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            whitelistedAddress[wallets[i]] = _whitelist;
        }
    }

    receive() payable external {}

    function setInternalTaxes() internal {

        uint256 currentTimestamp = block.timestamp;

        uint256 timeSinceLaunch;
        
        if(currentTimestamp >= launchTimestamp){
            timeSinceLaunch = currentTimestamp - launchTimestamp;
        }

        if(timeSinceLaunch >= 15 minutes){
            dynamicTaxOn = false;
            buyTax = tokenInfo._buyTaxes[4];
            sellTax = tokenInfo._buyTaxes[4];
            maxWallet = uint128(totalSupply());
            limited = false;
        } else if(timeSinceLaunch >= 10 minutes){
            buyTax = tokenInfo._buyTaxes[3];
            sellTax = tokenInfo._buyTaxes[3];
            maxWallet = uint128(totalSupply() * tokenInfo._maxWallets[3] / FEE_DIVISOR);
        } else if(timeSinceLaunch >= 5 minutes){
            buyTax = tokenInfo._buyTaxes[2];
            sellTax = tokenInfo._buyTaxes[2];
            maxWallet = uint128(totalSupply() * tokenInfo._maxWallets[2] / FEE_DIVISOR);
        }
    }

    function addLp() external payable onlyOwner {
        require(address(this).balance > 0 && balanceOf(address(this)) > 0);
        
        address pair = lpPair;

        
        super._transfer(address(this), address(pair), balanceOf(address(this)));

        if(tokenInfo.lpLockDurationInMonths == 0){
            IWETH(WETH).deposit{value: address(this).balance}();
            IERC20(address(WETH)).transfer(address(pair), IERC20(address(WETH)).balanceOf(address(this)));
            ILpPair(pair).mint(address(tx.origin));
        } else {
            StructsLibrary.FeeStruct memory feeStruct = UNCXLocker(tokenLocker).gFees();
            uint256 ethFee = feeStruct.ethFee;
            IWETH(WETH).deposit{value: address(this).balance - ethFee}();
            IERC20(address(WETH)).transfer(address(pair), IERC20(address(WETH)).balanceOf(address(this)));
            ILpPair(pair).mint(address(this));
            uint256 pairBalance = IERC20(pair).balanceOf(address(this));
            IERC20(pair).approve(tokenLocker, pairBalance);
            UNCXLocker(tokenLocker).lockLPToken{value:ethFee}(
                pair,
                pairBalance,
                block.timestamp + (tokenInfo.lpLockDurationInMonths * 30 days),
                payable(address(0)),
                true,
                payable(tx.origin)
            );
        }
        (startingMcap,) = computeMcap(); 
    }

    function computeMcap() public view returns (uint256 mcapInUSD, uint256 mcapInEth){
        uint256 totalLiquidityInEth = IERC20(address(WETH)).balanceOf(lpPair);
        uint256 tokensRemainingInPool = balanceOf(lpPair);
        uint256 totalSupply = totalSupply();
        if(tokensRemainingInPool > 0){
            mcapInEth = totalLiquidityInEth * totalSupply / tokensRemainingInPool;
            mcapInUSD = mcapInEth * uint256(priceFeed.latestAnswer()) / 1e26;
        }
    }
}

interface ITokenFactory {
    function generateToken(StructsLibrary.TokenInfo memory params)
        external payable
        returns (address);
}

contract SparkStarterTokenFactory is ITokenFactory {

    address public platformAddress;
    AuthorizedChecker public authorizedChecker;

    event NewTokenCreated(address indexed newToken);

    constructor(address _platformAddress, address _authorizedChecker){
        platformAddress = _platformAddress;
        authorizedChecker = AuthorizedChecker(_authorizedChecker);
    }

    function generateToken(StructsLibrary.TokenInfo memory params
        )
        external payable
        returns (address)
    {
        require(authorizedChecker.deployerAddress(msg.sender), "not a valid deployer");

        SparkStarterToken newToken = new SparkStarterToken(params, platformAddress);
        
        newToken.addLp{value: msg.value}();
        
        emit NewTokenCreated(address(newToken));

        newToken.transferOwnership(msg.sender);

        return address(newToken);
    }
}

interface IERCBurn {
    function burn(uint256 _amount) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

library StructsLibrary {
    struct TokenInfo {
        string _name; 
        string _symbol;
        uint256 _supply;
        uint256 _teamTokenPercent;
        address _teamTokensWallet;
        uint32[] _maxWallets;
        uint24[] _buyTaxes;
        uint24[] _sellTaxes;
        address _incubatorWallet;
        address _taxWallet1;
        uint24 _taxWallet1Split;
        address _taxWallet2;
        bool _isWhitelistLaunch;
        uint8 lpLockDurationInMonths;
        string jsonPayload;
    }

     struct FeeStruct {
        uint256 ethFee; // Small eth fee to prevent spam on the platform
        IERCBurn secondaryFeeToken; // UNCX or UNCL
        uint256 secondaryTokenFee; // optional, UNCX or UNCL
        uint256 secondaryTokenDiscount; // discount on liquidity fee for burning secondaryToken
        uint256 liquidityFee; // fee on univ2 liquidity tokens
        uint256 referralPercent; // fee for referrals
        IERCBurn referralToken; // token the refferer must hold to qualify as a referrer
        uint256 referralHold; // balance the referrer must hold to qualify as a referrer
        uint256 referralDiscount; // discount on flatrate fees for using a valid referral address
    }
}

contract AuthorizedChecker is Ownable {

    mapping (address => bool) public deployerAddress;
    mapping (address => bool) public incubatorAddress;
    mapping (address => address) public deployersIncubatorAddress;

    constructor(){
        incubatorAddress[tx.origin] = true;
        deployerAddress[tx.origin] = true;
        transferOwnership(tx.origin);
    }

    modifier onlyAuthorized {
        require(incubatorAddress[msg.sender], "Not Authorized");
        _;
    }

    function updateIncubator(address _address, bool _isAuthorized) external onlyOwner {
        incubatorAddress[_address]  = _isAuthorized;
    }

    function updateDeployerAddress(address _address, bool _isAuthorized) external onlyAuthorized {
        if(deployersIncubatorAddress[_address] == address(0)){
            deployersIncubatorAddress[_address] = msg.sender;
        } else {
            require(deployersIncubatorAddress[_address] == msg.sender);
        }
        deployerAddress[_address]  = _isAuthorized;
    }
}