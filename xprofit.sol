/**
 *Submitted for verification at BscScan.com on 2024-04-02
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol

pragma solidity ^0.8.24;

interface AutomationCompatibleInterface {
    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/AutomationBase.sol

pragma solidity ^0.8.24;

contract AutomationBase {
    error OnlySimulatedBackend();

    function preventExecution() internal view {
        if (tx.origin != address(0)) {
            revert OnlySimulatedBackend();
        }
    }

    modifier cannotExecute() {
        preventExecution();
        _;
    }
}

// File: @chainlink/contracts/src/v0.8/AutomationCompatible.sol

pragma solidity ^0.8.24;

abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}

// File: contracts/xprofit.sol

//SPDX-License-Identifier: MIT
//Experience sustainable profits and passive income with XProfit. Powered by ChainLink Automation.
//https://xprofit.app

pragma solidity 0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender) == 1, "!OWNER"); _;
    }

    function isOwner(address account) public view returns (uint256) {
        return (account == owner ? 1 : 0);
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IRewardDistributor {
    function setRewardShare(address shareholder, uint256 amount, uint256 isProfit, uint256 setShareOnly) external;
    function setRewardAmount() external;
}

contract RewardDistributor is IRewardDistributor {
    struct RewardShare {
        uint256 amount;
        uint256 totalRealised;
    }

    IERC20 reward;

    address token;
    address[] public shareholders;
    address[] public diamondHolders;

    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) diamondHolderIndexes;
    mapping(address => uint256) public isDiamondHand;
    mapping(address => mapping(uint256 => uint256)) public isDistributed;
    mapping(address => uint256) public shares;
    mapping(address => RewardShare) public rewardShares;

    uint256 public constant rewardPerShareAccuracyFactor = 10 ** 36;

    uint256 public totalCycles = 1;
    uint256 public totalRewardAmount;
    uint256 public totalShares;
    uint256 public totalRewardShares;
    uint256 public totalRewardDistributed;
    uint256 public rewardPerShare;
    uint256 public finalRewardPerShare;
    uint256 public mockPeriod = 1;
    uint256 public claimOn = 0;

    modifier onlyToken() {
        require(msg.sender == token); _;
    }

    constructor (address _reward) {
        reward = IERC20(_reward);
        token = msg.sender;
    }

    function getShareholderCount() external view returns(uint256 count) {
        return shareholders.length;
    }

    function getDiamondHolderCount() external view returns(uint256 count) {
        return diamondHolders.length;
    }

    function setCycle() external onlyToken {
        mockPeriod = 1;
        claimOn = 1;
        totalCycles++;
        finalRewardPerShare = rewardPerShare;
    }

    function setRewardShare(address shareholder, uint256 amount, uint256 isProfit, uint256 setShareOnly) external override onlyToken {
        if(setShareOnly == 1) {
            totalShares -= shares[shareholder];
            totalShares += amount;
            shares[shareholder] = amount;
        }
        else {
            uint256 setTotalRewardShares = 0;
            uint256 cachedTotalRewardShares = totalRewardShares;
            uint256 cachedRewardShares = rewardShares[shareholder].amount;

            if (claimOn == 1 && isDistributed[shareholder][totalCycles-1] == 0) {
                isDistributed[shareholder][totalCycles-1] = 1;
                distributeReward(shareholder);
            }

            if (amount == 0 && shares[shareholder] > 0) {
                removeShareholder(shareholder);
                setTotalRewardShares = 1;
            }
            else if (isProfit == 1 && isDiamondHand[shareholder] == 1) {
                removeDiamondHolder(shareholder);
                setTotalRewardShares = 1;
            }
            else if (amount > shares[shareholder]) {
                if (shares[shareholder] == 0) {
                    addShareholder(shareholder);
                }

                if (mockPeriod == 1 && isDiamondHand[shareholder] == 0 ) {
                    addDiamondHolder(shareholder);
                }
            }

            totalShares -= shares[shareholder];
            totalShares += amount;
            shares[shareholder] = amount;

            if (setTotalRewardShares == 1) {
                cachedTotalRewardShares -= cachedRewardShares;
                cachedRewardShares = 0;
            }
            else if (isProfit == 0 && isDiamondHand[shareholder] == 1) {
                cachedTotalRewardShares -= cachedRewardShares;
                cachedTotalRewardShares += amount;
                cachedRewardShares = amount;
            }

            if (cachedTotalRewardShares > 0) {
                rewardPerShare = (rewardPerShareAccuracyFactor * totalRewardAmount) / cachedTotalRewardShares;
            }
            else {
                rewardPerShare = 0;
            }

            totalRewardShares = cachedTotalRewardShares;
            rewardShares[shareholder].amount = cachedRewardShares;
        }
    }

    function distributeProjectFees(address projectFeeReceiver, uint256 amountProject) external onlyToken {
        reward.transfer(projectFeeReceiver, amountProject);
    }

    function setRewardAmount() external override onlyToken {
        claimOn = 0;
        mockPeriod = 0;
        totalRewardAmount = reward.balanceOf(address(this));
        rewardPerShare = (rewardPerShareAccuracyFactor * totalRewardAmount) / totalRewardShares;
    }

    function claimRewards() external {
        require(claimOn == 1 && rewardShares[msg.sender].amount > 0 && isDistributed[msg.sender][totalCycles-1] == 0, "No Rewards Claimable!");
        isDistributed[msg.sender][totalCycles-1] = 1;
        distributeReward(msg.sender);
    }

    function distributeReward(address shareholder) internal {
        uint256 rewardAmount = getRewards(rewardShares[shareholder].amount);
        if (rewardAmount > 0) {
            bool success = reward.transfer(shareholder, rewardAmount);
            if (success) {
                totalRewardDistributed += rewardAmount;
                rewardShares[shareholder].totalRealised += rewardAmount;
            }
            else {
                isDistributed[shareholder][totalCycles-1] = 0;
            }
        }
    }

    function getUnpaidRewardEarnings(address shareholder) external view returns (uint256) {
        if (isDistributed[shareholder][claimOn == 1 ? totalCycles - 1 : totalCycles] == 1) {return 0;}
        uint256 shareholderTotalRewards = getRewards(rewardShares[shareholder].amount);
        return shareholderTotalRewards;
    }

    function getRewards(uint256 share) internal view returns (uint256) {
        return (share * (claimOn == 1 ? finalRewardPerShare : rewardPerShare)) / rewardPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function addDiamondHolder(address shareholder) internal {
        diamondHolderIndexes[shareholder] = diamondHolders.length;
        diamondHolders.push(shareholder);
        isDiamondHand[shareholder] = 1;
        isDistributed[shareholder][totalCycles-1] = 1;
        isDistributed[shareholder][totalCycles] = 0;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        delete shareholderIndexes[shareholder];
        if (diamondHolders.length > 0 && isDiamondHand[shareholder] == 1) {
            removeDiamondHolder(shareholder);
        }
    }

    function removeDiamondHolder(address shareholder) internal {
        diamondHolders[diamondHolderIndexes[shareholder]] = diamondHolders[diamondHolders.length - 1];
        diamondHolderIndexes[diamondHolders[diamondHolders.length - 1]] = diamondHolderIndexes[shareholder];
        diamondHolders.pop();
        delete diamondHolderIndexes[shareholder];
        isDiamondHand[shareholder] = 0;
        isDistributed[shareholder][totalCycles] = 1;
    }
}

contract XProfit is IERC20, Auth, AutomationCompatibleInterface{
    IERC20 public stable;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public sbForwarder;
    address public ftOnForwarder;
    address public ftOffForwarder;
    address public pair;
    address public projectFeeReceiver;
    address public presaleAddress;
    address immutable public distributorAddress;

    string constant NAME = 'XProfit';
    string constant SYMBOL = 'XProfit';

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => uint256) public totalPurchased;
    mapping(address => uint256) public totalProfit;
    mapping(address => uint256) public isFeeExempt;
    mapping(address => uint256) public isRewardExempt;

    uint256 inSwap;
    uint256 isProfit;
    uint256 needReset;
    uint256 tokenValue;
    uint256 constant DECIMALS = 18;
    uint256 constant TOTAL_SUPPLY = (21 * 10 ** 9) * 1 ether;
    uint256 public rewardFee = 500;
    uint256 public projectFee = 200;
    uint256 public totalFee = 700;
    uint256 public feeDenominator = 10000;
    uint256 public multiplier = 10752;
    uint256 public breakeven;
    uint256 public profit;
    uint256 public launchedAt;
    uint256 public relaunchedAt;
    uint256 public initialMarketCap;
    uint256 public initialValue;
    uint256 public targetMarketCap;
    uint256 public previousMarketCap;
    uint256 public marketCapMultiplier = 10;
    uint256 public marketCapIndex = 1;
    uint256 public fullTradingTime;
    uint256 public claimTime;
    uint256 public resetOn = 1;
    uint256 public resetTimer = 90 days;
    uint256 public currentCycle = 1;
    uint256 public season = 1;
    uint256 public fullTradingOffTimer = 48 hours;
    uint256 public claimOffTimer = 24 hours;
    uint256 public fullTradingEnabled;
    uint256 public manualOps;
    uint256 public manualSwap;
    uint256 public swapThresholdPercent = 2000;
    uint256 public swapThreshold = TOTAL_SUPPLY / swapThresholdPercent;
    uint256 public swapMaxPercent = 200;
    uint256 public swapMax = TOTAL_SUPPLY / swapMaxPercent;
    uint256 public swapAgainstPair = 1;

    IDEXRouter immutable router;
    RewardDistributor immutable distributor;

    modifier swapping() { inSwap = 1; _; inSwap = 0; }

    constructor (
        address _dexRouter, address _stable
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        stable = IERC20(_stable);
        pair = IDEXFactory(router.factory()).createPair(address(this), _stable);
        allowances[address(this)][address(router)] = TOTAL_SUPPLY;
        distributor = new RewardDistributor(_stable);
        distributorAddress = address(distributor);
        isFeeExempt[msg.sender] = 1;
        isRewardExempt[msg.sender] = 1;
        isRewardExempt[pair] = 1;
        isRewardExempt[address(this)] = 1;
        isRewardExempt[DEAD] = 1;
        approve(_dexRouter, TOTAL_SUPPLY);
        approve(address(pair), TOTAL_SUPPLY);
        balances[msg.sender] = TOTAL_SUPPLY;
        projectFeeReceiver = msg.sender;
        emit Transfer(address(0), msg.sender, TOTAL_SUPPLY);
    }

    function totalSupply() external pure override returns (uint256) {return TOTAL_SUPPLY;}

    function decimals() external pure override returns (uint256) {return DECIMALS;}

    function symbol() external pure override returns (string memory) {return SYMBOL;}

    function name() external pure override returns (string memory) {return NAME;}

    function balanceOf(address account) public view override returns (uint256) {return balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, TOTAL_SUPPLY);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances[sender][msg.sender] != TOTAL_SUPPLY){
            allowances[sender][msg.sender] = sub(allowances[sender][msg.sender], amount);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b <= a, "Insufficient Allowance");
        return a - b;
    }
    }

    function subBalance(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        require(b <= a, "Insufficient Balance");
        return a - b;
    }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(balances[sender] >= amount, "Insufficient Balance");
        address cachedPair = pair;
        uint256 amountReceived;
        uint256 cachedTotalPurchasedSender = totalPurchased[sender];
        if(initialMarketCap == 0 && launchedAt != 0) {
            initialMarketCap = _getCurrentMarketCap();
            initialValue = initialMarketCap / getCirculatingSupply();
            targetMarketCap = ((initialMarketCap * (marketCapIndex * marketCapMultiplier)) * 10) / 10;
        }
        if(inSwap == 1){ return basicTransfer(sender, recipient, amount); }
        if(isFeeExempt[sender] == 0 && isFeeExempt[recipient] == 0
            && (sender == cachedPair || recipient == cachedPair)) {
            tokenValue = getTokenValue(amount);
            if(swapAgainstPair == 1) { setSwapThreshold(); }
            if(manualOps == 1) { checkFullTrading(); }
            if(recipient == cachedPair && fullTradingEnabled == 0) {
                require(tokenValue <= cachedTotalPurchasedSender, "Amount Not Allowed");
                if(manualSwap == 1 && inSwap == 0 && balances[address(this)] >= swapThreshold && _getCurrentMarketCap() > previousMarketCap) {
                    swapBack();
                }
            }
            amountReceived = isFeeExempt[sender] == 0 ? takeFee(sender, amount) : amount;
            setTotalPurchased(sender, recipient, cachedTotalPurchasedSender);
        }
        else {
            amountReceived = amount;
            if(sender == presaleAddress && launchedAt != 0) {
                uint256 presaleValue = ((initialValue * amount) * multiplier) / (1 ether * feeDenominator);
                totalPurchased[recipient] += presaleValue;
                breakeven += presaleValue;
            }
            else {
                if(cachedTotalPurchasedSender > 0) {
                    tokenValue = getTokenValue(amount);
                    if(tokenValue >= cachedTotalPurchasedSender) {
                        totalPurchased[sender] = 0;
                        totalPurchased[recipient] += cachedTotalPurchasedSender;
                    }
                    else {
                        totalPurchased[sender]-= tokenValue;
                        totalPurchased[recipient] += tokenValue;
                    }
                }
            }
        }
        balances[sender] -= amount;
        balances[recipient] += amountReceived;
        distributor.setRewardShare(sender, balances[sender], recipient != cachedPair ? 0 : isProfit, isRewardExempt[sender]);
        distributor.setRewardShare(recipient, balances[recipient], sender != cachedPair ? 0 : isProfit, isRewardExempt[recipient]);
        if(launchedAt == 0 && recipient == pair) {
            launchedAt = block.timestamp;
            relaunchedAt = block.timestamp;
        }
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = subBalance(balances[sender], amount);
        balances[recipient] += amount;
        distributor.setRewardShare(recipient, balances[recipient], 0 , isRewardExempt[recipient]);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkFullTrading() internal {
        if (fullTradingEnabled == 0 && targetMarketCap > 0 && _getCurrentMarketCap() >= targetMarketCap && (claimTime + claimOffTimer) < block.timestamp) {
            setFullTrading(1);
            setTarget();
        }
        else if (fullTradingEnabled == 1 && (fullTradingTime + fullTradingOffTimer) < block.timestamp) {
            setFullTrading(0);
        }
    }

    function setTotalPurchased(address sender, address recipient, uint256 cachedTotalPurchasedSender) internal {
        uint256 cachedTokenValue = tokenValue;
        if (recipient == pair) {
            if (cachedTokenValue >= cachedTotalPurchasedSender) {
                isProfit = cachedTokenValue > cachedTotalPurchasedSender ? 1 : 0;
                breakeven -= cachedTotalPurchasedSender;
                profit += (cachedTokenValue - cachedTotalPurchasedSender);
                totalProfit[sender] += (cachedTokenValue - cachedTotalPurchasedSender);
                totalPurchased[sender] = 0;
            }
            else {
                isProfit = 0;
                totalPurchased[sender] -= cachedTokenValue;
                breakeven -= cachedTokenValue;
            }
        }
        else {
            isProfit = 0;
            uint256 taxedValue = (cachedTokenValue * multiplier) / feeDenominator;
            totalPurchased[recipient] += taxedValue;
            breakeven += taxedValue;
        }
    }

    function setSwapThreshold() internal {
        swapThreshold = balances[pair] / swapThresholdPercent;
        swapMax = balances[pair] / swapMaxPercent;
    }

    function getTokenValue(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(stable);

        uint256[] memory amounts = router.getAmountsOut(
            amount,
            path
        );

        uint256 value = amounts[amounts.length - 1];
        return value;
    }

    function getCurrentMarketCap() external view returns (uint256) {
        return getTokenValue(1 ether) * getCirculatingSupply();
    }

    function _getCurrentMarketCap() internal view returns (uint256) {
        return getTokenValue(1 ether) * getCirculatingSupply();
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        return amount - feeAmount;
    }

    function setIsRewardExempt(address holder, uint256 exempt) external onlyOwner {
        require(holder != address(this) && holder != pair && holder != DEAD, "!Exemptable");
        isRewardExempt[holder] = exempt;
        if (exempt == 1) {
            distributor.setRewardShare(holder, 0, 1, 0);
        } else {
            distributor.setRewardShare(holder, balances[holder], 0, 0);
        }
    }

    function setIsFeeExempt(address holder, uint256 exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 _projectFee, uint256 _rewardFee) external onlyOwner {
        rewardFee = _rewardFee;
        projectFee = _projectFee;
        totalFee = _projectFee + _rewardFee;
        require(totalFee < (feeDenominator/4), "Fee > 25%");
    }

    function setInitFees(uint256 _multiplier) external onlyOwner {
        multiplier = _multiplier;
    }

    function setMarketCapMultiplier(uint256 _marketCapMultiplier, uint256 _marketCapIndex, uint256 setMarketCap) external onlyOwner {
        marketCapMultiplier = _marketCapMultiplier;
        marketCapIndex = _marketCapIndex;
        if (setMarketCap == 1) {
            targetMarketCap = ((initialMarketCap * (marketCapIndex * marketCapMultiplier)) * 10) / 10;
        }
    }

    function setProjectFeeReceiver(address _projectFeeReceiver) external onlyOwner {
        projectFeeReceiver = _projectFeeReceiver;
    }

    function overrideFullTrading(uint256 _enabled) external onlyOwner {
        setFullTrading(_enabled);
        if(_enabled == 1) {
            setTarget();
        }
    }

    function setTradingTimer(uint256 _fullTradingOffTimer, uint256 _claimOffTimer) external onlyOwner {
        fullTradingOffTimer = _fullTradingOffTimer;
        claimOffTimer = _claimOffTimer;
    }

    function setResetTimer(uint256 _resetTimer, uint256 _resetOn) external onlyOwner {
        resetTimer = _resetTimer;
        resetOn = _resetOn;
    }

    function setFullTrading(uint256 _enabled) internal {
        if (_enabled == 1) {
            fullTradingTime = block.timestamp;
        }
        else {
            distributor.setCycle();
            currentCycle++;
            claimTime = block.timestamp;
            if(needReset == 1) {
                relaunchedAt = block.timestamp;
                previousMarketCap = 0;
                currentCycle = 1;
                season++;
                needReset = 0;
            }
        }
        fullTradingEnabled = _enabled;
    }

    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
        if(keccak256(checkData) == keccak256(hex'01')) {
            upkeepNeeded = manualSwap == 0 && inSwap == 0 && balances[address(this)] >= swapThreshold && _getCurrentMarketCap() > previousMarketCap;
            performData = checkData;
        }
        else if(keccak256(checkData) == keccak256(hex'02')) {
            upkeepNeeded = manualOps == 0 && fullTradingEnabled == 0 && targetMarketCap > 0 && _getCurrentMarketCap() >= targetMarketCap && (claimTime + claimOffTimer) < block.timestamp;
            performData = checkData;
        }
        else if(keccak256(checkData) == keccak256(hex'03')) {
            upkeepNeeded = manualOps == 0 && fullTradingEnabled == 1 && (fullTradingTime + fullTradingOffTimer) < block.timestamp;
            performData = checkData;
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        if(msg.sender == sbForwarder && keccak256(performData) == keccak256(hex'01') && manualSwap == 0 && inSwap == 0 && balances[address(this)] >= swapThreshold && _getCurrentMarketCap() > previousMarketCap) {
            swapBack();
        }
        else if(msg.sender == ftOnForwarder && keccak256(performData) == keccak256(hex'02') && manualOps == 0 && fullTradingEnabled == 0 && targetMarketCap > 0 && _getCurrentMarketCap() >= targetMarketCap && (claimTime + claimOffTimer) < block.timestamp) {
            setFullTrading(1);
            setTarget();
        }
        else if(msg.sender == ftOffForwarder && keccak256(performData) == keccak256(hex'03') && manualOps == 0 && fullTradingEnabled == 1 && (fullTradingTime + fullTradingOffTimer) < block.timestamp) {
            setFullTrading(0);
        }
    }

    function swapBack() internal swapping {
        uint256 rewardAmount = stable.balanceOf(distributorAddress);
        uint256 balanceToSwap = balances[address(this)];
        previousMarketCap = _getCurrentMarketCap();

        if(swapMax != 0 && balanceToSwap > swapMax) {
            balanceToSwap = swapMax;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(stable);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balanceToSwap,
            0,
            path,
            distributorAddress,
            block.timestamp
        );

        uint256 projectAmount = ((stable.balanceOf(distributorAddress) - rewardAmount) * projectFee) / totalFee;
        distributor.distributeProjectFees(projectFeeReceiver, projectAmount);
    }

    function setTarget() internal {
        claimTime = 0;
        distributor.setRewardAmount();

        if(resetOn == 1 && (relaunchedAt + resetTimer) < block.timestamp) {
            marketCapIndex = 1;
            marketCapMultiplier = 10;
            needReset = 1;
        }
        else if(marketCapIndex == 10) {
            marketCapIndex = 1;
            marketCapMultiplier *= 10;
        }
        else {
            marketCapIndex++;
        }

        targetMarketCap = ((initialMarketCap * (marketCapIndex * marketCapMultiplier)) * 10) / 10;
    }

    function overrideSwapBack() external onlyOwner {
        swapBack();
    }

    function setManualOps(uint256 _manualOps) external onlyOwner {
        manualOps = _manualOps;
    }

    function setManualSwap(uint256 _manualSwap) external onlyOwner {
        manualSwap = _manualSwap;
    }

    function resetPreviousMarketCap(uint256 _previousMarketCap) external onlyOwner {
        previousMarketCap = _previousMarketCap;
    }

    function setSwapAgainstPair(uint256 _swapAgainstPair) external onlyOwner {
        swapAgainstPair = _swapAgainstPair;
    }

    function setSwapPercent(uint256 _swapThresholdPercent, uint256 _swapMaxPercent) external onlyOwner {
        swapThreshold = TOTAL_SUPPLY / _swapThresholdPercent;
        swapThresholdPercent = _swapThresholdPercent;
        swapMax = TOTAL_SUPPLY / _swapMaxPercent;
        swapMaxPercent = _swapMaxPercent;
    }

    function setUp(address _presaleAddress, address _sbForwarder, address _ftOnForwarder, address _ftOffForwarder) external onlyOwner {
        presaleAddress = _presaleAddress;
        isFeeExempt[_presaleAddress] = 1;
        isRewardExempt[_presaleAddress] = 1;
        distributor.setRewardShare(_presaleAddress, 0, 1, 0);
        sbForwarder = _sbForwarder;
        ftOnForwarder = _ftOnForwarder;
        ftOffForwarder = _ftOffForwarder;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_SUPPLY - balanceOf(DEAD)) - balanceOf(ZERO);
    }
}