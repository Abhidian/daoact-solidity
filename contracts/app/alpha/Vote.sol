pragma solidity ^0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Pool {
    function votesFunding() external payable;
}

contract Vote is Ownable {

    using SafeMath for uint256;

    address public quorum;
    address public proposalController;

    // sum of all funds that were used to buy ACT_VOTE tokens
    uint256 public fundsGiven;

    // number of votes per ether
    uint256 public exchangeRate;

    mapping(address => uint256) private balances;

    event ACTVotePurchase(address indexed buyer,uint256 amount, uint256 votes);
    event ACTVoteTransfer(address indexed from,address indexed to,uint256 votes);

    event ACTVoteSpent(address indexed voter,uint256 votes);
    event ACTVoteReturned(address indexed voter,uint256 votes);

    function Vote(uint256 _exchangeRate) public {
        owner = msg.sender;
        require(owner != address(0));
        require(_exchangeRate > 0);

        exchangeRate = _exchangeRate; //exchange should be uint value in 65000 format. 65000 means 650.00 USD.
    }

    modifier onlyProposalController() {
        require(msg.sender == proposalController);
        _;
    }

    function setQuorumAddress (address _quorumAddr) public onlyOwner {
        require(_quorumAddr != address(0));
        quorum = _quorumAddr;
    }

    /**
     * Used for transfering votes from one account to another
     * @param _to Recepient adress
     * @param _value Number of votes to be transferred
     * @return bool True if transferred successfully
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ACTVoteTransfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Receive ethers and load ACT Votes to the account of sender
     */
    function buyVotes() external payable {
        uint votes = msg.value.mul(exchangeRate);
        require(votes == 10);

        balances[msg.sender] = balances[msg.sender].add(votes);
        fundsGiven = fundsGiven.add(msg.value);
        if (quorum.send(msg.value)) {
            ACTVotePurchase(msg.sender,msg.value,votes);
        } else {
            revert();
        }
    }

    /**
     * Return sum of funds that were used to buy ACT_VOTE tokens
     * @return Funds
     */
    function funds() view external returns (uint256) {
        return fundsGiven;
    }

    /**
     * Return ACT_VOTE price
     * @return price
     */
    function getVotePrice() constant external returns (uint256) {
        return exchangeRate;
    }

    /**
     * Used to update ACT_VOTE exchange rate with respect to ethers
     * @param _value new exchange rate
     * @return true if successful
     */
    function setPrice(uint256 _value) external onlyOwner returns (bool) {
        exchangeRate = _value;
        return true;
    }

    /**
     * Used to update Address of Quorum Platform Contract in case it is updated
     * @param _newAddress updated contract address
     * @return true if successful
     */
    function updateQuorumAddress(address _newAddress) external onlyOwner returns (bool) {
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
    function balanceOf(address _who) view external returns (uint256) {
        return balances[_who];
    }

    // Interface function
    function isContract() pure external returns (bool) {
        return true;
    }

    function deposit(address _to, uint256 _value) external onlyProposalController returns(bool) {
        require(_to != address(0));
        require(_value > 0);
        balances[_to] = balances[_to].add(_value);
        ACTVoteReturned(_to, _value);
        return true;
    }

    function withdraw(address _from) external onlyProposalController returns(bool) {
        require(_from != address(0));
        require(balances[_from] > 0);
        balances[_from] = balances[_from].sub(1);
        ACTVoteSpent(_from, 1);
        return true;
    }
}