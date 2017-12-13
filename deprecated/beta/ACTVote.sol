pragma solidity ^0.4.13;

import "Ownable.sol";

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


    /**
     * Used for transfering votes from one account to another
     * @param _to Recepient adress
     * @param _value Number of votes to be transferred
     * @return bool True if transferred successfully
     */
    function transfer(address _to, uint256 _value)returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ACTVoteTransfer(msg.sender, _to, _value);
        return true;
    }

    
    /**
     * Receive ethers sent for supporting ACT platform
     */
    function supportPlatform() payable{
        if(quorum.send(msg.value)){
            ActSupportFund(msg.sender,msg.value);
        }else{
            revert();
        }
    }

    /**
     * Receive ethers and load ACT Votes to the account of sender
     */
    function buyVotes() external payable  external payable {
        uint votes = msg.value * exchangeRate;
        balances[msg.sender] += votes;
        fundsGiven += msg.value;
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
     * Return ACT_Vote balance of sender
     * @return amount of ACT_VOTE
     */
    function balanceOf() constant external returns (uint256){
        return balances[msg.sender];
    }

    // Interface function
    function isContract() external returns (bool){
        return true;
    }
    
}