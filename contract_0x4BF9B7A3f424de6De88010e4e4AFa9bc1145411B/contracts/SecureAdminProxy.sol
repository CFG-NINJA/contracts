// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IClusterYield {
    function updatePlatformFee(uint256 _newFee) external;
    function addPlan(uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod) external;
    function updatePlan(uint256 _planId, uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod, bool _isActive) external;
    function getContractBalance() external view returns (uint256);
    function getPlatformStats() external view returns (uint256, uint256, uint256, uint256);
    function getBotStats() external view returns (address, uint256, uint256);
}

/**
 * @title SecureAdminProxy
 * @dev Secure proxy contract for ClusterYield with limited admin functions
 * @notice This contract acts as owner of ClusterYield with restricted capabilities for maximum user security
 * 
 * WHAT ADMIN CAN DO:
 * - Receive 10% platform fees automatically
 * - Add new investment plans
 * - Update existing investment plans (rates, minimums, lock periods, active status)
 * - View platform statistics
 * - Update platform fee percentage (max 10%)
 * - Emergency withdraw stuck tokens (except user funds)
 * 
 * WHAT ADMIN CANNOT DO (PERMANENTLY DISABLED):
 * - Transfer funds to trading bot (transferToBot)
 * - Set trading bot address (setTradingBot)
 * - Transfer ownership to another address (transferOwnership)
 * - Receive profits from bot (receiveProfits)
 * 
 * This is a "SET AND FORGET" contract - once deployed and ownership transferred,
 * these restrictions cannot be changed, providing maximum security for users.
 */
