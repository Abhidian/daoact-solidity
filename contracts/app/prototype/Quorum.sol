pragma solidity 0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Quorum is Ownable {
    
    using SafeMath for uint256;
    
    // 10% quorum
    uint256 private criterion = 10;
    
    // retain the ability to fund atleast 10 proposals
    uint256 private minAbility = 10;
  
    // 80% of the pool will be funded to proposals
    uint256 private proposalsPerc = 80;
    
    // 20% of the pool will be for foundation
    uint256 private foundationPerc = 20;
    
    // Foundation address to receive fundings
    address private foundationAddress;
    
    address private voteConAddress;
      
    event FundsReceived(address indexed sender,uint256 amount);
    event CriterionUpdated(uint256 _value);
    event AbilityUpdated(uint256 _value);
    event ProposalPercUpdated(uint256 _value);
    event FoundationPercUpdated(uint256 _value);
    event FoundationAddressUpdated(address _newAddress);
    event VoteConAddressUpdated(address _newAddress);
    event ProposalFunded(address indexed proposalOwner, uint256 proposalID, uint256 proposalFund, uint256 foundationFund);
    event ProposalRejected(address indexed proposalOwner, uint256 proposalID, uint256 votesInFavor, uint256 against);
    
    
    function Quorum(address _owner) public {
        require(_owner != address(0));
        owner = _owner;
    }
    
    function () public payable{
        FundsReceived(msg.sender,msg.value);
    }
    
    // re-entrancy vulnerability is on caller side because called is also a contract
    function fundProposal(uint256 _id, address _owner, uint256 _inFavor, uint256 _against, uint256 _target) voteContract external returns (bool,uint256){
        
        if( _inFavor >= criterion.div(_inFavor.add(_against)).mul(100) ){
            
            uint256 proposalFund;
            uint256 foundationFund;
            (proposalFund, foundationFund) = fundsAvailable();
            
            if(_target < proposalFund){
                   proposalFund = _target;
            }
            
            // Transfer funds to proposal owner and foundation 
            _owner.transfer(proposalFund);
            foundationAddress.transfer(foundationFund);
            ProposalFunded(_owner,_id,proposalFund,foundationFund);
            return (true,proposalFund);
        } else {
            
            ProposalRejected(_owner,_id,_inFavor,_against);
            return (false,0);
        }
    }
    
    
    function fundsAvailable() internal constant returns (uint256 proposalFund, uint256 foundationFund){
        return (
            proposalsPerc.div(this.balance).mul(100).div(minAbility),
            foundationPerc.div(this.balance).mul(100).div(minAbility)
        );
    }
    
    // Setters
    function updateCriterion(uint256 _value) external onlyOwner returns(bool){
        require(_value > 0);
        criterion = _value;
        CriterionUpdated(_value);
        return true;
    }
    function updateAbility(uint256 _value) external onlyOwner returns(bool){
        require(_value > 0);
        minAbility = _value;
        AbilityUpdated(_value);
        return true;
    }
    function updateProposalPerc(uint256 _value) external onlyOwner returns(bool){
        require(_value > 0);
        proposalsPerc = _value;
        ProposalPercUpdated(_value);
        return true;
    }
    function updateFoundationPerc(uint256 _value) external onlyOwner returns(bool){
        require(_value > 0);
        foundationPerc = _value;
        FoundationPercUpdated(_value);
        return true;
    }
    function updateFoundationAddress(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        foundationAddress = _newAddress;
        FoundationAddressUpdated(_newAddress);
        return true;
    }
    function updateVoteConAddress(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        voteConAddress = _newAddress;
        VoteConAddressUpdated(_newAddress);
        return true;
    }
    
    // getters
    function Balance() external constant returns(uint256){
        return this.balance;
    }
    function Criterion() external constant returns(uint256){
        return criterion;
    }
    function Ability() external constant returns(uint256){
        return minAbility;
    }
    function ProposalPer() external constant returns(uint256){
        return proposalsPerc;
    }
    function FoundationPer() external constant returns(uint256){
        return foundationPerc;
    }
    function FoundationAddress() external constant returns(address){
        return foundationAddress;
    }
    function VoteConAddress() external constant returns(address){
        return voteConAddress;
    }
    
    
    
    modifier voteContract(){
        require(msg.sender == voteConAddress);
        _;
    }
}