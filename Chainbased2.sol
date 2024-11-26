// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 _amount) external;

    function claimDividend(address _user) external;

    function getPaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function getUnpaidEarnings(address shareholder)
        external
        view
        returns (uint256);

    function totalDistributed() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        _owner = payable(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] public shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;
    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == token);
        _;
    }

    constructor() {
        token = msg.sender;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit(uint256 _amount) external override onlyToken {
        totalDividends = totalDividends.add(_amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(_amount).div(totalShares)
        );
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            IERC20Extended(token).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend(address _user) external {
        distributeDividend(_user);
    }

    function getPaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        return shares[shareholder].totalRealised;
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

// main contract
contract Chainbased is IERC20Extended, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Chainbased";
    string private constant _symbol = "BASD";
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 500_000_000 * 10 ** _decimals;

    IDexRouter public router;
    DividendDistributor public distributor;
    address public pair;
    address private constant DEAD = address(0xdead);

    uint256 liquidityFee = 45;
    uint256 reflectionFee = 50;
    uint256 burnFee = 5;

    uint256 liquidityFeeCount;
    uint256 reflectionFeeCount;
    uint256 burnFeeCount;

    uint256 public totalFee = 100;
    uint256 public feeDenominator = 10000;
    uint256 public swapThreshold = _totalSupply / 20000;
    uint256 public launchedAt;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;

    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event AutoLiquify(uint256 amountEth, uint256 amountBOG);
    event FeeExempt(address holder, bool exempt);
    event DividendExempt(address holder, bool exempt);

    constructor() {
        address router_ = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        router = IDexRouter(router_);
        pair = IDexFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );
        distributor = new DividendDistributor();

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(router)] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(router)] = true;
        isDividendExempt[address(distributor)] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[DEAD] = true;

        _allowances[address(this)][address(router)] = uint256(int(-1));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap || sender == address(distributor)) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 amountReceived;
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        if (
            isFeeExempt[sender] ||
            isFeeExempt[recipient] ||
            (sender != pair && recipient != pair)
        ) {
            amountReceived = amount;
        } else {
            uint256 feeAmount;
            feeAmount = amount.mul(totalFee).div(feeDenominator);
            amountReceived = amount.sub(feeAmount);
            takeFee(sender, feeAmount);
            setFeeCount(amount);            
        }
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, uint256 feeAmount) internal {
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
    }

    function setFeeCount(uint256 _amount) internal {
        liquidityFeeCount += _amount.mul(liquidityFee).div(feeDenominator);
        reflectionFeeCount += _amount.mul(reflectionFee).div(feeDenominator);
        burnFeeCount += _amount.mul(burnFee).div(feeDenominator);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = liquidityFeeCount.div(2);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToLiquify,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountEthLiquidity = address(this).balance.sub(balanceBefore);
        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountEthLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner(),
                block.timestamp
            );
            emit AutoLiquify(amountEthLiquidity, amountToLiquify);
        }

        if (reflectionFeeCount > 0) {
            try distributor.deposit(reflectionFeeCount) {
                _basicTransfer(address(this), address(distributor), reflectionFeeCount);
            } catch {}
        }
        if (burnFeeCount > 0) {
            _basicTransfer(address(this), DEAD, burnFeeCount);
        }

        liquidityFeeCount = 0;
        reflectionFeeCount = 0;
        burnFeeCount = 0;
    }

    function claimDividend() external swapping {
        distributor.claimDividend(msg.sender);
    }

    function getPaidDividend(address shareholder)
        public
        view
        returns (uint256)
    {
        return distributor.getPaidEarnings(shareholder);
    }

    function getUnpaidDividend(address shareholder)
        external
        view
        returns (uint256)
    {
        return distributor.getUnpaidEarnings(shareholder);
    }

    function getTotalDistributedDividend() external view returns (uint256) {
        return distributor.totalDistributed();
    }

    function removeStuckEth(address receiver, uint256 amount)
        external
        onlyOwner()
    {
        payable(receiver).transfer(amount);
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner()
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
        emit DividendExempt(holder, exempt);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner() {
        isFeeExempt[holder] = exempt;
        emit FeeExempt(holder, exempt);
    }

    function setFeePercent(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _burnFee,
        uint256 _feeDenominator
    ) public onlyOwner() {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        burnFee = _burnFee;
        totalFee = liquidityFee
            .add(reflectionFee)
            .add(burnFee);
        feeDenominator = _feeDenominator;
        require(
            totalFee <= feeDenominator.mul(12).div(1000),
            "Can't be greater than 1.2%"
        );
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner()
    {
        require(swapThreshold > 0);
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
}