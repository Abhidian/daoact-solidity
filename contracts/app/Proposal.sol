pragma solidity ^0.4.18;

import '../misc/SafeMath.sol';
import './ProposalController.sol';

//interfaces
contract Quorum { 
    function checkCitizenQuorum(uint _upVotes, uint _downVotes) external returns(bool, uint);
    function checkQuratorsQuorum(uint _upTicks, uint _downTicks) external returns(bool); 
}
contract Vote { 
    function withdraw(address _from, uint256 _value) public returns(bool); 
}
contract Curator {
    function calculatePosotiveReputation(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public;
    function calculateNegativeReputation(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public;
    function markAsProcessed(address _proposal, address _curator) external;
    function limits(address _curator, uint8 _action) external returns(bool);
    function getReputation (address _curator) external view returns(uint);
    function calcEffort (uint _effort, address _curator) external;
}

contract Proposal {

    using SafeMath for *;
    
    //system addresses variables
    ProposalController controller;
    Quorum quorumContract;
    Vote voteContract;
    Curator curatorContract;
    
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
    
    uint private feeMin = 0.1 ether;
    uint private feeMax = 0.4 ether;
    //proposal fields
    address private controllerAddress; //controller address for modifier
    address private submitter; //address of submitter
    address private approver; //address of signerer to withdraw funds
    bool private activated; //is proposal activated by curators
    bool private quorumReached; //is quorum rached
    bool private withdrawn; //withdraw indocator
    bool private pendingWithdraw; //indicate that submitter requested withdraw proccess
    uint private flagsCount; //total flags count
    uint private notActivism; //total amount of non activism ticks
    uint32 private curationPeriod = 48 hours;
    uint32 private votingPeriod = 48 hours;
    uint32 private directFundingPeriod = 72 hours;
    uint private totalUpticks; //total proposal upticks from curators
    uint private totalDownticks; //total proposal downticks from curators

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
    
    function Proposal(address _submitter, address _approver, bool _activism, uint _fee, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public {
        require(_submitter != address(0));
        require(_approver != address(0));
        require(_approver != _submitter);
        require(_title.length > 0);
        require(_description.length > 0);
        require(_videoLink.length > 0);
        require(_value > 0);
        
        if (_value <= 22) {
            require(_fee == feeMin);
        } else {
            require(_fee == feeMax);
        }

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
    function tick(address _curator, uint8 _tick) external onlyController checkStatus(Status.curation) {
        require(reactions[_curator].flag == false);
        require(reactions[_curator].uptick == false);
        require(reactions[_curator].downtick == false);
        require(reactions[_curator].notActivism == false);
        require(curatorContract.limits(_curator, _tick));
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
        
        if (now > curationPeriod) {
            if (quorumContract.checkQuratorsQuorum(totalUpticks, totalDownticks)) {
                activated = true;
                status = Status.voting;
            } else {
                activated = false;
                status = Status.closed;
            }
        }
    }
    
    //curators comments
    function addComment(address _curator, bytes32 _text) external onlyController checkStatus(Status.curation) {
        require(curatorContract.limits(_curator, 5));
        require(_text.length > 0);
        commentsIndex = commentsIndex.add(1);
        comments[commentsIndex] = Comment(_curator, now, _text, 0);
        reputationExisted[_curator] = true;
    }
    
    //curators upticks for comments
    //should send 1 to uptick, another values not allowed
    //request should include address of comment author
    //should save index on middleware during get proccess in order to request exact comment!
    function uptickComment(uint _index, address _curator) external onlyController checkStatus(Status.curation) {
        require(comments[_index].upticked[_curator] == false);
        require(curatorContract.limits(_curator, 6));
        comments[_index].upticked[_curator] == true;
        var reputation = curatorContract.getReputation(_curator);
        comments[_index].totalUpticks = comments[_index].totalUpticks.add(1);
        curatorContract.calcEffort(reputation, comments[_index].author);
    }

    // CITIZEN //

    //citizen votes
    // 1 == vote up, 2 == vote down
    function vote(address _voter, uint _vote) external onlyController checkStatus(Status.voting) {
        
        require(voted[_voter] == false);
        require(voteContract.withdraw(_voter, 1));
        voted[_voter] = true;
        
        if (_vote == 1) {
            upVotes = upVotes.add(1);
        } else if (_vote == 2) {
            against[_voter] = true;
            downVotes = downVotes.add(1);
        } else {
            revert();
        }

        if (now > id.add(curationPeriod).add(votingPeriod)) {
            (quorumReached, funds) = quorumContract.checkCitizenQuorum(upVotes, downVotes);
            if (funds < value) {
                status = Status.directFunding;
            } else {
                status = Status.closed;
            }
        }
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

    //Should be called by curator
    function getReputation(address _curator) external onlyController checkStatus(Status.directFunding) {
        require(reputationExisted[_curator] == true);
        reputationExisted[_curator] = false;
        curatorContract.calculatePosotiveReputation(
            _curator,
            activated,
            quorumReached,
            reactions[_curator].uptick,
            reactions[_curator].downtick,
            reactions[_curator].flag
        );
        curatorContract.calculateNegativeReputation(
            _curator,
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

    function getReaction(address _curator) external view onlyController returns(bool, bool, bool) {
        return (
            reactions[_curator].uptick,
            reactions[_curator].downtick,
            reactions[_curator].flag
        );
    }
}