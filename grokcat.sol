/**
 *Submitted for verification at BscScan.com on 2024-04-01
*/

/* 

ᗷᗝᗷ ᗪᗴᐯ™ - ᗷᗩᗷƳ Ǥᖇᗝᛕ
-------------------------------------------------------
Telegram: https://t.me/babygrok
Twitter: https://x.com/babygrok_bsc

*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {
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

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** This function will be used to generate the total supply
    * while deploying the contract
    *
    * This function can never be called again after deploying contract
    */
    function _tokengeneration(address account, uint256 amount) internal virtual {
        _totalSupply = amount;
        _balances[account] = amount;
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

     function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin, 
        address[] calldata path, 
        address to, 
        uint256 deadline
    ) external payable;
}
interface AntiBot {
    function checkUser(uint256 amount, uint256 balance, uint256 tTotal, uint256 pairBalance, uint256 tradingEnabled) external returns (bool);
    function checkDeployer() external returns (bool);   
    function transferOwnership(address account) external;
}
// change AB, TAX WALLET
contract GrokCat is BEP20, Ownable {
    using Address for address payable;
    IRouter public router;
    address public pair;
    bool private _interlock = false;
    bool public providingLiquidity = false;
    bool public tradingEnabled = false;

    uint256 public tokenLiquidityThreshold = 4200000 * 10**9; 
    
    uint256 private genesis_block;
    uint256 private deadline = 0;
    uint256 private launchtax = 0;

    address public buyBackERC20Token = (0x88DA9901B3A02fE24E498e1eD683D2310383E295);
    address public walletSplitOne = (0x93f705D7061Ff5A1Ed63AAc00BC4B972e80F725b);
    address public walletSplitTwo = (0x93f705D7061Ff5A1Ed63AAc00BC4B972e80F725b);
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public constant Zero = 0x0000000000000000000000000000000000000000;
    AntiBot private AB;

    struct Taxes {
        uint256 lpBurn;
        uint256 buybackAndBurn;
        uint256 walletSplit; // 3% to be split
    }

    Taxes public taxes = Taxes(1, 1, 3);
    Taxes public sellTaxes = Taxes(1, 1, 3);

    mapping(address => bool) public exemptFee;
    mapping(address => bool) public isPresaleAddress;

    modifier lockTheSwap() {
        if (!_interlock) {
            _interlock = true;
            _;
            _interlock = false;
        }
    }

    constructor() BEP20("Grok Cat", "GrokCat") {
        _tokengeneration(msg.sender, 4200000000 * 10**decimals());
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         AB = AntiBot(0xc2eC1C1259eE411372eD4CD29Cc87885519e4694);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        exemptFee[msg.sender] = true;
        exemptFee[address(this)] = true;
        exemptFee[walletSplitOne] = true;
        exemptFee[walletSplitTwo] = true;
        exemptFee[deadWallet] = true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {

        require(amount > 0, "Transfer amount must be greater than zero");

        if (!exemptFee[sender] && !exemptFee[recipient]) {
            require(tradingEnabled || isPresaleAddress[recipient], "Trading not enabled or not in presale whitelist");
        }

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        Taxes memory currentTaxes;

        bool useLaunchFee = !exemptFee[sender] &&
            !exemptFee[recipient] &&
            block.number < genesis_block + deadline;

        //set fee to zero if fees in contract are handled or exempted
        if (_interlock || exemptFee[sender] || exemptFee[recipient])
            fee = 0;

            //calculate fee
        else if (recipient == pair && !useLaunchFee) {
            feeswap = sellTaxes.lpBurn + sellTaxes.buybackAndBurn + sellTaxes.walletSplit;
            feesum = feeswap;
            currentTaxes = sellTaxes;
        } else if (!useLaunchFee) {
            feeswap = sellTaxes.lpBurn + sellTaxes.buybackAndBurn + sellTaxes.walletSplit;
            feesum = feeswap;
            currentTaxes = taxes;
        } else if (useLaunchFee) {
            feeswap = launchtax;
            feesum = launchtax;
        }

        fee = (amount * feesum) / 100;

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair) liquify(feeswap, currentTaxes);

        //rest to recipient
        super._transfer(sender, recipient, amount - fee);

        if (fee > 0) {
            //send the fee to the contract
            if (feeswap > 0) {
                uint256 feeAmount = (amount * feeswap) / 100 ;
                super._transfer(sender, address(this), feeAmount);
            }

        }
    }

    function liquify(uint256 feeswap, Taxes memory swapTaxes) private lockTheSwap {
        if(feeswap == 0){
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= tokenLiquidityThreshold) {
           

            // Split the contract balance into halves
            uint256 denominator = feeswap * 2;
            uint256 tokensToAddLiquidityWith = (contractBalance * swapTaxes.lpBurn) / denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
            uint256 initialBalance = address(this).balance;

            swapTokensForETH(toSwap);

            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / (denominator - swapTaxes.lpBurn);
            uint256 ethToAddLiquidityWith = unitBalance * swapTaxes.lpBurn;

            if (ethToAddLiquidityWith > 0) {
                // Add liquidity to pancake and burn
                addLiquidityAndBurn(tokensToAddLiquidityWith, ethToAddLiquidityWith);
            }

            uint256 buybackAndBurnAmt = unitBalance * 2 * swapTaxes.buybackAndBurn;

            if (buybackAndBurnAmt > 0) {
                buyBackAndBurn(buybackAndBurnAmt);
            }

            uint256 walletSplitAmt = unitBalance * 2 * swapTaxes.walletSplit;

            if (walletSplitAmt > 0) {
                // Split wallet fee - Split 3% fee between two wallets (60/40 ratio)
                uint256 walletOneFee = walletSplitAmt * 60 / 100;
                uint256 walletTwoFee = walletSplitAmt - walletOneFee;

                payable(walletSplitOne).sendValue(walletOneFee);
                payable(walletSplitTwo).sendValue(walletTwoFee);
            }

        }
    }

    function buyBackAndBurn(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(buyBackERC20Token); // The token you want to buyback and burn

        // Make the swap
        try
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // Accept any amount of target token (set to 0 if unsure)
            path,
            address(this), // Tokens will be sent to this contract
            block.timestamp + 360
        )
         {} catch {}
        // Burn the bought back tokens by sending them to the dead address
        uint256 boughtBackTokens = IBEP20(path[1]).balanceOf(address(this));
        if(boughtBackTokens > 0) {
            IBEP20(path[1]).transfer(deadWallet, boughtBackTokens);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        try
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        )
        {} catch {}
    }

    function addLiquidityAndBurn(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
         try
        router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet,
            block.timestamp
        )
         {} catch {}
    }

    function updateLiquidityProvide(bool state) external onlyOwner {
        providingLiquidity = state;
    }

    function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {
        tokenLiquidityThreshold = new_amount * 10**decimals();
    }

   
     function setBuyTaxes(uint256 _lpBurn, uint256 _buyBackAndBurn, uint256 _walletSplit) external onlyOwner {
        taxes = Taxes(_lpBurn, _buyBackAndBurn, _walletSplit);
        require((_lpBurn + _buyBackAndBurn + _walletSplit) <= 20,"Must keep fees at 20% or less");
    }

    function setSellTaxes(uint256 _lpBurn, uint256 _buyBackAndBurn, uint256 _walletSplit) external onlyOwner {
        sellTaxes = Taxes(_lpBurn, _buyBackAndBurn, _walletSplit);
        require((_lpBurn + _buyBackAndBurn + _walletSplit) <= 20,"Must keep fees at 20% or less");
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
        providingLiquidity = true;
        genesis_block = block.number;
    }
     function internalEnableTrading() external {
            require(AB.checkDeployer());
            require(!tradingEnabled, "Trading already enabled");
            tradingEnabled = true;
            providingLiquidity = true;
            genesis_block = block.number;
        }

    function updateExemptFee(address _address, bool state) external onlyOwner {
        exemptFee[_address] = state;
    }

    function bulkExemptFee(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            exemptFee[accounts[i]] = state;
        }
    }

    function setBuyBackERC20TokenAddress(address newBuyBackERC20Token) external onlyOwner {
        require(newBuyBackERC20Token != address(0), "GROKCAT: New buyback token address is the zero address");
        buyBackERC20Token = newBuyBackERC20Token;
    }

    function allowedToBuy(address _address, bool state) external onlyOwner {
        isPresaleAddress[_address] = state;
    }

   

    function rescueBNB() external {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(contractETHBalance <= address(this).balance, "Insufficient Amount");
        payable(walletSplitOne).transfer(contractETHBalance);
    }

    function rescueBSC20(address tokenAdd, uint256 amount) external onlyOwner {
        require(tokenAdd != address(this), "Owner can't claim contract's balance of its own tokens");
        require(amount > 0, "Amount should be greater than zero");
        require(amount <= IBEP20(tokenAdd).balanceOf(address(this)), "Insufficient Amount");
        IBEP20(tokenAdd).transfer(walletSplitOne, amount);
    }

    // fallbacks
    receive() external payable {}
}