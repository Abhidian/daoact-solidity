pragma solidity ^0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Curator {
    function getCuratorRewarding(address _curator) public view returns (uint);
}

contract Pool is Ownable {

    using SafeMath for *;

    Curator curatorContract;

    address public proposalController;
    address public quorumContract;
    address public voteContract;
    address public foundation;
    address public daoact;
    uint public fundingPool;
    uint public rewardingPool;
    uint public foundationPool;
    uint public timestamp;

    struct Transit {
        uint timestamp;
        uint balance;
    }

    Transit public transit;

    function Pool() public {
        owner = msg.sender;
        timestamp = now;
    }

    function setQuorumContractAddress(address _quorum) public onlyOwner {
        require(_quorum != address(0));
        quorumContract = _quorum;
    }

    function setVoteContractAddress(address _voteContract) public onlyOwner {
        require(_voteContract != address(0));
        voteContract = _voteContract;
    }

    function setCuratorContractAddress(address _curatorContract) public onlyOwner {
        require(_curatorContract != address(0));
        curatorContract = Curator(_curatorContract);
    }

    function setProposalControllerAddress(address _proposalController) public onlyOwner {
        require(_proposalController != address(0));
        proposalController = _proposalController;
    }

    function setFoundationAndDaoactAddresses(address _foundation, address _daoact) public onlyOwner {
        require(_foundation != address(0));
        require(_daoact != address(0));
        foundation = _foundation;
        daoact = _daoact;
    }

    //payment for buying votes, dividing into 3 pools: for funding proposals, for paying curator's rewarding, paying for foundation
    function votesFunding() external payable returns(bool) {
        require(msg.sender == voteContract);
        var funds = msg.value;
        var funding = funds.mul(80).div(100);
        var rewarding = funds.mul(15).div(100);
        var foundationPart = funds.mul(5).div(100);

        fundingPool = fundingPool.add(funding);
        rewardingPool = rewardingPool.add(rewarding);
        foundationPool = foundationPool.add(foundationPart);
        return true;
    }

    //accept direct funding for pool
    function directFunding() public payable {
        require(msg.value > 0);
        fundingPool = fundingPool.add(msg.value);
    }

    function fromProposalDirectFunding() external payable returns(bool) {
        require(msg.value > 0);
        require(msg.sender == proposalController);
        foundationPool = foundationPool.add(msg.value);
        return true;
    }

    //accept payment submission fee for paying curator's rewarding
    function submitionFunding() external payable returns(bool) {
        require(msg.sender == proposalController);
        rewardingPool = rewardingPool.add(msg.value);
        return true;
    }

    // get transit balance and timestamp
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
        if (_value * 1 ether <= allowed) {
            _proposal.transfer(_value * 1 ether);
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