pragma solidity ^0.4.18;

import './ProposalController.sol';

contract Proposal {

    ProposalController controller;
    address controllerAddress;

    //proposal fields
    address private submiter;
    uint public id;
    bytes32 public title;
    bytes32 public description;
    bytes32 public videoLink;
    bytes32 public documentsLink;
    uint public value;
    uint public funds;
    uint public commentsIndex;

    enum Status {onCuration, onVoting, onDirectFunding, closed}
    Status public status;

    //comment struct
    struct Comment {
        uint timestamp;
        address author;
        bytes32 text;
        mapping(address => uint) upticks;
        mapping(address => uint) downticks;
        uint totalUpticks;
        uint totalDownticks;
    }

    //comments storage
    mapping(uint => Comment) comments;

    function Proposal(address _submiter, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public {
        controller = ProposalController(msg.sender);
        controllerAddress = msg.sender;
        submiter = _submiter;
        id = now;
        title = _title;
        description = _description;
        videoLink = _videoLink;
        documentsLink = _documentsLink;
        value = _value;
        status = Status.onCuration;
    }

    modifier onlyController() {
        require(msg.sender == controllerAddress);
        _;
    }

    function addComment(bytes32 _text) external onlyController {
        require(_text.length > 0);
        comments[commentsIndex] = Comment(now, msg.sender, _text, 0, 0);
        commentsIndex ++;
    }

    function voteForComment(uint _index, uint _vote) external onlyController {
        if (_vote == 1) {
            comments[_index].upticks[msg.sender] ++;
            comments[_index].totalUpticks ++;
        } else if(_vote == 2) {
            comments[_index].downticks[msg.sender] ++;
            comments[_index].totalDownticks ++;
        } else {
            revert();
        }
    }

    function getComment(uint _index) external view onlyController returns(uint, address, bytes32, uint, uint){
        return (
            comments[_index].timestamp,
            comments[_index].author,
            comments[_index].text,
            comments[_index].totalUpticks,
            comments[_index].totalDownticks
        );
    }

    function fundProposal() external payable onlyController {
        require(msg.value > 0);
        funds += msg.value;
   }

   function wirthdrawFunds() external onlyController {
       //create multisig!
       //create time checker!
       submiter.transfer(this.balance);
       if(sendCuratorsReport()) {
            closeProposal();
       }
   }

   function sendCuratorsReport() internal returns(bool) {
       //send report to curators contract
       return true;
   }

   function closeProposal() internal {
       status = Status.closed;
       selfdestruct(submiter);
   }
}