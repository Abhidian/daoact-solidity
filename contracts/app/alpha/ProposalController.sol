pragma solidity ^0.4.18;

import './Proposal.sol';
import '../../misc/Ownable.sol';

contract Pool {
    function submitionFunding() external payable returns(bool);
}

contract Vote {
    function withdraw(address _from) external returns(bool);
}

contract ProposalController is Ownable {

    Pool poolContract;
    Vote voteContract;

    //proposals storage
    address[] proposals;

    uint public feeMin = 0.1 ether;
    uint public feeMax = 0.4 ether;

    event NewProposal(address indexed _proposal);

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
    //tick proposal by curator
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal, 4 == not activism
    function tickProposal(Proposal proposal, uint8 _tick) public {
        proposal.tick(msg.sender, _tick);
    }

    //add comment by curator
    function addComment(Proposal proposal, bytes32 _text) public {
        proposal.addComment(msg.sender, _text);
    }

    //uptick comment by curator
    function uptickComment(Proposal proposal, uint _index) public {
        proposal.uptickComment(_index, msg.sender);
    }

    //citizen vote
    //1 == vote up, 2 == vote down
    function citizenVote(Proposal proposal, uint _vote) public {
        require(proposal.vote(msg.sender, _vote));
        require(voteContract.withdraw(msg.sender));
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
        proposal.getReputation(msg.sender);
    }

    //getters
    function getProposalsList() public view returns(address[]) {
        return proposals;
    }

    function getProposal(Proposal proposal) public view returns(uint, bytes32, bytes32, bytes32, bytes32, uint, uint) {
        return(
        proposal.id(),
        proposal.title(),
        proposal.description(),
        proposal.videoLink(),
        proposal.documentsLink(),
        proposal.value(),
        uint(proposal.status())
        );
    }

    function getComments(Proposal proposal, uint _index) public view returns(address, uint, bytes32, uint) {
        return proposal.getComment(_index);
    }
}