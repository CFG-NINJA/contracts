// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IPair {
    function sync() external;
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint256);
    function mint(address to) external returns (uint liquidity);
}
interface IWETH {
    function deposit() external payable;
}

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

abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
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

abstract contract TimeBasedRewards {
    struct Holder {
        bool exists;            // 用户是否已经添加
        uint256 balance;      // 个人 Hold token 数量
        uint256 rewardDebt; // 用户上次的奖励债务
    }

    mapping(address => Holder) public holder;
    address[] public holders;

    uint256 public startTime;  // 奖励开始时间
    uint256 public lastUpdateTime;  // 上次更新奖励的时间戳
    uint256 public rewardPerHold;  // 每单位 Hold Token 的累计奖励
    uint256 public currentIndex;

    function __TimeBasedDividend_init() internal {
        startTime = block.timestamp;
        // 合约启动时的时间戳
        lastUpdateTime = startTime;
    }

    // 更新全局奖励（基于时间间隔）
    function _updateReward() internal {
        if (block.timestamp == lastUpdateTime) return;
        uint256 totalHold = getHoldTotal();
        if (totalHold == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }
        // 计算自上次更新以来经过的时间（秒）
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        if (timeElapsed > 0) {
            // 获取当前每秒的奖励
            uint256 rewardToDistribute = _getCurrentRewardPerSecond() * timeElapsed;
            // 计算在该时间段内应该分发的总奖励
            rewardPerHold += rewardToDistribute / totalHold;
            // 更新全局的 rewardPerHold
            lastUpdateTime = block.timestamp;
        }
    }

    // 用户领取奖励
    function _distributeReward(address user) internal returns(bool) {
        _updateReward();
        // 先更新全局奖励
        uint256 userHold = getUserHold(user);
        uint256 userRewardDebt = userHold * rewardPerHold;
        if (userRewardDebt > holder[user].rewardDebt) {
            uint256 pendingReward = userRewardDebt - holder[user].rewardDebt;
            if (pendingReward > 0) {// 更新用户的奖励债务
                holder[user].rewardDebt = userRewardDebt;
                _transferRewardsToUser(user, pendingReward);
                return true;
            }
        } else {
            holder[user].rewardDebt = userRewardDebt;
        }
        return false;
    }

    // 增持，更新奖励
    function _increaseHold(address user, uint256 amount) internal {
        if (!holder[user].exists) {
            holder[user].exists = true;
            holders.push(user);
        } else {
            _distributeReward(user);
        }
        // 更新用户的 Hold 持有量和奖励债务
        holder[user].balance += amount;
        // 因为更新了余额,所以偿还债务要更新到最新余额标准
        holder[user].rewardDebt = holder[user].balance * rewardPerHold;
    }

    // 减持
    function _decreaseHold(address user, uint256 amount) internal {
        if (!holder[user].exists) return;
        // 先结算用户的奖励
        _distributeReward(user);

        // 更新用户的 Hold 持有量和奖励债务
        if (getUserHold(user) <= amount) {
            holder[user].balance = 0;
        } else {
            holder[user].balance -= amount;
        }
        holder[user].rewardDebt = holder[user].balance * rewardPerHold;
    }

    // 用户持有量
    function getUserHold(address user) public virtual view returns (uint256) {user; require(false, "must override this method"); return 0;}
    // 总持有量
    function getHoldTotal() public virtual view returns (uint256) {require(false, "must override this method"); return 0;}
    // 发放奖励给用户
    function _transferRewardsToUser(address user, uint256 amount) internal virtual {user; amount; require(false, "must override this method");}
    // 获取当前阶段的每秒奖励
    function _getCurrentRewardPerSecond() internal virtual view returns (uint256) {require(false, "must override this method"); return 0;}

    // 每次分一个,但是要考虑多次分不到,gas空耗的问题
    function processRewards(uint256 processGasAmount) internal {
        uint256 shareholderCount = holders.length;
        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        while (gasUsed < processGasAmount && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
                break;
            }
            if (_distributeReward(holders[currentIndex])) {
                currentIndex++;
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                }
                break;
            }
            currentIndex++;
            iterations++;
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
        }
    }
}

