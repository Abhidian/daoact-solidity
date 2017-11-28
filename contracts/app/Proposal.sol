pragma solidity ^0.4.18;

import './ProposalController.sol';

contract Quorum { function check(uint _upVotes, uint _downVotes) external returns(bool, uint); }
contract Vote { function withdraw(address _from, uint256 _value) public returns(bool); }
contract Curator { function calculateReputation(address _curatorAddress, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public; }

contract Proposal {
    
    //system addresses variables
    ProposalController controller;
    Quorum quorumContract;
    Vote voteContract;
    Curator curatorContract;
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
    address[] curators;
    
    //proposal fields
    address private submiter; //address of submitter
    address private approver; //address of signerer to withdraw funds
    bool private activated; //is proposal activated by curators
    bool private quorumReached; //is quorum rached
    uint8 private flagsCount; //total flags count
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
    uint public commentsIndex; //to get comments by index
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
        value = _value * 1 ether;
        status = Status.curation;
        activated = false;
        quorumReached = false;
    }

    //modifiers
    modifier onlyController() {
        require(msg.sender == controllerAddress);
        _;
    }
    
    modifier checkStatus(Status _status) {
        require(status == _status);
        _;
    }
    
    // CURATORS //
    
    //curators ticks
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal
    function tick(address _curator, uint _tick) external onlyController checkStatus(Status.curation) {
        require(reactions[_curator].flag == false);
        require(reactions[_curator].uptick == false);
        require(reactions[_curator].downtick == false);

        if (_tick == 1) {
            reactions[_curator].uptick = true;
        } else if (_tick == 2) {
            reactions[_curator].downtick = true;
        } else if (_tick == 3) {
            //reputations score over 100
            //ace balance should be more then ???
            reactions[_curator].flag = true;
            flagsCount ++;
            if (flagsCount >= 5) {
                status = Status.closed;
            }
        } else {
            revert();
        }
        curators.push(_curator);
        checkPeriod();
    }
    
    //curators comments
    function addComment(bytes32 _text) external onlyController checkStatus(Status.curation) {
        require(_text.length > 0);
        comments[commentsIndex] = Comment(now, msg.sender, _text, 0, 0);
        commentsIndex ++;
        checkPeriod();
    }
    
    //curators votes for comments
    //1 == up tick, 2 == down tick
    function voteForComment(uint _index, uint _vote) external onlyController checkStatus(Status.curation) {
        if (_vote == 1) {
            comments[_index].upticks[msg.sender] ++;
            comments[_index].totalUpticks ++;
        } else if (_vote == 2) {
            comments[_index].downticks[msg.sender] ++;
            comments[_index].totalDownticks ++;
        } else {
            revert();
        }
        checkPeriod();
    }

    // CITIZEN //

    //citizen votes
    // 1 == vote up, 2 == vote down
    function vote(address _voter, uint _vote) external onlyController checkStatus(Status.voting) {
        
        require(voted[_voter] == false);
        
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

    //direct funding
    function fundProposal() external payable onlyController checkStatus(Status.directFunding) {
        require(msg.value > 0);
        require(status == Status.directFunding);
        funds += msg.value;

        if (funds >= value) {
            status = Status.closed;
        }
    }

    function wirthdrawFunds(address _sender) external onlyController checkStatus(Status.closed) {
        require(_sender == submiter);
        submiter.transfer(this.balance);
        //add multisig
    }

    //internal functions
    function sendReputation() internal {
        for (uint i; i < curators.length; i ++) {
            curatorContract.calculateReputation(
                curators[i],
                activated,
                quorumReached,
                reactions[curators[i]].uptick,
                reactions[curators[i]].downtick,
                reactions[curators[i]].flag
            );
        }
    }
    
    function checkPeriod() internal {
        if (now > id + curationPeriod) {
            status = Status.voting;
        }
        if (now > id + curationPeriod + votingPeriod) {
            status = Status.directFunding;
        }
        if (now > id + curationPeriod + votingPeriod + directFundingPeriod) {
            status = Status.closed;
        }
    }
    
    //getters
    function getComment(uint _index) external view onlyController returns(uint, address, bytes32, uint, uint) {
        return (
            comments[_index].timestamp,
            comments[_index].author,
            comments[_index].text,
            comments[_index].totalUpticks,
            comments[_index].totalDownticks
        );
    }

    function getReaction(address _curator) external view onlyController returns(bool, bool, bool) {
        return (
            reactions[_curator].uptick,
            reactions[_curator].downtick,
            reactions[_curator].flag
        );
    }
}