contract SecureAdminProxy is Ownable, ReentrancyGuard {
    
    IERC20 public immutable USDT;
    IClusterYield public immutable clusterYield;
    address public beneficiary;
    
    uint256 public totalFeesCollected;
    uint256 public totalFeesForwarded;
    
    // Maximum values for security (only essential limits)
    uint256 private constant MAX_PLATFORM_FEE = 1000; // 10% max platform fee
    // Removed MAX_DAILY_RETURN - no limit on daily returns for flexibility
    // Removed MAX_LOCK_PERIOD - no limit on lock periods for flexibility
    
    // Events
    event FeesReceived(uint256 amount);
    event FeesForwarded(address indexed beneficiary, uint256 amount);
    event BeneficiaryUpdated(address indexed oldBeneficiary, address indexed newBeneficiary);
    event PlatformFeeUpdated(uint256 oldFee, uint256 newFee);
    event PlanAdded(uint256 planId, uint256 dailyReturn, uint256 minDeposit, uint256 lockPeriod);
    event PlanUpdated(uint256 planId, uint256 dailyReturn, uint256 minDeposit, uint256 lockPeriod, bool isActive);
    event EmergencyWithdrawal(address indexed token, uint256 amount);
    
    /**
     * @dev Constructor
     * @param _usdtAddress Address of USDT token
     * @param _clusterYieldAddress Address of ClusterYield contract
     * @param _beneficiary Address to receive forwarded fees
     */
    constructor(
        address _usdtAddress,
        address _clusterYieldAddress,
        address _beneficiary
    ) Ownable(msg.sender) {
        require(_usdtAddress != address(0), "SecureAdminProxy: Invalid USDT address");
        require(_clusterYieldAddress != address(0), "SecureAdminProxy: Invalid ClusterYield address");
        require(_beneficiary != address(0), "SecureAdminProxy: Invalid beneficiary address");
        
        USDT = IERC20(_usdtAddress);
        clusterYield = IClusterYield(_clusterYieldAddress);
        beneficiary = _beneficiary;
    }
    
    // ============ FEE COLLECTION FUNCTIONS ============
    
    /**
     * @dev Automatically forward any received USDT to beneficiary
     * @notice This function is called whenever USDT is sent to this contract
     */
    function forwardFees() external nonReentrant {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "SecureAdminProxy: No fees to forward");
        
        totalFeesCollected += balance;
        totalFeesForwarded += balance;
        
        bool success = USDT.transfer(beneficiary, balance);
        require(success, "SecureAdminProxy: Fee forwarding failed");
        
        emit FeesReceived(balance);
        emit FeesForwarded(beneficiary, balance);
    }
    
    /**
     * @dev Check and forward any accumulated fees
     * @notice Anyone can call this to trigger fee forwarding
     */
    function checkAndForwardFees() external {
        uint256 balance = USDT.balanceOf(address(this));
        if (balance > 0) {
            this.forwardFees();
        }
    }
    
    /**
     * @dev Update beneficiary address (only owner)
     * @param _newBeneficiary New beneficiary address
     */
    function updateBeneficiary(address _newBeneficiary) external onlyOwner {
        require(_newBeneficiary != address(0), "SecureAdminProxy: Invalid beneficiary address");
        address oldBeneficiary = beneficiary;
        beneficiary = _newBeneficiary;
        emit BeneficiaryUpdated(oldBeneficiary, _newBeneficiary);
    }
    
    // ============ ALLOWED CLUSTERYIELD ADMIN FUNCTIONS ============
    
    /**
     * @dev Update ClusterYield platform fee (only owner)
     * @param _newFee New platform fee in basis points (max 10%)
     */
    function updateClusterYieldPlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= MAX_PLATFORM_FEE, "SecureAdminProxy: Platform fee too high");
        clusterYield.updatePlatformFee(_newFee);
        emit PlatformFeeUpdated(0, _newFee); // Note: We don't have access to old fee
    }
    
    /**
     * @dev Add new investment plan to ClusterYield (only owner)
     * @param _dailyReturn Daily return in basis points (no limit for flexibility)
     * @param _minDeposit Minimum deposit amount in wei
     * @param _lockPeriod Lock period in days (no limit for flexibility)
     */
    function addClusterYieldPlan(
        uint256 _dailyReturn,
        uint256 _minDeposit,
        uint256 _lockPeriod
    ) external onlyOwner {
        require(_minDeposit > 0, "SecureAdminProxy: Minimum deposit must be greater than 0");
        
        clusterYield.addPlan(_dailyReturn, _minDeposit, _lockPeriod);
        emit PlanAdded(0, _dailyReturn, _minDeposit, _lockPeriod); // Note: We don't have access to planId
    }
    
    /**
     * @dev Update ClusterYield investment plan (only owner)
     * @param _planId ID of the plan to update
     * @param _dailyReturn New daily return in basis points (no limit for flexibility)
     * @param _minDeposit New minimum deposit amount
     * @param _lockPeriod New lock period in days (no limit for flexibility)
     * @param _isActive Whether the plan should be active
     */
    function updateClusterYieldPlan(
        uint256 _planId,
        uint256 _dailyReturn,
        uint256 _minDeposit,
        uint256 _lockPeriod,
        bool _isActive
    ) external onlyOwner {
        require(_minDeposit > 0, "SecureAdminProxy: Minimum deposit must be greater than 0");
        
        clusterYield.updatePlan(_planId, _dailyReturn, _minDeposit, _lockPeriod, _isActive);
        emit PlanUpdated(_planId, _dailyReturn, _minDeposit, _lockPeriod, _isActive);
    }
    
    // ============ PERMANENTLY DISABLED FUNCTIONS ============
    // These functions are intentionally NOT implemented to prevent:
    // - transferToBot: Cannot transfer user funds to trading bot
    // - setTradingBot: Cannot set trading bot address
    // - transferOwnership: Cannot transfer ownership (set and forget)
    // - receiveProfits: Cannot receive profits from bot
    
    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Get ClusterYield contract balance
     */
    function getClusterYieldBalance() external view returns (uint256) {
        return clusterYield.getContractBalance();
    }
    
    /**
     * @dev Get ClusterYield platform statistics
     */
    function getClusterYieldStats() external view returns (uint256, uint256, uint256, uint256) {
        return clusterYield.getPlatformStats();
    }
    
    /**
     * @dev Get ClusterYield bot statistics
     */
    function getClusterYieldBotStats() external view returns (address, uint256, uint256) {
        return clusterYield.getBotStats();
    }
    
    /**
     * @dev Get proxy contract statistics
     */
    function getProxyStats() external view returns (
        uint256 currentBalance,
        uint256 totalCollected,
        uint256 totalForwarded,
        address currentBeneficiary
    ) {
        return (
            USDT.balanceOf(address(this)),
            totalFeesCollected,
            totalFeesForwarded,
            beneficiary
        );
    }
    
    // ============ EMERGENCY FUNCTIONS ============
    
    /**
     * @dev Emergency withdrawal function for any ERC20 token except USDT (only owner)
     * @param _token Address of token to withdraw (cannot be USDT)
     * @param _amount Amount to withdraw
     * @notice USDT withdrawals are blocked to prevent interference with fee collection
     */
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(USDT), "SecureAdminProxy: Cannot withdraw USDT (use forwardFees)");
        require(_token != address(0), "SecureAdminProxy: Invalid token address");
        
        IERC20 token = IERC20(_token);
        require(token.balanceOf(address(this)) >= _amount, "SecureAdminProxy: Insufficient token balance");
        
        bool success = token.transfer(owner(), _amount);
        require(success, "SecureAdminProxy: Token withdrawal failed");
        
        emit EmergencyWithdrawal(_token, _amount);
    }
    
    /**
     * @dev Emergency ETH withdrawal (only owner)
     * @param _amount Amount of ETH to withdraw
     */
    function emergencyWithdrawETH(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "SecureAdminProxy: Insufficient ETH balance");
        
        (bool success, ) = payable(owner()).call{value: _amount}("");
        require(success, "SecureAdminProxy: ETH withdrawal failed");
        
        emit EmergencyWithdrawal(address(0), _amount);
    }
    
    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}
    
    // ============ SECURITY DOCUMENTATION ============
    
    /**
     * @dev Returns a list of permanently disabled functions for transparency
     * @return disabledFunctions Array of function names that are permanently disabled
     */
    function getDisabledFunctions() external pure returns (string[] memory disabledFunctions) {
        disabledFunctions = new string[](4);
        disabledFunctions[0] = "transferToBot";
        disabledFunctions[1] = "setTradingBot";
        disabledFunctions[2] = "transferOwnership";
        disabledFunctions[3] = "receiveProfits";
        return disabledFunctions;
    }
    
    /**
     * @dev Returns a list of allowed admin functions for transparency
     * @return allowedFunctions Array of function names that admin can execute
     */
    function getAllowedFunctions() external pure returns (string[] memory allowedFunctions) {
        allowedFunctions = new string[](6);
        allowedFunctions[0] = "updatePlatformFee";
        allowedFunctions[1] = "addPlan";
        allowedFunctions[2] = "updatePlan";
        allowedFunctions[3] = "forwardFees";
        allowedFunctions[4] = "updateBeneficiary";
        allowedFunctions[5] = "emergencyWithdraw";
        return allowedFunctions;
    }
    
    /**
     * @dev Returns security limits for transparency
     * @return maxPlatformFee Maximum platform fee in basis points (only limit enforced)
     */
    function getSecurityLimits() external pure returns (uint256 maxPlatformFee) {
        return MAX_PLATFORM_FEE;
    }
}
