// SPDX-License-Identifier: MIT
// Developed by Gonza Rexine alias Ethicode
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RVLSToken is ERC20, Ownable, ReentrancyGuard {
    uint256 public constant MAX_TAX_PERCENT = 2; // Tax percent fixed at 2%
    uint256 public constant STAKING_REWARD_PERCENT = 3; // Staking reward fixed at 3% per month
    uint256 public constant STAKING_INTERVAL = 30 days; // Staking interval fixed at 30 days
    uint256 public constant MAX_TRANSFER_PERCENT = 1; // Maximum transfer amount as a percentage of total supply
    uint256 public constant MAX_SUPPLY = 1000000000 * 10 ** 18; // Maximum supply of 1 billion tokens
    uint256 public constant MINIMUM_VOTING_TOKENS = 100000 * 10 ** 18; // Minimum tokens required for voting
    uint256 public constant LOCK_PERCENT = 15; // Percent of tokens to lock
    uint256 public constant LOCK_DURATION = 2 * 365 days; // Lock duration of 2 years
    uint256 public constant P2E_PERCENT = 125; // 12.5% of the total supply allocated for P2E incentives
    uint256 public constant STAKING_AND_LIQUIDITY_PERCENT = 20; // 20% of the total supply allocated for staking rewards and liquidity
    uint256 public constant MARKETING_PERCENT = 15; // 15% of the total supply allocated for marketing
    uint256 public constant CHARITY_PERCENT = 5; // 5% of the total supply allocated for charity
    uint256 public constant COMMUNITY_REWARDS_PERCENT = 125; // 12.5% of the total supply allocated for community rewards
    uint256 public constant PRESALE_PERCENT = 20; // 20% of the total supply allocated for presale

    address public immutable creator; // Creator address
    address public donationsWallet;
    address public nominatedOwner; // Nominated owner address
    uint256 public lockReleaseTime; // Time when locked tokens can be released
    bool public nominationInProgress; // Flag to prevent multiple nominations

    IERC20 public oldToken; // Reference to the old token contract
    address public p2eContract; // P2E contract address

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public stakingRewards;

    event TaxApplied(address indexed from, address indexed to, uint256 amount);
    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);
    event OwnershipNominated(address indexed nominatedOwner);
    event OwnershipAccepted(address indexed newOwner);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMigrated(address indexed account, uint256 amount);

    constructor(address _donationsWallet, address _owner, address _oldToken) ERC20("Rivals Token", "RVLS") {
        creator = msg.sender;
        donationsWallet = _donationsWallet;
        oldToken = IERC20(_oldToken);
        transferOwnership(_owner);

        uint256 lockAmount = (MAX_SUPPLY * LOCK_PERCENT) / 100;
        lockReleaseTime = block.timestamp + LOCK_DURATION; // Set lock release time to 2 years from deployment

        uint256 p2eAmount = (MAX_SUPPLY * P2E_PERCENT) / 1000;
        uint256 stakingAndLiquidityAmount = (MAX_SUPPLY * STAKING_AND_LIQUIDITY_PERCENT) / 100;
        uint256 marketingAmount = (MAX_SUPPLY * MARKETING_PERCENT) / 100;
        uint256 charityAmount = (MAX_SUPPLY * CHARITY_PERCENT) / 100;
        uint256 communityRewardsAmount = (MAX_SUPPLY * COMMUNITY_REWARDS_PERCENT) / 1000;
        uint256 presaleAmount = (MAX_SUPPLY * PRESALE_PERCENT) / 100;
        uint256 initialPresaleRelease = (presaleAmount * 10) / 100; // 10% on TGE
        uint256 vestedPresaleAmount = presaleAmount - initialPresaleRelease; // Remaining 90% vested

        _mintInternal(address(this), lockAmount); // Mint and lock 15% of the total supply
        _mintInternal(msg.sender, MAX_SUPPLY - lockAmount - p2eAmount - stakingAndLiquidityAmount - marketingAmount - charityAmount - communityRewardsAmount - presaleAmount); // Mint the remaining tokens to the contract creator
        _mintInternal(address(this), p2eAmount); // Mint P2E incentives to the contract itself
        _mintInternal(address(this), stakingAndLiquidityAmount); // Mint staking rewards and liquidity to the contract itself
        _mintInternal(address(this), marketingAmount); // Mint marketing tokens to the contract itself
        _mintInternal(address(this), charityAmount); // Mint charity tokens to the contract itself
        _mintInternal(address(this), communityRewardsAmount); // Mint community rewards tokens to the contract itself
        _mintInternal(msg.sender, initialPresaleRelease); // Mint initial presale release to the contract creator
        _mintInternal(address(this), vestedPresaleAmount); // Mint vested presale tokens to the contract itself
    }

    function setDonationsWallet(address _donationsWallet) external onlyOwner {
        donationsWallet = _donationsWallet;
    }

    function setP2EContract(address _p2eContract) external onlyOwner {
        p2eContract = _p2eContract;
    }

    function distributeP2EIncentives(address to, uint256 amount) external {
        require(msg.sender == p2eContract, "Caller is not the P2E contract");
        _transfer(address(this), to, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount <= (totalSupply() * MAX_TRANSFER_PERCENT) / 100, "Transfer amount exceeds the max transfer limit");

        uint256 taxAmount = (amount * MAX_TAX_PERCENT) / 100;
        uint256 netAmount = amount - taxAmount;

        super._transfer(sender, donationsWallet, taxAmount);
        super._transfer(sender, recipient, netAmount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(block.timestamp >= lockReleaseTime || balanceOf(msg.sender) <= (totalSupply() * (100 - LOCK_PERCENT)) / 100, "Tokens are locked");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(block.timestamp >= lockReleaseTime || balanceOf(sender) <= (totalSupply() * (100 - LOCK_PERCENT)) / 100, "Tokens are locked");
        return super.transferFrom(sender, recipient, amount);
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0 tokens");

        _transfer(msg.sender, address(this), amount);

        Stake storage userStake = stakes[msg.sender];
        userStake.amount += amount;
        userStake.timestamp = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function unstake() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No tokens staked");
        require(block.timestamp >= userStake.timestamp + STAKING_INTERVAL, "Staking period not yet completed");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;

        userStake.amount = 0;
        stakingRewards[msg.sender] = 0;

        _transfer(address(this), msg.sender, totalAmount);

        emit Unstaked(msg.sender, totalAmount);
        emit RewardsClaimed(msg.sender, reward);
    }

    function calculateReward(address staker) public view returns (uint256) {
        Stake memory userStake = stakes[staker];
        if (block.timestamp < userStake.timestamp + STAKING_INTERVAL) {
            return 0;
        }
        uint256 stakingDuration = block.timestamp - userStake.timestamp;
        uint256 intervals = stakingDuration / STAKING_INTERVAL;
        uint256 reward = (userStake.amount * STAKING_REWARD_PERCENT * intervals) / 100;
        return reward;
    }

    function claimRewards() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No tokens staked");
        require(block.timestamp >= userStake.timestamp + STAKING_INTERVAL, "Staking period not yet completed");
        uint256 reward = calculateReward(msg.sender);
        stakingRewards[msg.sender] += reward;
        userStake.timestamp = block.timestamp;
        emit RewardsClaimed(msg.sender, reward);
    }

    // Ownership transfer two-step process
    function nominateNewOwner(address _nominatedOwner) external onlyOwner {
        require(!nominationInProgress, "Nomination already in progress");
        require(_nominatedOwner != address(0), "Invalid nominated owner address");
        nominatedOwner = _nominatedOwner;
        nominationInProgress = true;
        emit OwnershipNominated(_nominatedOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "Caller is not the nominated owner");
        nominatedOwner = address(0);
        nominationInProgress = false;
        _transferOwnership(msg.sender);
        emit OwnershipAccepted(msg.sender);
    }

    // Voting functionality
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 startTime;
        uint256 endTime;
        bool executed;
    }

    Proposal[] public proposals;

    mapping(address => mapping(uint256 => bool)) public votes;

    event ProposalCreated(uint256 proposalId, string description, uint256 startTime, uint256 endTime);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    function createProposal(string memory description, uint256 duration) external {
        require(balanceOf(msg.sender) >= MINIMUM_VOTING_TOKENS, "Insufficient tokens to create proposal");

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + duration;

        proposals.push(Proposal({
            description: description,
            voteCount: 0,
            startTime: startTime,
            endTime: endTime,
            executed: false
        }));

        uint256 proposalId = proposals.length - 1;
        emit ProposalCreated(proposalId, description, startTime, endTime);
    }

    function vote(uint256 proposalId) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting period not active");
        require(balanceOf(msg.sender) >= MINIMUM_VOTING_TOKENS, "Insufficient tokens to vote");
        require(!votes[msg.sender][proposalId], "Already voted");

        proposal.voteCount++;
        votes[msg.sender][proposalId] = true;

        emit Voted(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        // Add the logic to execute the proposal here

        emit ProposalExecuted(proposalId);
    }

    // Manual token burn function
    function burnTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot burn 0 tokens");
        _burn(address(this), amount);
        emit TokensBurned(address(this), amount);
    }

    // Migrate tokens from old contract
    function migrateTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot migrate 0 tokens");
        require(oldToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        _mintInternal(msg.sender, amount);
        emit TokensMigrated(msg.sender, amount);
    }

    // Function to mint tokens
    function mint(address account, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting exceeds maximum supply");
        _mintInternal(account, amount);
    }

    // Internal mint function
    function _mintInternal(address account, uint256 amount) private {
        _mint(account, amount);
    }

    // Emergency function to transfer ETH
    receive() external payable {}

    // Fallback function to receive ETH
    fallback() external payable {}

    // Prevent accidental ETH sends to the contract
    function withdrawEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
