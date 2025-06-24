// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IClusterYield {
    function transferOwnership(address newOwner) external;
    function updatePlatformFee(uint256 _newFee) external;
    function setTradingBot(address _botAddress) external;
    function transferToBot(uint256 _amount) external;
    function receiveProfits(uint256 _amount) external;
    function addPlan(uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod) external;
    function updatePlan(uint256 _planId, uint256 _dailyReturn, uint256 _minDeposit, uint256 _lockPeriod, bool _isActive) external;
}

/**
 * @title FeeCollectorProxy
 * @dev Proxy contract to collect fees from ClusterYield and forward them to beneficiary
 * @notice This contract acts as owner of ClusterYield to collect 10% deposit fees
 * Features:
 * - Automatically forwards received USDT to beneficiary
 * - Optional admin functions (can be disabled for full autonomy)
 * - Emergency withdrawal capabilities
 * - Transparent fee collection mechanism
 */
contract FeeCollectorProxy is Ownable, ReentrancyGuard {
    
    IERC20 public immutable USDT;
    IClusterYield public immutable clusterYield;
    address public beneficiary;
    bool public adminFunctionsEnabled;
    
    uint256 public totalFeesCollected;
    uint256 public totalFeesForwarded;
    
    // Events
    event FeesReceived(uint256 amount);
    event FeesForwarded(address indexed beneficiary, uint256 amount);
    event BeneficiaryUpdated(address indexed oldBeneficiary, address indexed newBeneficiary);
    event AdminFunctionsToggled(bool enabled);
    event EmergencyWithdrawal(address indexed token, uint256 amount);
    
    /**
     * @dev Constructor
     * @param _usdtAddress Address of USDT token
     * @param _clusterYieldAddress Address of ClusterYield contract
     * @param _beneficiary Address to receive forwarded fees
     * @param _adminFunctionsEnabled Whether admin functions are enabled initially
     */
    constructor(
        address _usdtAddress,
        address _clusterYieldAddress,
        address _beneficiary,
        bool _adminFunctionsEnabled
    ) Ownable(msg.sender) {
        require(_usdtAddress != address(0), "FeeCollectorProxy: Invalid USDT address");
        require(_clusterYieldAddress != address(0), "FeeCollectorProxy: Invalid ClusterYield address");
        require(_beneficiary != address(0), "FeeCollectorProxy: Invalid beneficiary address");
        
        USDT = IERC20(_usdtAddress);
        clusterYield = IClusterYield(_clusterYieldAddress);
        beneficiary = _beneficiary;
        adminFunctionsEnabled = _adminFunctionsEnabled;
    }
    
    /**
     * @dev Automatically forward any received USDT to beneficiary
     * @notice This function is called whenever USDT is sent to this contract
     */
    function forwardFees() external nonReentrant {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "FeeCollectorProxy: No fees to forward");
        
        totalFeesCollected += balance;
        totalFeesForwarded += balance;
        
        bool success = USDT.transfer(beneficiary, balance);
        require(success, "FeeCollectorProxy: Fee forwarding failed");
        
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
        require(_newBeneficiary != address(0), "FeeCollectorProxy: Invalid beneficiary address");
        address oldBeneficiary = beneficiary;
        beneficiary = _newBeneficiary;
        emit BeneficiaryUpdated(oldBeneficiary, _newBeneficiary);
    }
    
    /**
     * @dev Toggle admin functions on/off (only owner)
     * @param _enabled Whether admin functions should be enabled
     * @notice Setting to false makes the contract autonomous (irreversible)
     */
    function toggleAdminFunctions(bool _enabled) external onlyOwner {
        adminFunctionsEnabled = _enabled;
        emit AdminFunctionsToggled(_enabled);
    }
    
    // ============ CLUSTERYI ELD ADMIN FUNCTIONS (if enabled) ============
    
    modifier onlyIfAdminEnabled() {
        require(adminFunctionsEnabled, "FeeCollectorProxy: Admin functions disabled");
        _;
    }
    
    /**
     * @dev Update ClusterYield platform fee (only if admin functions enabled)
     */
    function updateClusterYieldPlatformFee(uint256 _newFee) external onlyOwner onlyIfAdminEnabled {
        clusterYield.updatePlatformFee(_newFee);
    }
    
    /**
     * @dev Set ClusterYield trading bot (only if admin functions enabled)
     */
    function setClusterYieldTradingBot(address _botAddress) external onlyOwner onlyIfAdminEnabled {
        clusterYield.setTradingBot(_botAddress);
    }
    
    // transferToBot function intentionally NOT implemented
    // This prevents admin/owner from transferring user funds to trading bot
    // Making the contract safer for users while maintaining other admin functions
    
    /**
     * @dev Receive profits from ClusterYield trading bot (only if admin functions enabled)
     */
    function receiveClusterYieldProfits(uint256 _amount) external onlyOwner onlyIfAdminEnabled {
        clusterYield.receiveProfits(_amount);
    }
    
    /**
     * @dev Add new investment plan to ClusterYield (only if admin functions enabled)
     */
    function addClusterYieldPlan(
        uint256 _dailyReturn,
        uint256 _minDeposit,
        uint256 _lockPeriod
    ) external onlyOwner onlyIfAdminEnabled {
        clusterYield.addPlan(_dailyReturn, _minDeposit, _lockPeriod);
    }
    
    /**
     * @dev Update ClusterYield investment plan (only if admin functions enabled)
     */
    function updateClusterYieldPlan(
        uint256 _planId,
        uint256 _dailyReturn,
        uint256 _minDeposit,
        uint256 _lockPeriod,
        bool _isActive
    ) external onlyOwner onlyIfAdminEnabled {
        clusterYield.updatePlan(_planId, _dailyReturn, _minDeposit, _lockPeriod, _isActive);
    }
    
    /**
     * @dev Transfer ClusterYield ownership to another address (only owner)
     * @param _newOwner New owner address
     * @notice This effectively removes this proxy from the ownership chain
     */
    function transferClusterYieldOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "FeeCollectorProxy: Invalid new owner");
        clusterYield.transferOwnership(_newOwner);
    }
    
    // ============ EMERGENCY FUNCTIONS ============
    
    /**
     * @dev Emergency withdrawal function for any ERC20 token (only owner)
     * @param _token Address of token to withdraw (use address(0) for ETH)
     * @param _amount Amount to withdraw
     * @notice Should only be used in emergencies
     */
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(0)) {
            // Withdraw ETH
            require(address(this).balance >= _amount, "FeeCollectorProxy: Insufficient ETH balance");
            (bool success, ) = payable(owner()).call{value: _amount}("");
            require(success, "FeeCollectorProxy: ETH withdrawal failed");
        } else {
            // Withdraw ERC20 token
            IERC20 token = IERC20(_token);
            require(token.balanceOf(address(this)) >= _amount, "FeeCollectorProxy: Insufficient token balance");
            bool success = token.transfer(owner(), _amount);
            require(success, "FeeCollectorProxy: Token withdrawal failed");
        }
        
        emit EmergencyWithdrawal(_token, _amount);
    }
    
    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Get contract statistics
     */
    function getStats() external view returns (
        uint256 currentBalance,
        uint256 totalCollected,
        uint256 totalForwarded,
        address currentBeneficiary,
        bool adminEnabled
    ) {
        return (
            USDT.balanceOf(address(this)),
            totalFeesCollected,
            totalFeesForwarded,
            beneficiary,
            adminFunctionsEnabled
        );
    }
    
    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}
}