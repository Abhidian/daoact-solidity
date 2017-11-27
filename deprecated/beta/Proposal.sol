pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

contract ACTVote is Ownable{
    
    using SafeMath for uint256;
    
    address private quorum;
    
    // sum of all funds that were used to buy ACT_VOTE tokens
    uint256 private fundsGiven;
    
    uint256 private exchangeRate;
    
    mapping(address => uint256) private balances;
    
    event ActSupportFund(address indexed contributor,uint256 amount);
    event ACTVotePurchase(address indexed buyer,uint256 amount, uint256 act_votes); 
    event ACTVoteTransfer(address indexed from,address indexed to,uint256 act_votes);
    
    function ACTVote(address _owner,address _quorum,uint256 _exchangeRate){
        require(_owner != 0x00);
        require(_quorum != 0x00);
        require(_exchangeRate > 0);
        
        owner = _owner;
        quorum = _quorum;
        exchangeRate = _exchangeRate;
    }

    function transfer(address _to, uint256 _value)returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ACTVoteTransfer(msg.sender, _to, _value);
        return true;
    }

    
    // support platform just by sending ethers
    function () payable{
        if(quorum.send(msg.value)){
            ActSupportFund(msg.sender,msg.value);
        }else{
            revert();
        }
    }

    function buyVotes() external payable {
        uint votes = msg.value * exchangeRate;
        balances[msg.sender] += votes;
        fundsGiven += msg.value;
        if(quorum.send(msg.value)){
            ACTVotePurchase(msg.sender,msg.value,votes);
        }else{
            revert();
        }
    }
    
    function funds() constant external returns (uint256){
        return fundsGiven;
    }
    
    function getVotePrice() constant external returns (uint256){
        return exchangeRate;
    }
    
    function setPrice(uint256 value)  external onlyOwner  returns (bool){
        exchangeRate = value;
        
        return true;
    }
    
    function quorumAddress() constant external returns (address){
        return quorum;
    }
    
    function updateQuorumAddress(address _newAddress)  external onlyOwner returns (bool){
        quorum = _newAddress;
        return true;
    }
    
    function balanceOf() constant external returns (uint256){
        return balances[msg.sender];
    }

    // Interface function
    function isContract() external returns (bool){
        return true;
    }
}

contract Quorum is Ownable{
    
    uint256 private curationTime;
    uint256 private votingTime;
    
    function Quorum(){
        
    }
    
    
    function () payable{
        
    }
    
    function getCurationTime() external constant returns(uint256){
        return curationTime;
    }
    
    function updateCurationTime(uint256 _value) external onlyOwner returns (uint256){
        return curationTime;
    }
    
    function getVotingTime() external constant returns(uint256){
        return votingTime;
    }
    
    function updateVotingTime(uint256 _value) external onlyOwner returns (uint256){
        return votingTime;
    }
    
}

contract ProposalModlue is Ownable{
    
    // Address of ACT Vote contract
    ACTVote voteContract; 
    
    // Address of Quorum contract
    Quorum quorum; 
    
    uint256 private curationValue;
   
    struct Proposed {
        uint256 proposalID; 
        address proposalOwner;
        uint256 value;
        State state;
        uint256 curationEnd;
        uint256 votingEnd;
        bytes description;
    }
    
    struct Comment {
        string text;
        uint256 likes;
        uint256 dislikes;
        address owner;
    }
    
    struct Vote{
        int256 value;
        address voter;
    }
    
    /**
     * A user can have only one proposal active
     * Active mean to following stages: INITIAL, IN_CURATION, IN_VOTING, IN_FUNDING
     */
    mapping(address => Proposed[]) proposals;
    
    // proposal id is the key
    mapping(uint256 => Comment[]) comments;
    
    // proposal id is the key
    mapping(uint256 => Vote[]) votes;
    
    mapping(address => bool) allowance;
    
    enum State{IN_CURATION, IN_VOTING,IN_FUNDING, RESIGNED_ON_CURATION, RESIGNED_ON_VOTING}
    
    event ProposalSubmitted(address indexed submitter,uint256 proposalID,uint256 fee);
    event CommentMade(address indexed owner,uint256 proposalID,bytes comment)
    event QuorumAddressUpdate(address indexed oldAddress,address indexed newAddress);
    event ACTVoteAddressUpdate(address indexed oldAddress,address indexed newAddress);
    
    function ProposalModlue(address _actVote,address _quorum){
        owner = msg.sender;
        voteContract = ACTVote(_actVote);
        quorum = Quorum(_quorum);
        require(voteContract.isContract()); // Calling interface function to make sure address is valid and alive
    }
    
    /**
     * Call this function to prompt submission fee to user before submitting proposal
     * @param _proposalValue Proposal funding target
     * @return submissionFee Fee required to submit proposal
     */
    function getSubmissionFee(uint256 _proposalValue) returns (uint256 submissionFee){
        // Obtaining sum of all funds that were used to buy ACT_Votes From ACTVote Contract
        uint256 fundsGiven = voteContract.funds();
        
        // Sum of all funds that were already released for funding From Quorum Contract
        uint256 releasedFunds = 0;
        
        // TODO: Floating point precision can be acheived with 
        uint256 fundsAvailable = (fundsGiven - releasedFunds) * 8/10;
        
        submissionFee = _proposalValue * curationValue / fundsAvailable;
        
        return;
    }
    
    /**
     */
    function submitProposal(bytes proposal,uint _value) external payable returns (bool) {
        require(allowance[msg.sender]);
        uint256 fee = getSubmissionFee(_value);
        require(msg.value >= fee); // Accept fee if it is higher than required
        uint256 id = now;
        proposals[msg.sender].push(Proposed({
            proposalID: id,
            proposalOwner: msg.sender,
            value: _value,
            state: State.IN_CURATION,
            curationEnd: quorum.getCurationTime(),
            votingEnd: quorum.getVotingTime(),
            description: proposal
        }));
        
        if(quorum.send(msg.value)){
            ProposalSubmitted(msg.sender,id,fee);
        }else{
            revert();
        }
        
        return true;
    }

    function addComment(uint256 proposalID,bytes comment) external returns (bool){
        comments[proposalID].push(Comment({
            text: comment,
            owner: msg.sender
        }));
        return true;
    }
    
   function likeComment(uint256 proposalID,bytes comment) external returns (bool){
        comments[proposalID].push(Comment({
            text: comment,
            owner: msg.sender
        }));
        return true;
    }

    function voteContractAddr()constant returns(address) {
        return voteContract;
    }
    
    function updateVoteContract(address _newAddress)external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        ACTVoteAddressUpdate(voteContract,_newAddress);
        voteContract = ACTVote(_newAddress);
        return true;
    }
    
    function quorumContractAddr()constant returns(address) {
        return quorum;
    }
    
    function updateQuorumContract(address _newAddress)external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        QuorumAddressUpdate(quorum,_newAddress);
        quorum = Quorum(_newAddress);
        return true;
    }
    
    function resigneProposal(address owner) internal returns(bool){
        delete allowance[address];
    }
    
    // function getState(uint256 index) constant returns (State){
    //     require(index >= 0);
    //     // return proposals[addres].state;
    // }
    
    // modifier inState(uint256 index,State state) {
    // require(index >= 0);
    // require(index < proposals.length);
    // require(getState(index) == state);
    // _;
    // }
    
}