abstract contract UniSwapPoolEthUSDT is ERC20 {
    address public pair;
    address public pairUsdt;
    address public usdt;
    IRouter public router;
    address[] public buyPath;
    address[] public sellPath;
    uint8 public rateWeth2Usdt = 25;
    constructor(address _router, address _usdt) {
        usdt = _usdt;
        router = IRouter(_router);
        IERC20(router.WETH()).approve(_router, ~uint256(0));

        buyPath.push(router.WETH());
        buyPath.push(address(this));

        sellPath.push(address(this));
        sellPath.push(router.WETH());
    }
    function initPair() internal {
        if (pair == address(0)) pair = IFactory(router.factory()).getPair(router.WETH(), address(this));
        if (pairUsdt == address(0)) pairUsdt = IFactory(router.factory()).getPair(usdt, address(this));
    }
    function isPair(address _pair) internal view returns (bool) {return pair == _pair || pairUsdt == _pair;}
    function isAddLiquidity(uint256 amountToken) internal view returns (bool isAddLP, uint256 amountLP){
        (isAddLP, amountLP) = isAddLiquidityWeth(amountToken);
        if (isAddLP) return (isAddLP, amountLP);
        return isAddLiquidityUsdt(amountToken);
    }
    function isAddLiquidityWeth(uint256 amountToken) internal view returns (bool isAddLP, uint256 amountLP){
        return _isAddLiquidity(pair, amountToken);
    }
    function isAddLiquidityUsdt(uint256 amountToken) internal view returns (bool isAddLP, uint256 amountLP){
        (isAddLP, amountLP) = _isAddLiquidity(pairUsdt, amountToken);
        return (isAddLP, amountLP / rateWeth2Usdt);
    }
    function _isAddLiquidity(address _pair, uint256 amountToken) internal view returns (bool isAddLP, uint256 amountLP){
        address token0 = IPair(_pair).token0();
        address token1 = IPair(_pair).token1();
        (uint r0,uint r1,) = IPair(_pair).getReserves();
        uint bal0 = IERC20(token0).balanceOf(_pair);
        uint bal1 = IERC20(token1).balanceOf(_pair);
        uint256 pairSupply = IPair(_pair).totalSupply();
        if (token0 == address(this)) {
            if (bal1 > r1+1000) {
                isAddLP = true;
                amountLP = amountToken*pairSupply/r1;
            }
        } else {
            if (bal0 > r0+1000) {
                isAddLP = true;
                amountLP = amountToken*pairSupply/r0;
            }
        }
        return (isAddLP, amountLP);
    }
    function isRemoveLiquidity() internal view returns (bool isRemoveLP, uint256 amountLP) {
        (isRemoveLP, amountLP) = isRemoveLiquidityETH();
        if (isRemoveLP) return (isRemoveLP, amountLP);
        (isRemoveLP, amountLP) = isRemoveLiquidityUSDT();
        return (isRemoveLP, amountLP);
    }
    function isRemoveLiquidityETH() internal view returns (bool isRemoveLP, uint256 amountLP) {
        return _isRemoveLiquidity(pair);
    }
    function isRemoveLiquidityUSDT() internal view returns (bool isRemoveLP, uint256 amountLP) {
        (isRemoveLP, amountLP) = _isRemoveLiquidity(pairUsdt);
        amountLP /= rateWeth2Usdt;
        return (isRemoveLP, amountLP);
    }
    function _isRemoveLiquidity(address _pair) internal view returns (bool isRemoveLP, uint256 amountLP) {
        address token0 = IPair(_pair).token0();
        if (token0 == address(this)) return (isRemoveLP, amountLP);
        uint256 pairSupply = IPair(_pair).totalSupply();
        (uint r0,,) = IPair(_pair).getReserves();
        uint bal0 = IERC20(token0).balanceOf(_pair);
        if (r0 > bal0+1000) {
            isRemoveLP = true;
            uint256 diff = r0 - bal0;
            amountLP = diff * pairSupply / r0;
        }
        return (isRemoveLP, amountLP);
    }
    function swapAndSend2fee(uint256 amount, address to) internal {
        swapAndSend2feeWithPath(amount, to, sellPath);
    }
    function swapAndSend2feeWithPath(uint256 amount, address to, address[] memory path) internal {
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
    }
    function getPredictPairBAmount(uint256 amountA, address tokenA) internal view returns(uint256 amountB) {
        if (tokenA == buyPath[0]) {
            return router.getAmountsOut(amountA, buyPath)[1];
        } else {
            return router.getAmountsOut(amountA, sellPath)[1];
        }
    }
}

abstract contract BicMining is TimeBasedRewards, UniSwapPoolEthUSDT {
    // 奖励阶段参数（按秒计算奖励）
    uint256 public rewardPhase1;  // 第1-10天每秒的奖励
    uint256 public rewardPhase2;  // 第11-20天每秒的奖励
    uint256 public rewardPhase3;  // 20天后的每秒奖励
    bool public isMiningFinished;   // 挖矿是否结束

    function __BicMining_init() internal {
        rewardPhase1 = expend(200 ether) / 1 days;
        rewardPhase2 = expend(100 ether) / 1 days;
        rewardPhase3 = expend(50 ether) / 1 days;
        super.__TimeBasedDividend_init();
    }

    function expend(uint256 num) internal pure returns (uint256) {return num * 1 ether;}
    function reduce(uint256 num) internal pure returns (uint256) {return num / 1 ether;}

    // 获取当前阶段的每秒奖励
    function _getCurrentRewardPerSecond() internal virtual override view returns (uint256) {
        uint256 elapsedDays = (block.timestamp - startTime) / 1 days;
        if (elapsedDays < 10) {
            return rewardPhase1;
        } else if (elapsedDays < 20) {
            return rewardPhase2;
        } else {
            return rewardPhase3;
        }
    }
    function _transferRewardsToUser(address user, uint256 amount) internal virtual override {
        amount = reduce(amount);
        if (balanceOf(address(1)) < amount) {
            isMiningFinished = true;
            return;
        }
        super._transfer(address(1), user, amount);
    }
    // 用户持有量
    function getUserHold(address user) public virtual override view returns (uint256) {
        uint256 balanceWethLP = IERC20(pair).balanceOf(user);
        uint256 balanceUSDTLP = IERC20(pairUsdt).balanceOf(user);
        return min(balanceWethLP + balanceUSDTLP/rateWeth2Usdt, holder[user].balance);
    }
    function min(uint256 a, uint256 b) private pure returns(uint256) {
        return a<b?a:b;
    }
    // 总持有量
    function getHoldTotal() public virtual override view returns (uint256) {
        uint256 wethTotal = IPair(pair).totalSupply();
        uint256 usdtTotal = IPair(pairUsdt).totalSupply();
        uint256 blackHoleWethTotal = IERC20(pair).balanceOf(address(0));
        uint256 blackHoleUsdtTotal = IERC20(pairUsdt).balanceOf(address(0));
        return wethTotal - blackHoleWethTotal + (usdtTotal - blackHoleUsdtTotal) / rateWeth2Usdt;
    }
    function process() internal {
        if (isMiningFinished) return;
        super.processRewards(250000);
    }
}

