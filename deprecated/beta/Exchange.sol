pragma solidity ^0.4.13;

import "SafeMath.sol";

contract ACTION{
    function balanceOf(address _owner) returns (uint256);
    function deposit(address _to,uint256 _value) returns (bool);
    function withdraw(address _from,uint256 _value) returns (bool);
    function isContract() external returns(bool);
}

contract ACTToken{
    function balanceOf(address _owner) returns (uint256);
    function deposit(address _to,uint256 _value) returns(bool);
    function withdraw(address _from,uint256 _value) returns(bool);
    function isContract() constant returns(bool);
}

contract Exchange{
    using SafeMath for uint256;

    address private owner;

    ACTToken private actToken;
    
    ACTION private actionToken;
    
    // ExchangeRate is immutable
    uint256 constant public exchangeRate = 10;  
    
    // vestingDuration unit is month
    uint256 private vestingDuration;
    
    /**
     * vestings contain hash of events associated with an address
     * @address Address of owner of events
     * @uint256 timestamp of event
     * @byte32 hash of event
     */
    mapping(address => mapping(uint256 => bytes32)) vestings;
    
    /**
     * Vested event is broadcasted when user vest ACT tokens for ACTION tokens.
     * To exchange back ACTION to ACT user have to send vestId,total,balance,hash
     * and amount of ACTION tokens want to exchagne to releaseACT() function
     */
    event Vested(address indexed vester,uint256 indexed vestId,uint256 total,uint256 balance,bytes32 hash); 
    
    event OwnershipTransfer(address indexed oldOnwer, address indexed newOwner);
  
    function Exchange(address _owner, address _actTokens, address _actionToken, uint256 _duration){
        require(_owner != 0x00);
        require(_owner != _actTokens);
        require(_owner != _actionToken);
        require(_actTokens != 0x00);
        require(_actionToken != 0x00);
        require(_duration > 1);
        
        owner = _owner;
        actToken = ACTToken(_actTokens);
        actionToken = ACTION(_actionToken);
        vestingDuration = _duration;
    }
    
    function getOwner() constant external returns(address){
        return owner;
    }
    
    function actContract() constant external returns(address){
        return actToken;
    } 
    
    function actionContract() constant external returns(address){
        return actionToken;
    } 
    
    function vestPeriod() constant external returns(uint256){
        return vestingDuration;
    }
     
    function transferOwnership(address _newOwner) external onlyOwner returns(bool){
        require(_newOwner != 0x00);
        OwnershipTransfer(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    
    function updateActAddress(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        actToken = ACTToken(_newAddress);
        return actToken.isContract();
    }
    
    function updateActionAddress(address _newAddress) external onlyOwner returns(bool){
        require(_newAddress != 0x00);
        actionToken = ACTION(_newAddress);
        return actionToken.isContract();
    }
    
    function updateVestDuration(uint256 _value) external onlyOwner returns(bool){
        require(_value > 1);
        vestingDuration = _value;
        return true;
    }
    
    function verifyVesting(uint256 _id) constant external returns(bytes32){
        require(_id != 0);
        return vestings[msg.sender][_id];
    }
    
    
    function vestACT(uint256 _actTokens) external returns(bool) {
        require(_actTokens > 0);
        require(actToken.isContract());
        require(actionToken.isContract());
        require(actToken.balanceOf(msg.sender) >= _actTokens);
        
        uint256 actions = _actTokens.mul(exchangeRate);
        
        // Subtract ACT tokens from sender account
        if(!actToken.withdraw(msg.sender,_actTokens)){
           revert(); 
        }
        
        // Add ACTION tokens to sender account
        if(!actionToken.deposit(msg.sender,actions)){
            revert();
        }
        
        uint256 id = now;
        bytes32 hash = sha3(msg.sender,id,actions,actions);
        vestings[msg.sender][id] = hash;
        Vested(msg.sender,id,actions,actions,hash);
        return true;
    }
    
    
    function releaseACT(uint256 _id,uint256 _total,uint256 balance,bytes32 _hash,uint256 release) external returns(bool){
        require(_id > 0);
        require(_total > 0);
        require(balance > 0);
        require(release > 0);
        require(actionToken.isContract());
        require(actionToken.balanceOf(msg.sender) >= balance);
        require(vestings[msg.sender][_id] == _hash);
        require(sha3(msg.sender,_id,_total,balance) == _hash);
        require(balance >= release);
        
        uint256 allowed = allowance(_id,_total,balance);
        
        require(allowed >= release);
        
        // Calculate hash with remaining balance
        bytes32 hash = sha3(msg.sender,_id,_total,balance.sub(release));
        
        // update hash
        vestings[msg.sender][_id] = hash;
        
        // Subtract ACTION tokens to sender account
        if(!actionToken.withdraw(msg.sender,release)){
            revert();
        }
        
        // Add ACT tokens to sender account
        if(!actToken.deposit(msg.sender,release/exchangeRate)){
            revert();
        }
        
        Vested(msg.sender,_id,_total,balance.sub(release),hash);
        return true;
    }
    
    function allowance(uint256 _id,uint256 _total,uint256 _balance) internal returns (uint256){
        
        if (now > _id + (vestingDuration * 30 days)){
             return _balance;
        }
        
        // There can be miner difference in actual and calculated age
        // becuase of no floating type
        uint256 age = now.sub(_id)/30 days;
        return _total.div(vestingDuration) * age;
    }
    
    // interface function
    function isContract() constant external returns(bool){
        return true;
    }
 
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
       require(msg.sender == owner);
        _;
    }

}
