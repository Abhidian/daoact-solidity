pragma solidity 0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Pool {
    function votesFunding() external payable;
}

contract Vote is Ownable{

    using SafeMath for uint256;

    address private quorum;

    address private proposalController;

    // sum of all funds that were used to buy ACT_VOTE tokens
    uint256 private fundsGiven;

    // number of votes per ether
    uint private ethPrice;
    uint private votePrice;

    mapping(address => uint256) private balances;

    event ACTVotePurchase(address indexed buyer,uint256 amount, uint256 votes);
    event ACTVoteTransfer(address indexed from,address indexed to,uint256 votes);

    event ACTVoteSpent(address indexed voter,uint256 votes);
    event ACTVoteReturned(address indexed voter,uint256 votes);

    function Vote(){
        owner = msg.sender;
        ethPrice = 850 * 100;
        votePrice = 1 ether / ethPrice;
    }

    modifier onlyProposalController() {
        require(msg.sender == proposalController);
        _;
    }

    function setQuorumAddress (address _quorumAddr) public onlyOwner {
        require(_quorumAddr != address(0));
        quorum = _quorumAddr;
    }

    function setProposalControllerAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0));
        proposalController = _newAddress;
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
     * Receive ethers and load ACT Votes to the account of sender
     */
    function buyVotes() external payable{
        uint fromMsg = msg.value.div(votePrice);
        uint votes = fromMsg.div(100);
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
    function getEthPrice() constant external returns (uint256){
        return ethPrice;
    }

    /**
     * Used to update ACT_VOTE exchange rate with respect to ethers
     * @param _value new exchange rate should be with 2 decimals and multiplied by 100
     * @return true if successful
     */
    function setEthPrice(uint256 _value)  external onlyOwner  returns (bool){
        ethPrice = _value;
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
     * Used to update Address of Proposal Contract in case it is updated
     * @param _newAddress updated contract address
     * @return true if successful
     */
    function updateProposalControllerAddress(address _newAddress) external onlyOwner returns (bool) {
        proposalController = _newAddress;
        return true;
    }


    /**
     * Return ACT_Vote balance of sender
     * @return amount of ACT_VOTE
     */
    function balanceOf(address _owner) constant external returns (uint256){
        return balances[_owner];
    }

    // Interface function
    function isContract() external returns (bool){
        return true;
    }

    function deposit(address _to,uint256 _value) onlyProposalController external  returns(bool){
        require(_to != 0x00);
        require(_value > 0);
        balances[_to] = balances[_to].add(_value);
        ACTVoteReturned(_to, _value);
        return true;
    }

    function withdraw(address _from,uint256 _value) external onlyProposalController returns(bool){
        require(_from != 0x00);
        require(_value > 0);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        ACTVoteSpent(_from,_value);
        return true;
    }



}