// SPDX-License-Identifier: MIT
// Developer - Rexine Gonza alias Ethicode
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./RivalsToken.sol"; // Import the RivalsToken contract

contract RivalsP2E is Ownable, ReentrancyGuard {
    RivalsToken public rivalsToken; // Instance of the RivalsToken contract
    uint256 public rewardAmount; // Reward amount for winning a game

    event GameWon(address indexed player, uint256 reward);

    constructor(address _rivalsToken) {
        rivalsToken = RivalsToken(_rivalsToken);
    }

    function setRewardAmount(uint256 _rewardAmount) external onlyOwner {
        rewardAmount = _rewardAmount;
    }

    function winGame(address player) external nonReentrant onlyOwner {
        require(player != address(0), "Invalid player address");
        require(rewardAmount > 0, "Reward amount not set");

        rivalsToken.distributeP2EIncentives(player, rewardAmount);
        emit GameWon(player, rewardAmount);
    }
}
