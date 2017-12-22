pragma solidity ^0.4.18;

import './Proposal.sol';
import '../../misc/Ownable.sol';
import '../../misc/SafeMath.sol';

contract Pool {
    function submitionFunding() external payable returns(bool);
}

contract Vote {
    function withdraw(address _from) external returns(bool);
}

contract Quorum {
    function checkCitizenQuorum(uint _upVotes, uint _downVotes, address _proposal, uint _value) external returns(bool, uint);
    function checkQuratorsQuorum(uint _upTicks, uint _downTicks) external returns(bool);
}

contract Curator {
    function limits(address _curator, uint8 _action) external returns(bool);
    function calcEffort (uint _effort, address _curator) external;
    function calcPos(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public;
    function calcNeg(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public;
    function getReputation(address _curator) external view returns(uint);
}

contract ProposalController is Ownable {

    using SafeMath for *;

    Pool poolContract;
    Vote voteContract;
    Curator curatorContract;
    Quorum quorumContract;
    
    //proposals storage
    address[] proposals;

    uint public feeMin = 0.1 ether;
    uint public feeMax = 0.4 ether;
    uint public curationPeriod = 48 hours;
    uint public votingPeriod = 48 hours;

    event NewProposal(address indexed _proposal);
    event VoteCasted(address indexed _proposal, address indexed _voter, uint indexed _vote);

    function ProposalController() public payable {
        owner = msg.sender;
    }
    
    function creatProposal(address _approver, bool _activism, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public payable returns(Proposal proposal) {
        if (_value <= 22) {
            require(msg.value == feeMin);
        } else {
            require(msg.value == feeMax);
        }
        require(poolContract.submitionFunding.value(msg.value)());
        proposal = new Proposal(msg.sender, _approver, _activism, _title, _description, _videoLink, _documentsLink, _value);
        proposals.push(proposal);
        NewProposal(proposal);
        return proposal;
    }

    function setVoteContractAddress(address _address) public onlyOwner {
        voteContract = Vote(_address);
    }

    function setPoolContractAddress(address _address) public onlyOwner {
        poolContract = Pool(_address);
    }

    function setCuratorContractAddress(address _address) public onlyOwner {
        curatorContract = Curator(_address);
    }

    function setQuorumContractAddress(address _address) public onlyOwner {
        quorumContract = Quorum(_address);
    }

    //tick proposal by curator
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal, 4 == not activism
    function tickProposal(Proposal proposal, uint8 _tick) public {
        require(curatorContract.limits(msg.sender, _tick));
        require(proposal.tick(msg.sender, _tick));
        var proposalTimestamp = proposal.id();
        
        if (now > proposalTimestamp.add(curationPeriod)) {
            if (quorumContract.checkQuratorsQuorum(proposal.totalUpticks(), proposal.totalDownticks())) {
                require(proposal.setActivated());
                require(proposal.setStatus(1));//set status "Voting"
            } else {
                require(proposal.setStatus(3));//set status "Closed"
            }
        }
    }

    //add comment by curator
    function addComment(Proposal proposal, bytes32 _text) public {
        require(curatorContract.limits(msg.sender, 4));
        proposal.addComment(msg.sender, _text);
    }

    //uptick comment by curator
    function uptickComment(Proposal proposal, uint _index) public {
        require(curatorContract.limits(msg.sender, 5));
        var reputation = curatorContract.getReputation(msg.sender);
        var author = proposal.getCommentAuthor(_index);
        curatorContract.calcEffort(reputation, author);
        proposal.uptickComment(_index, msg.sender);
    }

    //citizen vote
    //1 == vote up, 2 == vote down
    function citizenVote(Proposal proposal, uint _vote) public {
        require(proposal.vote(msg.sender, _vote));
        require(voteContract.withdraw(msg.sender));
        var proposalTimestamp = proposal.id();
        if (now > proposalTimestamp.add(curationPeriod).add(votingPeriod)) {
            var (reached, funds) =  quorumContract.checkCitizenQuorum(proposal.upVotes(), proposal.downVotes(), proposal, proposal.value());
            if (reached == true) {
                require(proposal.setQuorumReached());
                require(proposal.setFunds(funds));
                if (funds < proposal.value()) {
                    require(proposal.setStatus(2));//set status "Direct funding"
                } else {
                    require(proposal.setStatus(3));//set status "Closed"
                }
            }
        }
        VoteCasted(proposal, msg.sender, _vote);
    }

    //proposal direct funding
    //TEST HARDLY!!!!
    function directFunding(Proposal proposal) public payable {
        proposal.fundProposal.value(msg.value)();
    }

    //request funds by submitter
    //two signature required! First request must be only from submitter address 
    //and second - only from approver address!
    function withdrawProposal(Proposal proposal) public {
        proposal.wirthdrawFunds(msg.sender);
    }

    //get reputation (curator button)
    function getCuratorReputation(Proposal proposal) public {
        var (activated, quorum, uptick, downtick, flag) = proposal.getReputation(msg.sender);
        curatorContract.calcPos(msg.sender, activated, quorum, uptick, downtick, flag);
        curatorContract.calcNeg(msg.sender, activated, quorum, uptick, downtick, flag);
    }

    //getters
    function getProposalsList() public view returns(address[]) {
        return proposals;
    }

    function getProposal(Proposal proposal) public view returns(uint, bytes32, bytes32, bytes32, bytes32, uint, uint, uint) {
        return(
            proposal.id(),
            proposal.title(),
            proposal.description(),
            proposal.videoLink(),
            proposal.documentsLink(),
            proposal.value(),
            proposal.commentsIndex(),
            uint(proposal.status()),
        );
    }

    function getTicks(Proposal proposal) public view returns(uint, uint, uint) {
        return (
            proposal.totalUpticks(),
            proposal.totalDownticks(),
            proposal.flagsCount()
        );
    }

    function getComment(Proposal proposal, uint _index) public view returns(address, uint, bytes32, uint) {
        return proposal.getComment(_index);
    }

    function getCuratorReaction(Proposal proposal, address _curator) public view returns(bool, bool, bool) {
        return proposal.getReaction(_curator);
    }
}