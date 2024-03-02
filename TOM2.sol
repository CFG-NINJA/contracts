/**
 *Submitted for verification at BscScan.com on 2024-03-01
*/

//SPDX-License-Identifier: MIT

//WEB: tomcoin.app

pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
       
        _owner = msg.sender ;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender() , "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}


contract ERC20Detailed {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


interface IUniswapV2Factory {
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


interface IUniswapV2Pair {
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



interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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


                                                                                        
// TOM                                                                                         
//            ░░                                                
//                                                            
//        ██            ██                                      
//        ████    ████                                        
//    ████    ████████████████                                  
//        ████████████████▓▓▓▓██                                
//        ▓▓████▓▓▓▓▓▓▓▓▓▓██▓▓▓▓                                
//    ▓▓██▓▓▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓▓▓▓▓                              
//    ▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▓▓▓▓▓▓▓▓                              
//    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓▓▓                              
//    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                              
//    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                
//        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                  
//        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                    
//           ▓▓▓▓▓▓▓▓▓▓▓▓                                      
                                                                                        
contract TOM is Context, Ownable, IERC20, ERC20Detailed {
  
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public AMMs;
    mapping (address => bool) public blackListed;
   
    uint256 internal _totalSupply;

    uint256 immutable private _max_allowed_fee = 500; // Max fee is 5%
 
    uint256 public lPoolFee = 50;
    uint256 public walletSFee = 0;
    uint256 public walletTFee = 0;
    uint256 public walletVFee = 0;
	uint256 public walletXFee = 100;
    uint256 public walletYFee = 25;
    uint256 public walletZFee = 25;
	uint256 public buyBackBurnFee = 100;
    uint256 public foundationFee = 100;
	uint256 public _totalFee = lPoolFee + walletSFee + walletTFee + walletVFee + walletXFee + walletYFee + walletZFee + buyBackBurnFee + foundationFee;
    
    address payable public lPoolWallet = payable(0x5FD69eaB85d1a52981f2EF657B06Da8f70eD9E8a);
    address payable public SWallet = payable(0x558294679Bf4c224E471da865eb575ECf169197E);
    address payable public TWallet = payable(0x43887a6d6f0c9e27C353BcF29DC43B5217c96A23);
    address payable public VWallet = payable(0x83d2C1019Eb4974FA2f964e26a686b6a7b12a3e3);
    address payable public XWallet = payable(0x2E0dD6CBA6f1E8Cfd61666c753D22b0824F82B6E);
    address payable public YWallet = payable(0x7e093ACDfa0C752c7a4D292a7B3aCB797a3c2d1f);
    address payable public ZWallet = payable(0x78B763fc6dA53B88333bda0A125dF0e7f682Af4b);
	address payable public buyBackBurnWallet = payable(0x7bb9Da4b914a72cC5ba20b76453D9C6e2Cf84219);
    address payable public foundationWallet = payable(0x9A2ae4FA44E092c46679d1a081c5cE57bC701238);
	address public presaleWallet = owner();
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    bool public isFeeDistributionEnabled = true;
    bool public tradingEnabled;
  
    uint256 public minTokenTresholdToDistributeFee = 750000 * 10**18;
 
    event WalletUpdated(address oldWallet, address newWallet);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event UpdateFeeDistributionStatus(bool enabled);
    event TokenRemoved(address owner);
    event UpdateFeeDistributionTreshold(uint256 value);
    event ExcludedFromFee(address account);
    event IncludedInFee(address account);
    event TradingEnabled();
    event AddedInBlacklist(address account);
    event RemovedFromBlacklist(address account);
    event EthReleased(address owner);
    event UpdateFeeBase(uint256 newFee);
    event SwapAndDistributeFee(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor () ERC20Detailed("TOM", "TOM", 18) {
        
        _totalSupply = 1000000000 * (10**18);
        
        _balances[owner()] = _totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[lPoolWallet] = true;
        _isExcludedFromFee[SWallet] = true;
        _isExcludedFromFee[TWallet] = true;
        _isExcludedFromFee[VWallet] = true;
        _isExcludedFromFee[XWallet] = true;
        _isExcludedFromFee[YWallet] = true;
        _isExcludedFromFee[ZWallet] = true;
        _isExcludedFromFee[buyBackBurnWallet] = true;
        _isExcludedFromFee[foundationWallet] = true;
        _isExcludedFromFee[presaleWallet] = true;
        _isExcludedFromFee[deadWallet] = true;

        AMMs[uniswapV2Pair] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    /////////////////////////////////////////////////////////////
    /////////////////  BEP20 Standard Functions /////////////////
    /////////////////////////////////////////////////////////////

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + (addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - (subtractedValue));
        return true;
    }
      
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    /**
     * @dev Update trading status, can only be called one time to set it to true
     */
    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled();
    }

    /**
     * @dev Update lPool wallet
     * @param newWallet New lPool wallet
     */
    function changeLPoolWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        lPoolWallet = newWallet;
        emit WalletUpdated(lPoolWallet, newWallet);
        _isExcludedFromFee[lPoolWallet] = true;
    }

    /**
     * @dev Update wallet S
     * @param newWallet New wallet S
     */
    function changeSWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        SWallet = newWallet;
        emit WalletUpdated(SWallet, newWallet);
        _isExcludedFromFee[SWallet] = true;
    }

    /**
     * @dev Update wallet T
     * @param newWallet New wallet T
     */
    function changeTWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        TWallet = newWallet;
        emit WalletUpdated(TWallet, newWallet);
        _isExcludedFromFee[TWallet] = true;
    }

    /**
     * @dev Update wallet V
     * @param newWallet New wallet V
     */
    function changeVWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        VWallet = newWallet;
        emit WalletUpdated(VWallet, newWallet);
        _isExcludedFromFee[VWallet] = true;
    }

    /**
     * @dev Update wallet X
     * @param newWallet New wallet X
     */
    function changeXWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        XWallet = newWallet;
        emit WalletUpdated(XWallet, newWallet);
        _isExcludedFromFee[XWallet] = true;
    }

    /**
     * @dev Update wallet Y
     * @param newWallet New wallet Y
     */
    function changeYWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        YWallet = newWallet;
        emit WalletUpdated(YWallet, newWallet);
        _isExcludedFromFee[YWallet] = true;
    }

    /**
     * @dev Update wallet Z
     * @param newWallet New wallet Z
     */
    function changeZWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        ZWallet = newWallet;
        emit WalletUpdated(ZWallet, newWallet);
        _isExcludedFromFee[ZWallet] = true;
    }

    /**
     * @dev Update buyback and burn wallet
     * @param newWallet New buyback and burn wallet
     */
    function changeBuybackWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        buyBackBurnWallet = newWallet;
        emit WalletUpdated(buyBackBurnWallet, newWallet);
        _isExcludedFromFee[buyBackBurnWallet] = true;
    }

    /**
     * @dev Update foundation wallet
     * @param newWallet New foundation wallet
     */
    function changeFoundationWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        foundationWallet = newWallet;
        emit WalletUpdated(foundationWallet, newWallet);
        _isExcludedFromFee[foundationWallet] = true;
    }

    /**
     * @dev Update presale wallet
     * @param newWallet New presale wallet
     */
    function changePresaleWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Address Zero detected!!");
        presaleWallet = newWallet;
        emit WalletUpdated(presaleWallet, newWallet);
        _isExcludedFromFee[presaleWallet] = true;
    }

    /**
     * @dev Update fee percent
     * @param _lPoolFee lPool Wallet fee
     * @param _walletSFee Wallet S fee
     * @param _walletTFee Wallet T fee
     * @param _walletVFee Wallet V fee
     * @param _walletXFee Wallet X fee
     * @param _walletYFee Wallet Y fee
     * @param _walletZFee Wallet Z fee
     * @param _buyBackBurnFee Buyback and burn fee
     * @param _foundationFee Foundation fee
     */
    function setTeamFeePercent( 
        uint256 _lPoolFee,
        uint256 _walletSFee,
        uint256 _walletTFee,
        uint256 _walletVFee,
        uint256 _walletXFee,
        uint256 _walletYFee,
        uint256 _walletZFee,
        uint256 _buyBackBurnFee,
        uint256 _foundationFee
    ) external onlyOwner {
        lPoolFee = _lPoolFee;
        walletSFee = _walletSFee;
        walletTFee = _walletTFee;
        walletVFee = _walletVFee;
        walletXFee = _walletXFee;
        walletYFee = _walletYFee;
        walletZFee = _walletZFee;
        buyBackBurnFee = _buyBackBurnFee;
        foundationFee = _foundationFee;
        _totalFee = lPoolFee + walletSFee + walletTFee + walletVFee + walletXFee + walletYFee + walletZFee + buyBackBurnFee + foundationFee;
        require(_totalFee <= _max_allowed_fee, "Fee is crossing the boundaries");
        emit UpdateFeeBase(_totalFee);
    }

    /**
     * @dev Update fee distribution status
     * @param _enabled Fee distribution status
     */
    function updateFeeDistributionStatus(bool _enabled) public onlyOwner {
        require(_enabled != isFeeDistributionEnabled, "Can't set the same value");
        isFeeDistributionEnabled = _enabled;
        emit UpdateFeeDistributionStatus(_enabled);
    }

    /**
     * @dev Update the minimum number of tokens required to swap and distribute fees
     * @param _amount Minimum number of tokens required to swap and distribute fees
     */
    function updateFeeDistributionTreshold(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid entry");
        minTokenTresholdToDistributeFee = _amount;
        emit UpdateFeeDistributionTreshold(_amount);
    }

    /**
     * @dev Exclude/Include account from fee list
     * @param account Account to exclude/include
     */
    function excludeFromFee(address account) external onlyOwner {
         require(account != address(0), "Zero Address detected");
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }
    
    /**
     * @dev Include account in fee list
     * @param account Account to include
     */
    function includeInFee(address account) external onlyOwner {
        require(account != address(0), "Zero Address detected");
        _isExcludedFromFee[account] = false;
        emit IncludedInFee(account);
    }
    
    /**
     * @dev Add/Remove account from blacklist
     * @param account Account to add
     */
    function addInBlacklist(address account) external onlyOwner {
        require(account != address(0), "Zero Address detected");
        blackListed[account] = true;
        emit AddedInBlacklist(account);
    }

    /**
     * @dev Remove account from blacklist
     * @param account Account to remove
     */
    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "Zero Address detected");
        blackListed[account] = false;
        emit RemovedFromBlacklist(account);
    }

    /**
     * @dev Returns if account is blacklisted
     * @param account Account to check
     * @return bool
     */
    function isBlackListed(address account) public view returns (bool) {
        require(account != address(0), "Zero Address detected");
        return(blackListed[account]);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(!isBlackListed(sender) && !isBlackListed(recipient), "Blacklisted" );
        require(balanceOf(sender) >= amount, "insufficient Amount");
        require(amount > 0, "insufficient Amount");
        require(tradingEnabled == true || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "Trading not enabled yet");
         //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }
       
        if(!AMMs[recipient] && !AMMs[sender]) {
            takeFee = false;
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool isOverMinTokenBalance = contractTokenBalance >= minTokenTresholdToDistributeFee;
        if (
            isOverMinTokenBalance &&
            !AMMs[sender] &&
            isFeeDistributionEnabled &&
            takeFee
        ) {
            contractTokenBalance = minTokenTresholdToDistributeFee;
            swapAndDistributeFee(contractTokenBalance);
        }

        if(takeFee) {
            uint256 taxAmount = (amount * (lPoolFee + walletSFee + walletTFee + walletVFee + walletXFee + walletYFee + walletZFee
            + buyBackBurnFee + foundationFee)) / (10000);
            uint256 TotalSent = amount - (taxAmount);
            _balances[sender] = _balances[sender] - (amount);
            _balances[recipient] = _balances[recipient] + (TotalSent);
            _balances[address(this)] = _balances[address(this)] + (taxAmount);
            emit Transfer(sender, recipient, TotalSent);
            emit Transfer(sender, address(this), taxAmount);

        } else {
            _balances[sender] = _balances[sender] - (amount);
            _balances[recipient] = _balances[recipient] + (amount);
            emit Transfer(sender, recipient, amount);
        }
       
    }

    /** 
     * @dev Calculates the total fee
     */
    function totalFee() private view returns(uint256) {
        return (lPoolFee + walletSFee + walletTFee + walletVFee + walletXFee + walletYFee + walletZFee
            + buyBackBurnFee + foundationFee);
    }

    /**
     * @dev Swaps and distributes fee
     * @param tokensToLiquify The amount of tokens to swap and distribute
     */
    function swapAndDistributeFee(uint256 tokensToLiquify) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokensToLiquify);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToLiquify,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ethBalance = address(this).balance;

        uint256 ethForFutureLiquidity = ethBalance * (lPoolFee) / totalFee();
        uint256 ethForWalletS = ethBalance * (walletSFee) / totalFee();
        uint256 ethForWalletT = ethBalance * (walletTFee) / totalFee();
        uint256 ethForWalletV = ethBalance * (walletVFee) / totalFee();
        uint256 ethForWalletX = ethBalance * (walletXFee) / totalFee();
        uint256 ethForWalletY = ethBalance * (walletYFee) / totalFee();
        uint256 ethForWalletZ = ethBalance * (walletZFee) / totalFee();
        uint256 ethForBuyback = ethBalance * (buyBackBurnFee) / totalFee();
        uint256 ethForFoundation = ethBalance * (foundationFee) / totalFee();
    
        payable(lPoolWallet).transfer(ethForFutureLiquidity);
        payable(SWallet).transfer(ethForWalletS);
        payable(TWallet).transfer(ethForWalletT);
        payable(VWallet).transfer(ethForWalletV);
        payable(XWallet).transfer(ethForWalletX);
        payable(YWallet).transfer(ethForWalletY);
        payable(ZWallet).transfer(ethForWalletZ);
        payable(buyBackBurnWallet).transfer(ethForBuyback);
        payable(foundationWallet).transfer(ethForFoundation);
    }
    
    /**
     * @dev Swaps tokens for eth
     */
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    
    /**
     * @dev Withdraws stucked BNB from the contract
     */
    function withdrawStuckETH() external onlyOwner{
        require (address(this).balance > 0, "Can't withdraw negative or zero");
        payable(owner()).transfer(address(this).balance);
        emit EthReleased(owner());
    }

    /**
     * @dev Withdraws tokens that are sent here by mistake
     * @param _address The address of the token to withdraw
     */
    function removeStuckToken(address _address) external onlyOwner {
        require(IERC20(_address).balanceOf(address(this)) > 0, "Can't withdraw 0");

        IERC20(_address).transfer(owner(), IERC20(_address).balanceOf(address(this)));
        emit TokenRemoved(owner());
    }  
}