pragma solidity ^0.4.18;

import '../../misc/SafeMath.sol';
import './ProposalController.sol';
import '../../misc/Ownable.sol';

contract Proposal is Ownable {

    using SafeMath for *;

    ProposalController controller;

    //proposal status
    enum Status { curation, voting, directFunding, closed }
    Status public status;

    //curators comment
    struct Comment {
        address author;
        uint timestamp;
        bytes32 text;
        uint totalUpticks;
        mapping(address => bool) upticked;
    }

    //curators reaction
    struct Reaction {
        bool uptick;
        bool downtick;
        bool flag;
        bool notActivism;
    }

    //proposal fields
    address public controllerAddress; //controller address for modifier
    address public submitter; //address of submitter
    address public approver; //address of signerer to withdraw funds
    bool public activated; //is proposal activated by curators
    bool public quorumReached; //is quorum rached
    bool public withdrawn; //withdraw indicator
    bool public pendingWithdraw; //indicate that submitter requested withdraw proccess
    uint public flagsCount; //total flags count
    uint public notActivism; //total amount of non activism ticks
    uint32 public curationPeriod = 48 hours;
    uint32 public votingPeriod = 48 hours;
    uint32 public directFundingPeriod = 72 hours;
    uint public totalUpticks; //total proposal upticks from curators
    uint public totalDownticks; //total proposal downticks from curators

    uint public id; //timestamp of proposal
    bytes32 public title; //proposal title
    bytes32 public description; //proposal description
    bytes32 public videoLink; //proposal video url
    bytes32 public documentsLink; //proposal documents url
    uint public value; //proposal requested amount
    uint public funds; //how much funds have beed already funded
    uint public commentsIndex; //indexes in order to get comments
    uint public upVotes; //total up votes from citizens
    uint public downVotes; //total down votes from citizens

    //comments storage
    mapping(uint => Comment) comments;
    //agains citizens votes storage to be able to send back vote in case of quorum not reached
    mapping(address => bool) against;
    //citizen voters storage
    mapping(address => bool) voted;
    //curators reactions storage
    mapping(address => Reaction) reactions;
    //indicate curator action and allow to get reputation
    mapping(address => bool) reputationExisted;

    function Proposal(address _submitter, address _approver, bool _activism, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public {
        require(_submitter != address(0));
        require(_approver != address(0));
        require(_approver != _submitter);
        require(_title.length > 0);
        require(_description.length > 0);
        require(_videoLink.length > 0);
        require(_value > 0);
        owner = msg.sender;

        if (_activism == false) {
            status = Status.directFunding;
        }

        controller = ProposalController(msg.sender);
        controllerAddress = msg.sender;
        submitter = _submitter;
        id = now;
        title = _title;
        description = _description;
        videoLink = _videoLink;
        documentsLink = _documentsLink;
        value = _value.mul(1 ether);
        status = Status.curation;
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
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal, 4 == not activism
    function tick(address _curator, uint8 _tick) external onlyController checkStatus(Status.curation) returns(bool) {
        require(reactions[_curator].flag == false);
        require(reactions[_curator].uptick == false);
        require(reactions[_curator].downtick == false);
        require(reactions[_curator].notActivism == false);
        if (_tick == 1) {
            reactions[_curator].uptick = true;
        } else if (_tick == 2) {
            reactions[_curator].downtick = true;
        } else if (_tick == 3) {
            reactions[_curator].flag = true;
            flagsCount = flagsCount.add(1);
            if (flagsCount >= 5) {
                status = Status.closed;
            }
        } else if (_tick == 4) {
            reactions[_curator].notActivism == true;
            notActivism = notActivism.add(1);
            if (notActivism >= 5) {
                status = Status.directFunding;
            }
        } else {
            revert();
        }

        reputationExisted[_curator] = true;
        return true;
    }

    function setActivated() external onlyController returns(bool) {
        require(activated == false);
        activated = true;
        return true;
    }

    function setStatus(uint8 _status) external onlyController returns(bool) {
        if (_status == 1) {
            status = Status.voting;
        } else if (_status == 2) {
            status = Status.directFunding;
        } else if (_status == 3) {
            status = Status.closed;
        } else {
            revert();
        }
        return true;
    }

    function setQuorumReached() external onlyController returns(bool) {
        require(quorumReached == false);
        quorumReached = true;
        return true;
    }

    function setFunds(uint _funds) external onlyController returns(bool) {
        require(funds == 0);
        funds = _funds;
    }

    //curators comments
    function addComment(address _curator, bytes32 _text) external onlyController checkStatus(Status.curation) {
        require(_text.length > 0);
        comments[commentsIndex] = Comment(_curator, now, _text, 0);
        commentsIndex = commentsIndex.add(1);
        reputationExisted[_curator] = true;
    }

    //curators upticks for comments
    //should send 1 to uptick, another values not allowed
    //request should include index of comment
    //should save index on middleware during get proccess in order to request exact comment!
    function uptickComment(uint _index, address _curator) external onlyController checkStatus(Status.curation) {
        require(comments[_index].upticked[_curator] == false);
        comments[_index].upticked[_curator] == true;
        comments[_index].totalUpticks = comments[_index].totalUpticks.add(1);
    }

    // CITIZEN //

    //citizen votes
    // 1 == vote up, 2 == vote down
    function vote(address _voter, uint _vote) external onlyController checkStatus(Status.voting) returns(bool) {

        require(voted[_voter] == false);
        voted[_voter] = true;

        if (_vote == 1) {
            upVotes = upVotes.add(1);
        } else if (_vote == 2) {
            against[_voter] = true;
            downVotes = downVotes.add(1);
        } else {
            revert();
            return false;
        }

        return true;
    }

    //direct funding
    function fundProposal() external payable onlyController checkStatus(Status.directFunding) {
        require(msg.value > 0);
        require(status == Status.directFunding);
        funds = funds.add(msg.value);

        if (funds >= value) {
            status = Status.closed;
        }
    }

    //submitter funds request
    function wirthdrawFunds(address _requester) external onlyController checkStatus(Status.closed) {
        require(withdrawn == false);
        require(_requester == submitter || _requester == approver);
        if (_requester == submitter) {
            require(pendingWithdraw == false);
            pendingWithdraw = true;
        }
        if (_requester == approver) {
            require(pendingWithdraw == true);
            withdrawn = true;
            submitter.transfer(this.balance);
        }
    }

    //Should be called by curator from controller
    function getReputation(address _curator) external onlyController checkStatus(Status.directFunding) returns(bool, bool, bool, bool, bool) {
        require(reputationExisted[_curator] == true);
        reputationExisted[_curator] = false;
        return (
            activated,
            quorumReached,
            reactions[_curator].uptick,
            reactions[_curator].downtick,
            reactions[_curator].flag
        );
    }

    //getters

    //save index of comment on middleware during get proccess!
    function getComment(uint _index) external view onlyController returns(address, uint, bytes32, uint) {
        return (
            comments[_index].author,
            comments[_index].timestamp,
            comments[_index].text,
            comments[_index].totalUpticks
        );
    }

    function getCommentAuthor(uint _index) external view onlyController returns(address) {
        return comments[_index].author;
    }

    function getReaction(address _curator) external view onlyController returns(bool, bool, bool) {
        return (
            reactions[_curator].uptick,
            reactions[_curator].downtick,
            reactions[_curator].flag
        );
    }
}