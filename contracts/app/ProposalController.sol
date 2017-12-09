pragma solidity ^0.4.18;

import './Proposal.sol';

contract ProposalController {
    
    //proposals storage
    address[] proposals;

    event NewProposal(address indexed _proposal);
    
    function creatProposal(address _approver, bool _activism, uint _fee, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public returns(Proposal proposal) {
        proposal = new Proposal(msg.sender, _approver, _activism, _fee,  _title, _description, _videoLink, _documentsLink, _value);
        proposals.push(proposal);
        NewProposal(proposal);
        return proposal;
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
}