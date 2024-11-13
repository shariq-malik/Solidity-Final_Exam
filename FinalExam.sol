// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingPool {

    address public Owner_Address;
    uint public rewardPool; // Main Reward pool

    // For stakers info..
    struct Staker {
        uint balance;
        uint lastClaimedTime;
    }

    // to keep track of each stakers $balance$ and last Reward claim time..
    mapping(address => Staker) public stakers;

    uint public constant REWARD_RATE = 5; // 5% reward
    
    // reward claim period set to 7 days
    //uint public constant REWARD_TIME = 7 days; 

    // 3 min for testing...
    uint public constant REWARD_TIME = 3 minutes;

    // events deposit ya withdrawal ya rewards 
    event Deposit(address indexed staker, uint amount);
    event Withdraw(address indexed staker, uint amount);
    event ClaimRewards(address indexed staker, uint rewardAmount);

    
    constructor() {
        Owner_Address = msg.sender;
    }

    // owner privilage
    modifier onlyOwner() {
        require(msg.sender == Owner_Address, "Only the owner can perform this action");
        _;
    }

    // only owner could do this!!
    function addRewardFunds() external payable onlyOwner {
        require(msg.value > 0, "Reward amount should be greater than 0. !!!");
        rewardPool += msg.value;
    }

    // function to stake ether..
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount should be greater than 0. !!!");

        Staker storage staker = stakers[msg.sender];
        staker.balance += msg.value;
        
        if (staker.lastClaimedTime == 0) {
            staker.lastClaimedTime = block.timestamp;
        }

        emit Deposit(msg.sender, msg.value);
    }

    // withdraw your staked ether..
    function withdraw(uint amount) external {
        Staker storage staker = stakers[msg.sender];
        require(staker.balance >= amount, "Insufficient!! balance to withdraw.");

        staker.balance -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    // calculation for rewadss..
    function calculateReward(address stakerAddress) public view returns (uint) {
        Staker storage staker = stakers[stakerAddress];
        
        // if period time has come!
        if (block.timestamp >= staker.lastClaimedTime + REWARD_TIME) {
            uint reward = (staker.balance * REWARD_RATE) / 100; // reward 5%
            return reward <= rewardPool ? reward : 0;
        }
        return 0; // or not 
    }

    // claim your reward..
    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint reward = calculateReward(msg.sender);

        require(reward > 0, "No rewards available!! or insufficient reward pool!!!");
        
        staker.balance += reward;
        staker.lastClaimedTime = block.timestamp;
        rewardPool -= reward; // minus the reward..

        emit ClaimRewards(msg.sender, reward);
    }
}
