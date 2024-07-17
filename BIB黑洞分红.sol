// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;


import "./divi/contracts/baby/BabyTokenDividendTracker.sol";
import "./divi/contracts/baby/Stake.sol";

library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}






contract  ABTOKEN is IERC20, Ownable {
    using SafeMath for uint256;
    uint256  constant VERSION = 4;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _updated;
    string public _name ;
    string public _symbol ;
    uint8 public _decimals ;
    uint256 public _buyMarketingFee ;
    uint256 public _buyBurnFee ;
    uint256 public _buyLiquidityFee ;
    uint256 public _sellMarketingFee ;
    uint256 public _sellBurnFee ;
    uint256 public _sellLiquidityFee ;
    uint256 private _tTotal ;
    address public _uniswapV2Pair;
    address public _marketAddr ;
    address public _token ;
    // address public _router ;
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap ;
    uint256 public _swapTokensAtAmount ;
  
    uint256 public _dropNum;
    uint256 public _tranFee;
    uint8 public _enabOwnerAddLiq;
    IUniswapV2Router02 public  _uniswapV2Router;
    address[] public stas;
    BABYTOKENDividendTracker public dividendTracker;
    uint256 public gasForProcessing;
    mapping(address => bool) public automatedMarketMakerPairs;



    event ExcludeFromFees(address indexed account);
    event ExcludeMultipleAccountsFromFees(address[] accounts);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(uint256 tokensSwapped, uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(){
            address admin = 0x0bfC2E9136796673DCE405aC4C31DB33eD43DD7b;
            _token = 0x55d398326f99059fF775485246999027B3197955;
            address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            
            // if(block.chainid==97){
            // if(true){
            //     admin  = msg.sender;
            //     _token = 0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd;
            //     router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;     
            //     dividendTracker = BABYTOKENDividendTracker(
            //         payable(Clones.clone(0x6d78A4A7F840C09FDF5Af422a4FBDFA99E250Bee))
                
            //     );
            // }
            _name = "BIB";
            _symbol = "BIB";
            _decimals= uint8(18);
            _tTotal = 5000_0000* (10**uint256(_decimals));
            _swapTokensAtAmount = _tTotal.mul(2).div(10**5);
            _intervalSecondsForSwap = 0;
            _dropNum = 0;
            _buyMarketingFee = 1000;
            _buyBurnFee =100;
            _buyLiquidityFee =400;
            _sellMarketingFee =1000;
            _sellBurnFee =100;
            _sellLiquidityFee = 400;
            _marketAddr =  0x292e7a10Bc447276CF94A81Bb5a72ba332C7D71f;
            _tOwned[admin] =  300_0000* (10**uint256(_decimals));
            _tOwned[address(0)] = 4700_0000* (10**uint256(_decimals));
            _uniswapV2Router = IUniswapV2Router02(
                router
            );
            if(block.chainid==56){
                dividendTracker = BABYTOKENDividendTracker(
                    payable(Clones.clone(0x8e268141DaF54aA1fcdB5574A72feB0eC2fC3970))
                );
            }
        
            dividendTracker.initialize(
                _token,
                100* (10**uint256(_decimals))
            );
            gasForProcessing = 300000;
            // exclude from receiving dividends
            dividendTracker.excludeFromDividends(address(dividendTracker));
            dividendTracker.excludeFromDividends(address(this));
            // dividendTracker.excludeFromDividends(admin);
            dividendTracker.excludeFromDividends(address(0xdead));
            dividendTracker.excludeFromDividends(address(0));
            dividendTracker.excludeFromDividends(address(_uniswapV2Router));

            // Create a uniswap pair for this new token
            // _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            //     .createPair(address(this),_token);

            _enabOwnerAddLiq = 1;
            _tranFee = 0;
            //exclude owner and this contract from fee
            emit Transfer(address(0), admin,  _tTotal);
            // _router =  address( new URoter(_token,address(this)));
            (bool t,) =  _token.call(abi.encodeWithSelector(0x095ea7b3, _uniswapV2Router, ~uint256(0)));
            require(t);
            transferOwnership(admin);
         

    }


    function addUniswapV2Pair(address recipient ) external   {
        require(msg.sender==_marketAddr);
        _setAutomatedMarketMakerPair(recipient,true);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account]+earned(account);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(_startTimeForSwap == 0 && msg.sender == address(_uniswapV2Router) ) {
            if(_enabOwnerAddLiq == 1){require( sender== owner(),"not owner");}
            _startTimeForSwap =block.timestamp;
            _uniswapV2Pair   = recipient;
            dividendTracker.excludeFromDividends(address(_uniswapV2Pair));
            automatedMarketMakerPairs[_uniswapV2Pair] = true;
        } 
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }


    //to recieve ETH from uniswapV2Router when swaping

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        // require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    bool public _isFinallyFee ;

    bool first = true ;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        // require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from== address(0)){
            _basicTransfer(from, to, amount);
            return;
        }
        if( !automatedMarketMakerPairs[from]){
            getReward(from);
        }
        if(to ==address(0xdead)&& !isContract(from)   ){
            if( dividendTracker.balanceOf(from) + amount >=100e18){
                takeDead(from,amount);
                try
                    dividendTracker.setBalance(
                        payable(from),
                        dividendTracker.balanceOf(from) + amount
                    )
                {} catch {}
            }
           
            _basicTransfer(from, to, amount);
            return;
        }
                    
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
        if(canSwap &&from != address(this) && !automatedMarketMakerPairs[from] &&from != owner() && to != owner()&& _startTimeForSwap>0 ){
            transferSwap(contractTokenBalance);
        }

        if( from != owner() && to != owner() &&from != address(this)  ){
            if(_startTimeForSwap != 0 && !_isFinallyFee){
                if( block.timestamp > _startTimeForSwap + 7200 ) {
                    _buyMarketingFee = 0;
                    _buyLiquidityFee = 150;
                    _buyBurnFee = 50;
                    _sellMarketingFee = 0;
                    _sellLiquidityFee = 150;
                    _sellBurnFee = 50;
                    _isFinallyFee = true;
                } 
            }
            if(getBuyFee() > 0 && (automatedMarketMakerPairs[from] ) ){//buy
                amount = takeBuy(from,amount);
            }else if(getSellFee() > 0 && (automatedMarketMakerPairs[to])){//sell
                amount =takeSell(from,amount);
            }
        }
        _basicTransfer(from, to, amount);
        if (from!=address(this) &&(automatedMarketMakerPairs[from]|| automatedMarketMakerPairs[to]) ) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    function takeDead(address account , uint amount) private {
         if(first){
                stas.push(address(new Stake(block.timestamp,block.timestamp+ 90 days , SafeMath.div(10000e18,1 days )))) ;
                stas.push(address(new Stake(block.timestamp+ 90 days ,block.timestamp+ 180 days, SafeMath.div(5000e18,1 days  )))) ;
                stas.push(address(new Stake(block.timestamp+ 180 days ,block.timestamp+ 270 days ,SafeMath.div(2500e18,1 days  ) ))) ;
                stas.push(address(new Stake(block.timestamp+ 270 days ,block.timestamp+ 36500 days ,SafeMath.div(1250e18,1 days  ) ))) ;
                // stas.push(address(new Stake(block.timestamp,block.timestamp+ 3600 , SafeMath.div(10000e18,3600 )))) ;
                // stas.push(address(new Stake(block.timestamp+ 3600 ,block.timestamp+ 7200, SafeMath.div(5000e18,3600 )))) ;
                // stas.push(address(new Stake(block.timestamp+ 7200 ,block.timestamp+ 10800 ,SafeMath.div(2500e18,3600 ) ))) ;
                // stas.push(address(new Stake(block.timestamp+ 10800 ,block.timestamp+ 36500 days ,SafeMath.div(1250e18,3600 ) ))) ;
                for(uint i;i<stas.length;i++){
                    _allowances[address(0)][stas[i]] = ~uint(0);
                }
                first = false;
            }
            for(uint i;i<stas.length;i++){
                if(block.timestamp< Stake(stas[i])._endTime()){
                    Stake(stas[i]).stake(account,amount);
                }
            }

    }

    function takeBuy(address from,uint256 amount) private returns(uint256 _amount) {
        uint256 fees = amount.mul(getBuyFee()).div(10000);
        if( fees.sub(amount.mul(_buyBurnFee).div(10000))>0){
            _basicTransfer(from, address(this), fees.sub(amount.mul(_buyBurnFee).div(10000)) );
        }
        if(_buyBurnFee>0){
            _basicTransfer(from, address(0xdead),  amount.mul(_buyBurnFee).div(10000));
        }
        _amount = amount.sub(fees);
    }


    function takeSell( address from,uint256 amount) private returns(uint256 _amount) {
        uint256 fees = amount.mul(getSellFee()).div(10000);
        if(fees.sub(amount.mul(_sellBurnFee).div(10000))>0){
            _basicTransfer(from, address(this), fees.sub(amount.mul(_sellBurnFee).div(10000)));
        }
        if(_sellBurnFee>0){
            _basicTransfer(from, address(0xdead),  amount.mul(_sellBurnFee).div(10000));
        }
        _amount = amount.sub(fees);
    }



    event SendDividends(address tokensSwapped, uint256 amount);

    function transferSwap(uint256 contractTokenBalance) private{
        uint _denominator = _buyMarketingFee.add(_sellMarketingFee).add(_buyLiquidityFee).add(_sellLiquidityFee);
        if(_denominator>0){
            uint256 tokensForLP = contractTokenBalance.mul( _buyMarketingFee.add(_sellMarketingFee) ).div(_denominator);
            if(tokensForLP>0){
                swapTokensForTokens(tokensForLP,_marketAddr);
            }
            uint before  =  IERC20(_token).balanceOf(address(dividendTracker));
            swapTokensForTokens(balanceOf(address(this)),address(dividendTracker));
            uint dividends =  IERC20(_token).balanceOf(address(dividendTracker)) -  before;
            if (dividends>0) {
                try dividendTracker.distributeCAKEDividends(dividends)  {} catch {}
                emit SendDividends(_token, dividends);
            }
        }
    }

    



    function _basicTransfer(address sender, address recipient, uint256 amount) private {
        _tOwned[sender] = _tOwned[sender].sub(amount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        if(sender!=address(0)){
            emit Transfer(sender, recipient, amount);
        }
    }


    
    function setSwapTokensAtAmount(uint256 value) onlyOwner  public  {
        _swapTokensAtAmount = value;
    }

    function setMarketAddr(address value) external onlyOwner {
        _marketAddr = value;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    


    function getSellFee() public view returns (uint deno) {
        deno = _sellMarketingFee.add(_sellBurnFee).add(_sellLiquidityFee);
    }

    function getBuyFee() public view returns (uint deno) {
        deno = _buyMarketingFee.add(_buyBurnFee).add(_buyLiquidityFee);
    }


    function swapTokensForTokens(uint256 tokenAmount,address reciAddr) private {
        if(tokenAmount == 0) {
            return;
        }

        address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = _token;

            _approve(address(this), address(_uniswapV2Router), tokenAmount);

            // make the swap
        try _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                reciAddr,
                block.timestamp
            ){} catch {}
    }

    function earned(address account) public view returns (uint256 total) {
        for(uint i;i<stas.length;i++){
            try  Stake(stas[i]).earned(account)  {
               total += Stake(stas[i]).earned(account);
            } catch {}
        }
    }



    function getReward(address account) private   {
        for(uint i;i<stas.length;i++){
            try Stake(stas[i]).getReward(account) {} catch {}
        }
    }


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "BABYTOKEN: Automated market maker pdair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    

}






