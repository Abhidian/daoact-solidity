pragma solidity ^0.4.18;

import './Proposal.sol';

contract ProposalController {
    
    //proposals storage
    address[] proposals;
    
    function creatProposal(address _approver, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public returns(Proposal proposal) {
        proposal = new Proposal(msg.sender, _approver, _title, _description, _videoLink, _documentsLink, _value);
        proposals.push(proposal);
        return proposal;
    }
    
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
            uint(proposal.status())
        );
    }
    
    function addComment(Proposal proposal, bytes32 _text) public {
        proposal.addComment(_text);
    }
    
    function getProposalComment(Proposal proposal, uint _index) public view returns(uint, address, bytes32, uint, uint) {
        return proposal.getComment(_index);
    }
    
    function fundProposal(Proposal proposal) public payable {
        proposal.fundProposal.value(msg.value)();
    }
    
    function requestWithdraw(Proposal proposal) public {
        proposal.wirthdrawFunds(msg.sender);
    }

}