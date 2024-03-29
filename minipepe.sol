/**
 *Submitted for verification at BscScan.com on 2024-03-14
*/

/**
---------------------------------------------------------------------------------------------------
 Contract Developed by Renowned SAFU Dev on BSC/ETH: 
 t.me/AnoopSafuDeveloper

 [DM for any Smart Contract/DApp development]
---------------------------------------------------------------------------------------------------
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

       function transferOwnership(address newOwner) public virtual onlyOwner() {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
      
       function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract MiniPepe is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    address payable private MarketingWallet;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 420000000000000 * 10**_decimals; 
    string private constant _name = "MiniPepe Coin";
    string private constant _symbol = "MiniPepe";
    uint256 private _minSwapTokens = 840000000000 * 10**_decimals; 
    uint256 private _maxSwapTokens = 8400000000000 * 10**_decimals; 
    uint256 public buyTaxes = 5;
    uint256 public sellTaxes = 5;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool public tradeEnable = false;
    bool private _SwapBackEnable = false;
    bool private inSwap = false;
   
    //Contract Update Information
    string public constant Contract_Version = "0.8.20";
    string public constant Contract_Dev = "Anoop SAFU DEV || NFA,DYOR"; 
    string public constant Contract_Edition = "CA For Presale";
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;

    // Events
    event FeesUpdated(uint256 indexed _feeAmount);
    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event SwapBackSettingUpdated(bool indexed state);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event ETHBalanceRecovered();
    event TradingOpenUpdated();

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
           if (block.chainid == 56){
     uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PCS BSC Mainnet Router
     }
      else if(block.chainid == 1 || block.chainid == 5){
          uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap ETH Mainnet Router
      }
      else if(block.chainid == 42161){
           uniswapV2Router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // Sushi Arbitrum Mainnet Router
      }
     else  if (block.chainid == 97){
     uniswapV2Router = IUniswapV2Router02(0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248); // PCS BSC Testnet PinkSale Router
     }
    else {
         revert("Wrong Chain Id");
        }
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
         MarketingWallet = payable(0x987CC3bA027fdcD09E900616cC5841Ba8fe68BAf);
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[MarketingWallet] = true;
        _isExcludedFromFee[deadWallet] = true;
        _isExcludedFromFee[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true; // BSC PinkSale Locker
    
        _balances[0x987CC3bA027fdcD09E900616cC5841Ba8fe68BAf] = _tTotal;
        emit Transfer(address(0), 0x987CC3bA027fdcD09E900616cC5841Ba8fe68BAf, _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
   function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 feesum = 0;

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {    
              require(tradeEnable, "Trading not enabled");  
               feesum = amount * buyTaxes / 100;
        }
        
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            feesum = 0;
        } 
        
          if (to == uniswapV2Pair && from != address(this) && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                    feesum = amount * sellTaxes / 100;
                
                } 
       
             uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && _SwapBackEnable && contractTokenBalance > _minSwapTokens) {
                 swapTokensForEth(min(amount, min(contractTokenBalance, _maxSwapTokens)));
               uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        
        _balances[from] = _balances[from] - amount; 
        _balances[to] = _balances[to] + (amount - (feesum));
        emit Transfer(from, to, amount - (feesum));
        
         if(feesum > 0){
          _balances[address(this)] = _balances[address(this)] + (feesum);
          emit Transfer(from, address(this),feesum);
        }
    }
   
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        require(tokenAmount > 0, "amount must be greeter than 0");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
       require(amount > 0, "amount must be greeter than 0");
        MarketingWallet.transfer(amount);
    }

     function setTrading() external onlyOwner() {
        require(!tradeEnable,"trading is already open");
        _SwapBackEnable = true;
         tradeEnable = true;
       emit TradingOpenUpdated();
    }  
  
   function whitelistWallet(address account) external onlyOwner {
      require(_isExcludedFromFee[account] != true,"Account is already excluded");
       _isExcludedFromFee[account] = true;
    emit ExcludeFromFeeUpdated(account);
   }
   
   function removeWhitelistWallet(address account) external onlyOwner {
         require(_isExcludedFromFee[account] != false, "Account is already included");
        _isExcludedFromFee[account] = false;
     emit includeFromFeeUpdated(account);
    }
   
    function setFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(newBuyFee <= 10 && newSellFee <= 10, "ERC20: wrong tax value!");
        buyTaxes = newBuyFee;
        sellTaxes = newSellFee;
    }

    receive() external payable {}
   
    function rescueBEP20(address _tokenAddy, uint256 _amount) external onlyOwner {
        require(_tokenAddy != address(this), "Owner can't claim contract's balance of its own tokens");
        require(_amount > 0, "Amount should be greater than zero");
        require(_amount <= IERC20(_tokenAddy).balanceOf(address(this)), "Insufficient Amount");
        IERC20(_tokenAddy).transfer(MarketingWallet, _amount);
      emit ERC20TokensRecovered(_amount); 
    }
 
 function rescueBNB() external {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(contractETHBalance <= address(this).balance, "Insufficient Amount");
        payable(address(MarketingWallet)).transfer(contractETHBalance);
      emit ETHBalanceRecovered();
    }
}