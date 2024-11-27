/**
 *Submitted for verification at Etherscan.io on 2024-11-27
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

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

// Staking Contract
contract Staking is Ownable, ReentrancyGuard {
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
    event TokenAddressUpdated(address indexed previousToken, address indexed newToken);

    IERC20 public token;

    constructor() Ownable(msg.sender) {
        // Additional constructor logic if necessary
    }

    function stakeTokens(uint256 amount, uint256 durationIndex) external {
        require(amount > 0, "Amount must be greater than zero");
        require(durationIndex < stakeDurations.length, "Invalid duration index");

        uint256 potentialReward = (amount * stakeRewards[durationIndex]) / 10000;
        require(rewardsPool >= potentialReward, "Rewards pool has insufficient balance");

        uint256 duration = stakeDurations[durationIndex];

        token.transferFrom(msg.sender, address(this), amount);

        _stakes[msg.sender].push(Stake(amount, currentTime(), durationIndex, false));

        totalStakedTokens = totalStakedTokens + amount;
        emit Staked(msg.sender, amount, duration);
    }

    function withdrawAndClaim(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < _stakes[msg.sender].length, "Invalid stake index");

        Stake storage userStake = _stakes[msg.sender][stakeIndex];
        require(!userStake.claimed, "Tokens already claimed");

        // Ensure the stake is unlocked
        uint256 unlockTime = userStake.startTime + (stakeDurations[userStake.durationIndex] * 1 days);
        require(unlockTime <= currentTime(), "Stake is still locked. Unlock period not reached.");

        // Calculate principal and reward
        uint256 principal = userStake.amount;
        uint256 reward = (principal * stakeRewards[userStake.durationIndex]) / 10000;

        // Prevalidate that the rewards pool can cover the reward
        require(reward <= rewardsPool, "Rewards pool has insufficient balance");

        // Mark the stake as claimed
        userStake.claimed = true;
        totalStakedTokens = totalStakedTokens - principal;
        rewardsPool = rewardsPool - reward;

        // Send the principal + reward back to the user
        uint256 tokenReceivedBack = principal + reward;
        token.transfer(msg.sender, tokenReceivedBack);

        emit Claimed(msg.sender, principal, reward);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");

        token.transferFrom(msg.sender, address(this), amount);
        rewardsPool = rewardsPool + amount;
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
        require(_tokenAddress != address(0), "Token address cannot be the zero address");

        emit TokenAddressUpdated(address(token), _tokenAddress);

        token = IERC20(_tokenAddress);
    }
}