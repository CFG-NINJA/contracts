/**
 *Submitted for verification at Etherscan.io on 2024-10-15
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

// OpenZeppelin Contracts v4.6.0 (access/Ownable.sol)
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

// OpenZeppelin Contracts v4.6.0 (token/ERC20/IERC20.sol)
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

// OpenZeppelin Contracts v4.6.0 (utils/math/SafeMath.sol)
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// Staking Contract
contract Staking is Ownable {
    using SafeMath for uint256;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 durationIndex;
        bool claimed;
    }

    mapping(address => Stake[]) private _stakes;

    uint256[] public stakeDurations = [90, 180, 360];
    uint256[] public stakeRewards = [125, 500, 1500];

    uint256 public rewardsPool;
    uint256 public totalStakedTokens;
    
    event Staked(address indexed account, uint256 amount, uint256 durationIndex);
    event Claimed(address indexed account, uint256 principal, uint256 interest);
    event RewardsDeposited(uint256 amount);

    IERC20 public token;

    constructor() Ownable(msg.sender) {
        // Additional constructor logic if necessary
    }

    function stakeTokens(uint256 amount, uint256 durationIndex) external {
        require(amount > 0, "Amount must be greater than zero");
        require(durationIndex < stakeDurations.length, "Invalid duration index");

        uint256 potentialReward = amount.mul(stakeRewards[durationIndex]).div(10000);
        require(rewardsPool >= potentialReward, "Rewards pool has insufficient balance");

        uint256 duration = stakeDurations[durationIndex];

        token.transferFrom(msg.sender, address(this), amount);

        _stakes[msg.sender].push(Stake(amount, currentTime(), durationIndex, false));

        totalStakedTokens = totalStakedTokens.add(amount);
        emit Staked(msg.sender, amount, duration);
    }

    function withdrawAndClaim(uint256 stakeIndex) external {
        require(stakeIndex < _stakes[msg.sender].length, "Invalid stake index");

        Stake storage userStake = _stakes[msg.sender][stakeIndex];
        require(!userStake.claimed, "Tokens already claimed");

        // Ensure the stake is unlocked
        uint256 unlockTime = userStake.startTime.add(stakeDurations[userStake.durationIndex] * 1 days);
        require(unlockTime <= currentTime(), "Stake is still locked. Unlock period not reached.");

        // Calculate principal and reward
        uint256 principal = userStake.amount;
        uint256 reward = (principal * stakeRewards[userStake.durationIndex]) / 10000;

        // Mark the stake as claimed
        userStake.claimed = true;
        totalStakedTokens = totalStakedTokens.sub(principal);

        // Cap the reward by the available rewards pool
        if (reward > rewardsPool) {
            reward = 0;
        } else {
            rewardsPool = rewardsPool.sub(reward);
        }

        // Send the principal + reward back to the user
        uint256 tokenReceivedBack = principal + reward;
        if (tokenReceivedBack > 0) {
            token.transfer(msg.sender, tokenReceivedBack);
        }

        emit Claimed(msg.sender, principal, reward);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");

        token.transferFrom(msg.sender, address(this), amount);
        rewardsPool = rewardsPool.add(amount);
        emit RewardsDeposited(amount);
    }

    function getStakeCount(address account) external view returns (uint256) {
        return _stakes[account].length;
    }

    function getStake(address account, uint256 stakeIndex) external view returns (uint256 amount, uint256 startTime, uint256 duration, bool claimed) {
        require(stakeIndex < _stakes[account].length, "Invalid stake index");

        Stake storage userStake = _stakes[account][stakeIndex];

        return (userStake.amount, userStake.startTime, stakeDurations[userStake.durationIndex], userStake.claimed);
    }

    function getTotalStakingRewards() external view returns (uint256) {
        return rewardsPool;
    }

    // Function to get the current time
    function currentTime() internal view returns (uint256) {
        return block.timestamp;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
    }
}