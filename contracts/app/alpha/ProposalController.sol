pragma solidity ^0.4.18;

import './Proposal.sol';

contract Pool {
    function submitionFunding() external payable returns(bool);
    function fromProposalDirectFunding() external payable returns(bool);
}

contract Vote {
    function withdraw(address _from) external returns(bool);
}

contract Quorum {
    function checkCitizenQuorum(uint _upVotes, uint _downVotes, address _proposal, uint _value) external returns(bool, uint);
    function checkCuratorsQuorum(uint _upTicks, uint _downTicks) external returns(bool);
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

    uint128 public feeMin = 0.1 ether;
    uint128 public feeMax = 0.4 ether;

    event NewProposalForVoting(address indexed _proposal);

    function ProposalController() public {
        owner = msg.sender;
    }

    //activizm - 1; not activizm - 2
    function createProposal(address _approver, uint _activism, bytes32 _title, bytes32 _description, bytes32 _videoLink, bytes32 _documentsLink, uint _value) public payable returns(Proposal proposal) {
        if (_value <= 22 * 1 ether) {
            require(msg.value == feeMin);
        } else {
            require(msg.value == feeMax);
        }
        require(poolContract.submitionFunding.value(msg.value)());
        proposal = new Proposal(msg.sender, _approver, _activism, _title, _description, _videoLink, _documentsLink, _value);
        proposals.push(proposal);
        return proposal;
    }

    function setDependencies(address _vote, address _pool, address _curator, address _quorum) public onlyOwner {
        voteContract = Vote(_vote);
        poolContract = Pool(_pool);
        curatorContract = Curator(_curator);
        quorumContract = Quorum(_quorum);
    }

    //tick proposal by curator
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal, 4 == not activism
    function tickProposal(Proposal proposal, uint8 _tick) public {
        require(curatorContract.limits(msg.sender, _tick));
        require(proposal.tick(msg.sender, _tick));
        var proposalTimestamp = proposal.id();

        if (now > proposalTimestamp.add(1 minutes)) {
            if (quorumContract.checkCuratorsQuorum(proposal.totalUpticks(), proposal.totalDownticks())) {
                require(proposal.setActivated());
                require(proposal.setStatus(1));//set status "Voting"
                NewProposalForVoting(proposal);
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
        require(author != msg.sender);
        curatorContract.calcEffort(reputation, author);
        proposal.uptickComment(_index, msg.sender);
    }

    //citizen vote
    //1 == vote up, 2 == vote down
    function citizenVote(Proposal proposal, uint8 _vote) public {
        require(proposal.vote(msg.sender, _vote));
        require(voteContract.withdraw(msg.sender));
        var proposalTimestamp = proposal.id();
        if (now > proposalTimestamp.add(1 minutes).add(1 minutes)) {
            var (reached, funds) =  quorumContract.checkCitizenQuorum(proposal.upVotes(), proposal.downVotes(), proposal, proposal.value());
            if (reached == true) {
                require(proposal.setQuorumReached());
                require(proposal.setFunds(funds));
                if (funds < proposal.value()) {
                    require(proposal.setStatus(2));//set status "Direct funding"
                } else {
                    require(proposal.setStatus(3));//set status "Closed"
                }
            } else {
                //close proposal in case of quorum not reached
                require(proposal.setStatus(3));//set status "Closed"
            }
        }
    }

    //proposal direct funding
    //TEST HARDLY!!!!
    function directFunding(Proposal proposal) public payable {
        require(msg.value > 0);
        var funds = msg.value;
        var proposalPart = funds.mul(95).div(100);
        var foundationPart = funds.mul(5).div(100);
        require(proposal.fundProposal.value(proposalPart)());
        require(poolContract.fromProposalDirectFunding.value(foundationPart)());
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
        return (
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

    function getProposalInfo(Proposal proposal) public view returns(uint, uint, uint, bool, uint, uint, uint, bool) {
        return (
            proposal.totalUpticks(),
            proposal.totalDownticks(),
            proposal.flagsCount(),
            proposal.activated(),
            proposal.funds(),
            proposal.upVotes(),
            proposal.downVotes(),
            proposal.activism()
        );
    }

    function getComment(Proposal proposal, uint _index, address _curator) public view returns(address, uint, bytes32, uint, bool) {
        return proposal.getComment(_index, _curator);
    }

    function isVoted(Proposal proposal, address _citizen) public view returns(bool) {
        return proposal.isVotedByCitizen(_citizen);
    }

    function isTicked(Proposal proposal, address _curator) public view returns(bool) {
        return proposal.isTickedByCurator(_curator);
    }
}