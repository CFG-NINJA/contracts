// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.20;


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

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

contract Anydex is Ownable, ERC20 {

    address WETH;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    

    string constant _name = "Anydex";
    string constant _symbol = "ANYDEX";
    uint8 constant _decimals = 9; 
  

    uint256 _totalSupply = 10000000 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply / 100;
    uint256 public _maxWalletToken = _totalSupply / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    uint256 private buyLiquidityFee    = 0;
    uint256 private buyMarketingFee    = 15;
    uint256 private buyTeamFee         = 10;
    uint256 public  buyTotalFee        = buyTeamFee + buyMarketingFee + buyLiquidityFee;

    uint256 private sellLiquidityFee   = 0;
    uint256 private sellMarketingFee   = 15;
    uint256 private sellTeamFee        = 10;
    uint256 public  sellTotalFee       = sellTeamFee + sellMarketingFee + sellLiquidityFee;

    uint256 private transferFee        = 0;
    
    uint256 private lastSwap;
    address private autoLiquidityReceiver;
    address private marketingFeeReceiver;
    address private teamFeeReceiver;

    IDEXRouter public router;
    InterfaceLP private pairContract;
    address public pair;
    
    bool public TradingOpen = false;    

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 100; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor () {
        router = IDEXRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        pairContract = InterfaceLP(pair);
       
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0x38782F393d50700caE3e8Fb38C7611A2C417f23C;
        teamFeeReceiver = 0x70E37cD8e4790Aed78386a7DB8193A3BFdA98DD6;

        isFeeExempt[msg.sender] = true; 
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[address(this)] = true;
        

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) {return owner();}
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveAll(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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
        _maxWalletToken = (_totalSupply * maxWalletPercent ) / 1000;
                
    }

    function setMaxTx(uint256 maxTXPercent) external onlyOwner {
        require(maxTXPercent >= 5); 
        _maxTxAmount = (_totalSupply * maxTXPercent ) / 1000;
    }

   
  
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]){
            require(TradingOpen,"Trading not open yet");
        
           }
        
       
        if (sender != owner() || (recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && !isTxLimitExempt[recipient])){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
            
       
        checkTxLimit(sender, amount); 

        if(shouldSwapBack()){ 
            swapBack();
            lastSwap = block.number;
            }
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint256 amountReceived = (isFeeExempt[sender] || isFeeExempt[recipient]) ? amount : takeFee(sender, amount, recipient);
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
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
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

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && lastSwap != block.number;
    }

    function clearStuckETH(uint256 amountPercentage) external {
        require(isTxLimitExempt[msg.sender]);
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function swapback() external onlyOwner {
        swapBack();
    
    }

    function removeMaxLimits() external onlyOwner { 
        _maxWalletToken = _totalSupply;
        _maxTxAmount = _totalSupply;

    }

    function clearStuckToken(address tokenAddress, uint256 tokens) public returns (bool) {
        require(isTxLimitExempt[msg.sender]);
     if(tokens == 0){
            tokens = ERC20(tokenAddress).balanceOf(address(this));
        }
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }


    function StartAnyDex() public onlyOwner {
        require(!TradingOpen,"Trading already Enabled.");
        TradingOpen = true;
        lastSwap = block.number;
    }

    function swapBack() internal swapping {
        uint256 totalFee = buyTotalFee + sellTotalFee;
        uint256 liquidityFee = buyLiquidityFee + sellLiquidityFee;
        uint256 marketingFee = buyMarketingFee + sellMarketingFee;
        uint256 teamFee = buyTeamFee + sellTeamFee;

        uint256 amountToLiquify = ((swapThreshold * liquidityFee) / totalFee) / 2;
        uint256 amountToSwap = swapThreshold - amountToLiquify;

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

        uint256 amountETH = address(this).balance;

        uint256 totalETHFee = totalFee - (liquidityFee / 2);
        
        uint256 amountETHLiquidity = (amountETH * liquidityFee) / (totalETHFee * 2);
        uint256 amountETHMarketing = (amountETH * marketingFee) / totalETHFee;
        uint256 amountETHteam = (amountETH * teamFee) / totalETHFee;

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountETHMarketing}("");
        (tmpSuccess,) = payable(teamFeeReceiver).call{value: amountETHteam}("");
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

    function exemptAll(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        isTxLimitExempt[holder] = exempt;
    }

    function setTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }


    function updateBuyFees(uint256 _liquidityFee, uint256 _teamFee, uint256 _marketingFee) external onlyOwner {
        require(_liquidityFee + _teamFee+ _marketingFee < 30, "Fees can not be more than 30%"); 
        buyLiquidityFee = _liquidityFee;
        buyTeamFee = _teamFee;
        buyMarketingFee = _marketingFee;
        buyTotalFee = _liquidityFee + _teamFee+ _marketingFee;
    }

    function updateSellFees(uint256 _liquidityFee, uint256 _teamFee, uint256 _marketingFee) external onlyOwner {
        require(_liquidityFee + _teamFee+ _marketingFee < 30, "Fees can not be more than 30%"); 
        sellLiquidityFee = _liquidityFee;
        sellTeamFee = _teamFee;
        sellMarketingFee = _marketingFee;
        sellTotalFee = _liquidityFee + _teamFee+ _marketingFee;
    }

    function updateReceiverWallets(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _teamFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        teamFeeReceiver = _teamFeeReceiver;
    }

    function editSwapbackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount * 10**_decimals;
    }

    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD)- balanceOf(ZERO);
    }



event AutoLiquify(uint256 amountETH, uint256 amountTokens);

}