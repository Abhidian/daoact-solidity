pragma solidity ^0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Curator {
    function getCuratorRewarding(address _curator) public view returns (uint);
}

contract Pool is Ownable{

    using SafeMath for *;   

    Curator curatorContract; 

    address private proposalController;
    address private quorumContract;
    address private voteContract;
    address private foundation;
    address private daoact;
    uint private fundingPool;
    uint private rewardingPool;
    uint private foundationPool;
    uint private timestamp;

    struct Transit {
        uint timestamp;
        uint balance;
    }

    Transit private transit;

    function Pool(address _proposalController, address _voteContract, address _curatorContract, address _foundation, address _daoact) public {
        owner = msg.sender;
        require(_proposalController != address(0));
        require(_voteContract != address(0));
        require(_curatorContract != address(0));
        proposalController = _proposalController;
        voteContract = _voteContract;
        foundation = _foundation;
        daoact = _daoact;
        timestamp = now;

        curatorContract = Curator(_curatorContract);
    }
    ///??????????? address limitation ??????????????????
    function setQuorumContractAddress(address _quorum) {
        require(_quorum != address(0));
        quorumContract = _quorum;
    }

    function votesFunding() external payable {
        require(msg.sender == voteContract);
        var funds = msg.value;
        var funding = funds.mul(80).div(100);
        var rewarding = funds.mul(15).div(100);
        var foundationPart = funds.mul(5).div(100);

        fundingPool = fundingPool.add(funding);
        rewardingPool = rewardingPool.add(rewarding);
        foundationPool = foundationPool.add(foundationPart);
    }

    function directFunding() public payable {
        var funds = msg.value;
        var funding = funds.mul(95).div(100);
        var foundationPart = funds.mul(5).div(100);
        fundingPool = fundingPool.add(funding);
        foundationPool = foundationPool.add(foundationPart);
    }

    function submitionFunding() external payable returns(bool) {
        require(msg.sender == proposalController);
        rewardingPool = rewardingPool.add(msg.value);
        return true;
    }

    // getters
    function getTransit() external returns(uint, uint) {
        if (transit.timestamp != 0 && now < transit.timestamp + 30 days) {
            return (transit.balance, transit.timestamp);
        }  
        if (transit.timestamp == 0 || now >= transit.timestamp + 30 days) {
            timestamp = now;
            transit.timestamp = now;
            transit.balance = rewardingPool;
            return (transit.balance, transit.timestamp);
        }
    }

    //withdrawals
    function curatorReward() public {
        require(now > timestamp.add(30 days));
        var rewarding = curatorContract.getCuratorRewarding(msg.sender);
        rewardingPool = rewardingPool.sub(rewarding);
        msg.sender.transfer(rewarding);
    }

    function proposalFund(address _proposal, uint _value) external returns(uint) {
        require(msg.sender == quorumContract);
        var allowed = fundingPool.mul(10).div(100);
        if (_value <= allowed) {
            _proposal.transfer(_value);
            return _value;
        } else {
            _proposal.transfer(allowed);
            return allowed;
        }
    }

    function foundationFee() public {
        require(now > timestamp.add(30 days));
        require(msg.sender == foundation);
        var half = foundationPool.div(2);
        foundation.transfer(half);
        daoact.transfer(half);
    }
}