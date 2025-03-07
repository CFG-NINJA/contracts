/**
 *Submitted for verification at Etherscan.io on 2024-10-21
*/

/**

Join us on our mission to become the go-to hub for immersive and interactive crypto experiences. Play your favourite games against your friends or online with our unique crypto gaming Ecosystem.

Website: https://www.thegamehub.io
Twitter: https://x.com/TheGameHub_io
Telegram: https://t.me/TheGameHubIO
Linktree: https://linktr.ee/thegamehub.io

**/
// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.26;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address public _owner;

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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface InterfaceLP {
    function sync() external;
}

contract TheGamehub is Ownable, ERC20 {

    address immutable WETH;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "The GameHub";
    string constant _symbol = "GHUB";
    uint8 constant _decimals = 9; 
  

    uint256 constant _totalSupply = 100000000 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 50;
    uint256 public _maxWalletAmount = _totalSupply / 50;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) private _isUnauthorized;

    uint256 private buyMarketingFee    = 15;
    uint256 private buyTeamFee         = 15;
    uint256 public  buyTotalFee        = buyTeamFee + buyMarketingFee;

    uint256 private sellMarketingFee   = 15;
    uint256 private sellTeamFee        = 15;
    uint256 public  sellTotalFee       = sellTeamFee + sellMarketingFee;

    uint256 constant transferFee        = 0;
    
    uint256 private lastSwap;
    address private marketingFeeReceiver;
    address private teamFeeReceiver;

    IDEXRouter public router;
    InterfaceLP private pairContract;
    address immutable public pair;
    
    bool public TradingOpen = false;    

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 100; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    event maxWalletUpdated(uint256 indexed maxWalletAmount);
    event maxTxUpdated(uint256 indexed maxTxAmount);
    event maxLimitsRemoved(uint256 indexed maxWalletToken, uint256 indexed maxTxAmount);
    event exemptFees(address indexed holder, bool indexed exempt);
    event exemptTxLimit(address indexed holder, bool indexed exempt);
    event buyFeesUpdated(uint256 indexed buyTeamFee, uint256 indexed buyMarketingFee);
    event sellFeesUpdated(uint256 indexed sellTeamFee, uint256 indexed sellMarketingFee);
    event feesWalletsUpdated(address indexed marketingFeeReceiver, address indexed teamFeeReceiver);
    event swapbackSettingsUpdated(bool indexed enabled, uint256 indexed amount);
    event tradingEnabled(bool indexed enabled, uint256 indexed startTime);
    
    constructor () {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        pairContract = InterfaceLP(pair);
       
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        marketingFeeReceiver = 0x0Fc8cbD075cCc7eD5b829646Ab4fA72A2e393317;
        teamFeeReceiver = 0x97c424eeD2E86e1917E4ca9417E79acAc1d0723d;

        isFeeExempt[msg.sender] = true; 
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[address(this)] = true;
        

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) {return owner();}
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Spender is the zero address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveAll(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "Recipient is the zero address");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "Sender is the zero address");
        require(recipient != address(0), "Recipient is the zero address");
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if(currentAllowance != type(uint256).max){
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _allowances[sender][_msgSender()] = currentAllowance - amount;
            }
        }

        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWallet(uint256 maxWalletPercent) external onlyOwner {
        require(maxWalletPercent >= 5);
        _maxWalletAmount = (_totalSupply * maxWalletPercent ) / 1000;
        emit maxWalletUpdated(_maxWalletAmount);       
    }

    function setMaxTx(uint256 maxTxPercent) external onlyOwner {
        require(maxTxPercent >= 5); 
        _maxTxAmount = (_totalSupply * maxTxPercent ) / 1000;
        emit maxTxUpdated(_maxTxAmount);
    }

   
  
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!_isUnauthorized[sender] && !_isUnauthorized[recipient], "You are a Unauthorized");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner()){
            require(TradingOpen,"Trading not open yet");
        
        }
        
        checkTxLimit(sender, amount);
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);

        if (sender != owner() && (recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && !isTxLimitExempt[recipient])){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amountReceived) <= _maxWalletAmount,"Total Holding is currently limited, you can not buy that much.");}

        if(
            lastSwap != block.number &&
            _balances[address(this)] >= swapThreshold &&
            swapEnabled &&
            !inSwap &&
            recipient == pair
        ){ 
            swapBack();
            lastSwap = block.number;
        }

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "Tx Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, address recipient) internal returns (uint256) {
        uint256 feeAmount = 0;

        if(recipient == pair) {
            feeAmount = (amount * sellTotalFee) / 100;
        } else if(sender == pair) {
            feeAmount = (amount * buyTotalFee) / 100;
        }else{
            feeAmount = (amount * transferFee) / 100;
        }

        _balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        uint256 notFeeAmount = amount - feeAmount;

        return notFeeAmount;
    }

    function removeMaxLimits() external onlyOwner { 
        _maxWalletAmount = _totalSupply;
        _maxTxAmount = _totalSupply;
        emit maxLimitsRemoved(_maxWalletAmount, _maxTxAmount);
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external returns (bool) {
        require(msg.sender == marketingFeeReceiver || msg.sender == teamFeeReceiver);
        require(address(tokenAddress) != address(this));
        if(tokens == 0){
            tokens = ERC20(tokenAddress).balanceOf(address(this));
        }
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }


    function StartTheGameHub() external onlyOwner {
        require(!TradingOpen,"Trading already Enabled.");
        TradingOpen = true;
        lastSwap = block.number;
        emit tradingEnabled(TradingOpen, lastSwap);
    }

    function swapBack() internal swapping {
        uint256 totalFee = buyTotalFee + sellTotalFee;
        uint256 teamFee = buyTeamFee + sellTeamFee;
        uint256 amountETHteam = 0;
        uint256 amountETHMarketing = 0;

        uint256 amountToSwap = swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 totalETHFee = address(this).balance;

        if(totalFee == 0) {
            amountETHteam = 0;
        } else {
            amountETHteam = (totalETHFee * teamFee) / totalFee;
        }

        amountETHMarketing = totalETHFee - amountETHteam;

        (bool tmpSuccess,) = payable(teamFeeReceiver).call{value: amountETHteam}("");
        require(tmpSuccess, "Failed to send ether to Team Fee Receiver.");
        
        (bool tmpSuccess1,) = payable(marketingFeeReceiver).call{value: amountETHMarketing}("");
        require(tmpSuccess1, "Failed to send ether to Marketing Fee Receiver.");

    }

    function exemptAll(address holder, bool exempt) external onlyOwner {
        require(holder != address(0), "Holder is the zero address");
        isFeeExempt[holder] = exempt;
        isTxLimitExempt[holder] = exempt;
        emit exemptFees(holder, exempt);
    }

    function setTxLimitExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(0), "Holder is the zero address");
        isTxLimitExempt[holder] = exempt;
        emit exemptTxLimit(holder, exempt);
    }


    function updateBuyFees(uint256 _teamFee, uint256 _marketingFee) external onlyOwner {
        require( _teamFee + _marketingFee <= 5, "Fees can not be more than 5%"); 
        buyTeamFee = _teamFee;
        buyMarketingFee = _marketingFee;
        buyTotalFee =_teamFee+ _marketingFee;
        emit buyFeesUpdated(buyTeamFee, buyMarketingFee);
    }

    function updateSellFees(uint256 _teamFee, uint256 _marketingFee) external onlyOwner {
        require(_teamFee + _marketingFee <= 5, "Fees can not be more than 5%"); 
        sellTeamFee = _teamFee;
        sellMarketingFee = _marketingFee;
        sellTotalFee =_teamFee+ _marketingFee;
        emit sellFeesUpdated(sellTeamFee, sellMarketingFee);
    }

    function updateReceiverWallets( address _marketingFeeReceiver, address _teamFeeReceiver) external onlyOwner {
        require(_marketingFeeReceiver != address(0) && _teamFeeReceiver != address(0) , "Fee receiver cannot be zero address");
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
        emit feesWalletsUpdated(marketingFeeReceiver, teamFeeReceiver);
    }

    function editSwapbackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * 10**_decimals;
        emit swapbackSettingsUpdated(_enabled, _amount);
    }

     function updateIsUnauthorized(address account, bool state) external onlyOwner{
        _isUnauthorized[account] = state;
    }
    
    function bulkIsUnauthorized(address[] memory accounts, bool state) external onlyOwner{
        for(uint256 i =0; i < accounts.length; i++){
            _isUnauthorized[accounts[i]] = state;

        }
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD);
    }

}