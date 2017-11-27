pragma solidity 0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract ACTVote is Ownable{
    
    using SafeMath for uint256;
    
    address private quorum;
    
    address private proposalContract;
    
    // sum of all funds that were used to buy ACT_VOTE tokens
    uint256 private fundsGiven;
    
    // number of votes per ether
    uint256 private exchangeRate;
    
    mapping(address => uint256) private balances;
    
    event ACTVotePurchase(address indexed buyer,uint256 amount, uint256 votes); 
    event ACTVoteTransfer(address indexed from,address indexed to,uint256 votes);
    
    event ACTVoteSpent(address indexed voter,uint256 votes);
    event ACTVoteReturned(address indexed voter,uint256 votes);
    
    function ACTVote(address _owner, address _quorumAddr, address _proposalAddr, uint256 _exchangeRate) public{
        require(_owner != address(0));
        require(_quorumAddr != address(0));
        require(_proposalAddr != address(0));
        require(_exchangeRate > 0);

        owner = _owner;
        quorum = _quorumAddr;
        //proposalContract  = _proposalAddr;
        exchangeRate = _exchangeRate;
    }

    /* Remove after review
    function ACTVote() public {
        owner = 0xb115997626d0bE91Ee4b17AAd8330eFC7506C009;
        quorum = 0xab70CC544477F30ef5DCAb0025ffF40928671d8d;
        // proposalContract  = _proposalContract;
        exchangeRate = 100;
    }*/


    /**
     * Used for transfering votes from one account to another
     * @param _to Recepient adress
     * @param _value Number of votes to be transferred
     * @return bool True if transferred successfully
     */
    function transfer(address _to, uint256 _value) public returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ACTVoteTransfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Receive ethers and load ACT Votes to the account of sender
     */
    function buyVotes() external payable{
        uint votes = msg.value.mul(exchangeRate);
        require(votes == 10);
        
        balances[msg.sender] = balances[msg.sender].add(votes); 
        fundsGiven = fundsGiven.add(msg.value);
        if(quorum.send(msg.value)){
            ACTVotePurchase(msg.sender,msg.value,votes);
        }else{
            revert();
        }
    }
    
    /**
     * Return sum of funds that were used to buy ACT_VOTE tokens
     * @return Funds
     */
    function funds() constant external returns (uint256){
        return fundsGiven;
    }
    
    /**
     * Return ACT_VOTE price
     * @return price
     */
    function getVotePrice() constant external returns (uint256){
        return exchangeRate;
    }
    
    /**
     * Used to update ACT_VOTE exchange rate with respect to ethers
     * @param _value new exchange rate
     * @return true if successful
     */
    function setPrice(uint256 _value)  external onlyOwner  returns (bool){
        exchangeRate = _value;
        return true;
    }
    
    /**
     * Returns Address of Quorum Platform Contract
     * @return address
     */
    function quorumAddress() constant external returns (address){
        return quorum;
    }
    
    /**
     * Used to update Address of Quorum Platform Contract in case it is updated
     * @param _newAddress updated contract address 
     * @return true if successful
     */
    function updateQuorumAddress(address _newAddress)  external onlyOwner returns (bool){
        quorum = _newAddress;
        return true;
    }
    
     /**
     * Returns Address of Proposal Platform Contract
     * @return address
     */
    function proposalAddress() constant external returns (address){
        return proposalContract;
    }
    
    /**
     * Used to update Address of Proposal Contract in case it is updated
     * @param _newAddress updated contract address 
     * @return true if successful
     */
    function updateProposalAddress(address _newAddress)  external onlyOwner returns (bool){
        proposalContract = _newAddress;
        return true;
    }
    
    
    /**
     * Return ACT_Vote balance of sender
     * @return amount of ACT_VOTE
     */
    function balanceOf() constant external returns (uint256){
        return balances[msg.sender];
    }

    // Interface function
    function isContract() external pure returns (bool){
        return true;
    }
    
    function deposit(address _to,uint256 _value) onlyProposalCon external  returns(bool){
        require(_to != 0x00);
        require(_value > 0);
        balances[_to] = balances[_to].add(_value);
        ACTVoteReturned(_to, _value);
        return true;
    }
    
    function withdraw(address _from,uint256 _value) external onlyProposalCon returns(bool){
        require(_from != 0x00);
        require(_value > 0);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        ACTVoteSpent(_from,_value); 
        return true;
    }
    
    modifier onlyProposalCon(){
        require(msg.sender == proposalContract);
        _;
    }
    
}