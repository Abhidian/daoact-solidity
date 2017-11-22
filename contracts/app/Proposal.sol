pragma solidity ^0.4.17;

import './ProposalController.sol';

contract Quorum { function check(uint _upVotes, uint _downVotes) external returns(bool, uint); }
contract Vote { function withdraw(address _from,uint256 _value) public returns(bool); }

contract Proposal {
    
    //system addresses variables
    ProposalController controller;
    Quorum quorumContract;
    Vote voteContract;
    address controllerAddress;
    
    //proposal status
    enum Status { curation, voting, directFunding, closed }
    Status public status;
    
    //curators comment
    struct Comment {
        uint timestamp;
        address author;
        bytes32 text;
        mapping(address => uint) upticks;
        mapping(address => uint) downticks;
        uint totalUpticks;
        uint totalDownticks;
    }
    
    //curators reaction
    struct Reaction {
        bool uptick;
        bool downtick;
        bool flag;
    }
    
    //proposal fields
    address private submiter; //address of submitter
    address private approver; //address of signerer to withdraw funds
    bool private activated; //is proposal activated by curators
    bool private quorumReached; //is quorum rached
    uint32 private curationPeriod = 48 hours;
    uint32 private votingPeriod = 48 hours;
    uint32 private directFundingPeriod = 72 hours;
    uint public id; //timestamp of proposal
    bytes32 public title;
    bytes32 public description;
    bytes32 public videoLink;
    bytes32 public documentsLink;
    uint public value;
    uint public funds; //how much funds have beed already funded
    uint public commentsIndex;
    uint public upVotes; // up votes from citizens
    uint public downVotes; //down votes from citizens
    
    //comments storage
    mapping(uint => Comment) comments;
    //agains citizens votes storage to be able to send back vote in case of quorum not reached
    mapping(address => bool) against;
    //cicitizen voters storage
    mapping(address => bool) voted;
    //curators reactions storage
    mapping(address => Reaction) reactions;
    
    function Proposal(address _submiter, address _approver, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public {
        require(_submiter != address(0));
        require(_approver != address(0));
        require(_approver != _submiter);
        require(_title.length > 0);
        require(_description.length > 0);
        require(_videoLink.length > 0);
        require(_value > 0);
        
        controller = ProposalController(msg.sender);
        controllerAddress = msg.sender;
        submiter = _submiter;
        id = now;
        title = _title;
        description = _description;
        videoLink = _videoLink;
        documentsLink = _documentsLink;
        value = _value;
        status = Status.curation;
        activated = false;
        quorumReached = false;
    }
    
    modifier onlyController() {
        require(msg.sender == controllerAddress);
        _;
    }
    
    modifier checkStatus(Status _status) {
        require(status == _status);
        _;
    }
    
    //citizen votes
    function vote(address _voter, uint _vote) external onlyController checkStatus(Status.voting) {
        
        require(voted[msg.sender] == false);
        
        if (now > id + votingPeriod) {
            status = Status.directFunding;
            (quorumReached, funds) = quorumContract.check(upVotes, downVotes);
        }
        
        require(voteContract.withdraw(msg.sender, 1));
        
        if (_vote == 1) {
            upVotes ++;
        } else if (_vote == 2) {
            downVotes ++;
            against[_voter] = true;
        } else {
            revert();
        }
        
        voted[_voter] = true;
    }
    
    //curators upticks
    function tick(address _curator, uint _tick, bool _flag) external onlyController checkStatus(Status.curation) {
        if (_flag == true) {
            require(reactions[_curator].flag == false);
            require(reactions[_curator].uptick == false);
            require(reactions[_curator].downtick == false);
            reactions[_curator].flag = true;
        }
        if (_tick == 1) {
            require(reactions[_curator].uptick == false);
            require(reactions[_curator].downtick == false);
            reactions[_curator].uptick = true;
        } else if (_tick == 2) {
            require(reactions[_curator].downtick == false);
            require(reactions[_curator].uptick == false);
            reactions[_curator].downtick = true;
        } else {
            revert();
        }
    }
    
    function flag(address _curator) external onlyController {
        require(reactions[_curator].flag == false);
        reactions[_curator].flag = true;
        //reputations score over 100
        //five flags will close proposal
        //ace balance should be more then 50million
    }
    
    function addComment(bytes32 _text) external onlyController checkStatus(Status.curation) {
        require(status == Status.curation);
        require(_text.length > 0);
        comments[commentsIndex] = Comment(now, msg.sender, _text, 0, 0);
        commentsIndex ++;
        
        if(now > id + curationPeriod) {
            status = Status.voting;
        }
    }
    
    function voteForComment(uint _index, uint _vote) external onlyController checkStatus(Status.curation) {
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
    
    function getComment(uint _index) external view onlyController returns(uint, address, bytes32, uint, uint) {
        return (
            comments[_index].timestamp,
            comments[_index].author,
            comments[_index].text,
            comments[_index].totalUpticks,
            comments[_index].totalDownticks
        );
    }
    
    function fundProposal() external payable onlyController checkStatus(Status.directFunding) {
        require(msg.value > 0);
        require(status == Status.directFunding);
        funds += msg.value;
    }
   
   function wirthdrawFunds(address _sender) external onlyController checkStatus(Status.closed) {
        require(_sender == submiter);
        submiter.transfer(this.balance);
        //add multisig
   }
}