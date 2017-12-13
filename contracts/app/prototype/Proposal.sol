pragma solidity 0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract ACTVote{
    function deposit(address _to,uint256 _value) public returns(bool);
    function withdraw(address _from,uint256 _value) public returns(bool);
    function isContract() public returns (bool);
}
contract Quorum{
     function fundProposal(uint256 _id, address _owner, uint256 _inFavor, uint256 _against, uint256 _target) public returns (bool,uint256);
}

contract ProposalModule is Ownable{
    
    using SafeMath for uint256;
    
    // Address of ACT Vote contract
    ACTVote voteContract; 
    
    // Address of Quorum contract
    Quorum quorum;
    
    uint256 public directFundingDuration = 48 hours;
    uint256 public votingDuration = 120 hours; // (120 - 48 = 72)
    
    struct Proposal {
        address owner;
        uint256 ethValue;
        bytes trackingLink;
        bytes title;
        bytes description;
        uint256 funding;
        bool inVoting;
        bool quorum;
    }
    
    // ProposalID => Proposal
    mapping(uint256 => Proposal) private proposals;
    uint256[] public proposalIndex;
    
    struct Vote{
        uint256 upVotes;
        uint256 downVotes;
        mapping(address => bool) against;
        mapping(address => bool) voted;
    }
    
    // ProposalID => Vote
    mapping(uint256 => Vote) private votes;
    
    event LogNewProposal(address indexed owner, uint256 index, uint256 indexed proposalID, uint256 ethValue, bytes trackingLink, bytes title, bytes description);
    
    event VoteCasted(uint256 indexed proposalID,address indexed voter,int vote);
    
    event DirectFunded(address indexed contributor,uint256 indexed proposalID, uint256 amount);
    
    event QuorumAddressUpdate(address indexed oldAddress,address indexed newAddress);
    
    event ACTVoteAddressUpdate(address indexed oldAddress,address indexed newAddress);
    
    function ProposalModule(address _owner, address _actVoteAddr, address _quorumAddr) public {
        
        require(_owner != address(0));
        require(_quorumAddr != address(0));
        require(_actVoteAddr != address(0));

        owner = _owner;
        voteContract = ACTVote(_actVoteAddr);
        quorum = Quorum(_quorumAddr);
        require(voteContract.isContract()); // Calling interface function to make sure address is valid and alive
    }
    
    function submitProposal(uint256 _value,bytes _trackingLink,bytes _title,bytes _description) external returns(uint256 index){
        
        uint256 id = now;
        require(_value > 0);
        require(_trackingLink.length > 14);
        require(_title.length > 10);
        require(_description.length > 1024);
        
        proposals[id].owner = msg.sender;
        proposals[id].ethValue = _value;
        proposals[id].trackingLink  = _trackingLink;
        proposals[id].title = _title;
        proposals[id].description = _description;
        proposals[id].funding = 0;
        proposals[id].inVoting = true;
        proposals[id].quorum = false;
        
        proposalIndex.push(id);
    
        LogNewProposal(msg.sender, proposalIndex.length-1,id, _value, _trackingLink, _title, _description);
        return proposalIndex.length-1;
    }
  
    function getProposal(uint256 _id) isValid(_id) external constant returns(address,uint256, bytes, bytes, bytes,uint256) {
        
        return (proposals[_id].owner,
                proposals[_id].ethValue,
                proposals[_id].trackingLink,
                proposals[_id].title,
                proposals[_id].description,
                proposals[_id].funding);
    }
    
    // _inFavor == 1 (Upvote)
    function castVote(uint256 _proposalID,uint8 _inFavor) external isValid(_proposalID) returns (bool){
        
        require(proposals[_proposalID].inVoting);
        require(votes[_proposalID].voted[msg.sender] == false);


        if (now > _proposalID.add(votingDuration)){
            
            // trigger quorum contract for evaluation
            proposals[_proposalID].inVoting = false;
            (proposals[_proposalID].quorum,proposals[_proposalID].funding) = quorum.fundProposal(_proposalID,proposals[_proposalID].owner,votes[_proposalID].upVotes,votes[_proposalID].downVotes,proposals[_proposalID].ethValue);
            return true;
        }
    
        require(voteContract.withdraw(msg.sender,1));
        
        if(_inFavor == 1){
            
            votes[_proposalID].upVotes++; 
            VoteCasted(_proposalID,msg.sender,1);
        }else{
            
            votes[_proposalID].downVotes++;
            VoteCasted(_proposalID,msg.sender,-1);
            votes[_proposalID].against[msg.sender] = true; // So that spender can get back down vote in case proposal cannot reach quorum
        }

        votes[_proposalID].voted[msg.sender] = true;
        return true;
    }

    function upVotes(uint256 _proposalID) isValid(_proposalID) public constant returns (uint256){
        return votes[_proposalID].upVotes;
    }
    
    function isVoted(uint256 _proposalID) public constant returns (bool) {
        return votes[_proposalID].voted[msg.sender];
    }

    function downVotes(uint256 _proposalID) isValid(_proposalID) public constant  returns (uint256){
        return votes[_proposalID].downVotes;
    }
    
    function downVoter(uint256 _proposalID, address voter) isValid(_proposalID) public  constant returns (bool){
        return votes[_proposalID].against[voter];
    }
    
     function releaseVote(uint256 _proposalID, address voter) isValid(_proposalID) public returns (bool){
        require(!proposals[_proposalID].inVoting);
        require(!proposals[_proposalID].quorum);
        require(votes[_proposalID].against[voter]);
        votes[_proposalID].against[voter] = false;
        return voteContract.deposit(msg.sender,1);
    }

    /**
     * Receive ethers and directly send to proposals
     */
    function directSupport(uint256 _proposalID) payable isValid(_proposalID)external returns (bool){
        
        require(proposals[_proposalID].quorum);
        require(proposals[_proposalID].funding < proposals[_proposalID].ethValue);
        
        uint256 needed = proposals[_proposalID].ethValue.sub(proposals[_proposalID].funding);
        
        //@middleware dev: Subtract funding from ethValue and send exactly equall needed amount
        require(needed == msg.value);
        
        require(now < _proposalID.add(directFundingDuration));
        
        // Sending directly to proposal owner
        if(proposals[_proposalID].owner.send(msg.value)){
            proposals[_proposalID].funding += msg.value;
            DirectFunded(msg.sender,_proposalID,msg.value);
        }else{
            revert();
        }
        
        return true;
    }
    
    function voteContractAddr() public constant returns(address) {
        return voteContract;
    }
    
    function updateVoteContract(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        ACTVoteAddressUpdate(voteContract,_newAddress);
        voteContract = ACTVote(_newAddress);
        return true;
    }
    
    function quorumContractAddr() public constant returns(address) {
        return quorum;
    }
    
    function updateQuorumContract(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        QuorumAddressUpdate(quorum,_newAddress);
        quorum =  Quorum(_newAddress);
        return true;
    }
    
    modifier isValid(uint256 id){
        require(proposals[id].owner != 0x00);
        _;
    }
    
}