contract BICCoin is BicMining {
    uint8 public trading; // 0 init, 1 eth pool added, 2 trading
    uint8 public tax = 2;
    uint256 public feeTo1PercentAt; // fee to 1% after 1 year
    address public feeTo;
    mapping(address => bool) public exclades;

    constructor(address _router, address _usdt, address _wallet, address _feeTo, uint256 _toAmount) ERC20("BIC Coin", "BIC") UniSwapPoolEthUSDT(_router, _usdt) {
        feeTo = _feeTo;
        exclades[_wallet] = true;
        exclades[_feeTo] = true;
        exclades[address(this)] = true;
        exclades[address(1)] = true;
        uint256 _supply = 21e6 ether;
        super._update(address(0), _wallet, _toAmount);
        super._update(address(0), address(1), _supply - _toAmount);
        super._approve(address(this), _router, ~uint256(0));
    }
    function _update(address from, address to, uint256 amount) internal virtual override {
        if (trading == 0 && exclades[from]) {   // waiting for weth liquidity
            trading = 1;
            super._update(from, to, amount);
            return;
        }
        if (trading == 1 && exclades[from]) {   // waiting for usdt liquidity
            trading = 2;
            feeTo1PercentAt = block.timestamp + 365*24*3600;
            super._update(from, to, amount);
            super.__BicMining_init();
            return;
        }
        require(trading == 2, "Please waiting for trading");
        if (exclades[from] || exclades[to]) {
            super._update(from, to, amount);
            return;
        }

        super.initPair();
        super.process(); // 挖矿奖励
        if (block.timestamp >= feeTo1PercentAt && tax == 2) tax = 1;
        uint256 fee;
        if (isPair(from)) {
            (bool isRemoveLP, uint256 amountLP) = super.isRemoveLiquidity();
            if (isRemoveLP) {
                if (to != address(router)) {
                    _decreaseHold(to, amountLP);
                }
            }
            if (to != address(router)) {
                fee = amount * tax / 100;
            }
        } else if (isPair(to)) {
            (bool isAddLP, uint256 amountLP) = super.isAddLiquidity(amount);
            if (isAddLP) {
                _increaseHold(from, amountLP);
            } else {
                fee = amount * tax / 100;   // 20000000000000000
                // 卖单触发兑换手续费
                if (!inSwap && balanceOf(address(this)) >= 10 ether) {
                    handSwap();
                }
            }
        } else if (from == address(router)) {
            fee = amount * tax / 100;
            address token0 = IPair(pair).token0();
            if (token0 != address(this)) {
                uint256 pairSupply = IPair(pair).totalSupply();
                (,uint r1,) = IPair(pair).getReserves();
                uint256 amountLP = amount * pairSupply / r1;
                _decreaseHold(to, amountLP);
            }
        }
        if (fee > 0) {
            super._update(from, address(this), fee);
            amount -= fee;
        }
        super._update(from, to, amount);
    }
    function handSwap() private {
        super.swapAndSend2fee(balanceOf(address(this)), feeTo);
    }

    bool inSwap;
    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    receive() external payable {
        require(!inSwap, "in swapping");
        require(msg.value > 1 gwei, "amount must gt 1 gwei");
        autoLiquidity(msg.value);
    }
    function autoLiquidity(uint256 value) private lockSwap {
        uint256 fee = value * 2 / 100;
        payable(feeTo).transfer(fee);
        value -= fee;
        uint256 half = value/2;
        IWETH(router.WETH()).deposit{value:value}();

        uint256 amountToken = super.getPredictPairBAmount(half, router.WETH());
        super._update(pair, address(this), amountToken);
        IERC20(router.WETH()).transfer(pair, value-half);
        IPair(pair).sync();

        (,, uint256 liquidity) = router.addLiquidity(router.WETH(),address(this),half,amountToken,0,0,_msgSender(),block.timestamp);
        super._increaseHold(_msgSender(), liquidity);
    }
}