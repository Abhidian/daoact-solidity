contract Quorum is Ownable{
    
    uint256 private curationTime;
    uint256 private votingTime;
    
    function Quorum(){
        
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
