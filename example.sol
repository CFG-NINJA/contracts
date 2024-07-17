// SPDX-License-Identifier: MIT
// This smart contract is modified by ...

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

contract RVLSToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;
    uint256 private immutable TAX_RATE; // Buy/Sell tax
    uint256 private constant STAKING_REWARD_RATE = 3; // 3% per year
    uint256 private constant VOTING_THRESHOLD = 100_000 * 10 ** 18;
    uint256 private constant MAX_TX_PERCENTAGE = 1; // 1% of total supply
    uint256 private constant MAX_TX_AMOUNT = MAX_SUPPLY * MAX_TX_PERCENTAGE / 100;
    bool private _initialMintingDone = false;

    mapping(address => uint256) private _lastStakeTime;
    mapping(address => uint256) private _stakedAmounts;

    event Burn(address indexed burner, uint256 amount);
    event Stake(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount);

    constructor(uint256 taxRate) ERC20("RVLS Token", "RVLS") {
        require(taxRate <= 100, "Tax rate must be between 0 and 100");
        TAX_RATE = taxRate;
        _mint(msg.sender, MAX_SUPPLY);
        _initialMintingDone = true;
    }

    function _mint(address account, uint256 amount) internal override {
        require(!_initialMintingDone, "Minting new tokens is not allowed");
        super._mint(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount <= MAX_TX_AMOUNT, "Transfer amount exceeds the max transaction limit");

        uint256 taxAmount = amount.mul(TAX_RATE).div(100);
        uint256 transferAmount = amount.sub(taxAmount);

        super._transfer(sender, address(this), taxAmount);
        super._transfer(sender, recipient, transferAmount);
    }

    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    function stake(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to stake");

        _transfer(msg.sender, address(this), amount);
        _stakedAmounts[msg.sender] = _stakedAmounts[msg.sender].add(amount);
        _lastStakeTime[msg.sender] = block.timestamp;

        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(_stakedAmounts[msg.sender] >= amount, "Insufficient staked amount to unstake");

        uint256 reward = calculateReward(msg.sender);
        _stakedAmounts[msg.sender] = _stakedAmounts[msg.sender].sub(amount);
        _lastStakeTime[msg.sender] = block.timestamp;

        _transfer(address(this), msg.sender, amount.add(reward));
        emit Unstake(msg.sender, amount);
    }

    function calculateReward(address staker) public view returns (uint256) {
        uint256 stakingDuration = block.timestamp.sub(_lastStakeTime[staker]);
        uint256 reward = _stakedAmounts[staker]
            .mul(STAKING_REWARD_RATE)
            .mul(stakingDuration)
            .div(365 days)
            .div(100);
        return reward;
    }

    function votingRights(address account) external view returns (bool) {
        return balanceOf(account) >= VOTING_THRESHOLD;
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership();
    }

}
