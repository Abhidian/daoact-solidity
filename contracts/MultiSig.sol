pragma solidity ^0.4.13;

import "SafeMath.sol";
contract MultiSig{
  
  using SafeMath for uint256;
  
  struct Transaction{
    address[3] signer;
    uint confirmations;
    uint256 eth;
  }
  
  Transaction private pending;
    
  // the number of administrator that must confirm the same operation before it is run.
  uint256 constant public required = 3;

  mapping(address => bool) private administrators;
 
  // Funds has arrived into the contract (record how much).
  event Deposit(address _from, uint256 value);
  
  // Funds transfer to other contract
  event Transfer(address fristSigner, address secondSigner, address thirdSigner, address to,uint256 eth);
  
  // Confirmation done for a transaction.
  event Confirmed(string action,address signer, uint256 remaining);
  
  // 
  event Voilation(string action, address sender); 
  
  // Administrator key updated
  event KeyReplaced(address oldKey,address newKey);
  
  function MultiSig(){
      
    administrators[0xca35b7d915458ef540ade6068dfe2f44e8fa733c] = true;
    administrators[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c] = true;
    administrators[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db] = true;
    administrators[0x583031d1113ad414f02576bd6afabfb302140225] = true;

  }
  

  function transfer(address _to, uint256 ethers) external onlyAdmin {
    
    require( _to != 0x00 );
    require( ethers > 0 );
    require( ethers >= this.balance);
    
    uint256 remaining;
    
    if(pending.confirmations == 0){
        
        pending.signer[pending.confirmations] = msg.sender;
        pending.eth = ethers;
        pending.confirmations = pending.confirmations.add(1);
        remaining = required.sub(pending.confirmations);
        Confirmed("Fund Transfer",msg.sender,remaining);
        return;
    
    }
        
    if( pending.eth != ethers){
        Voilation("Funds Transfer",msg.sender);
        delete pending;
        return;
    }
    
    if(msg.sender == pending.signer[0]){
        Voilation("Funds Transfer",msg.sender);
        delete pending;
        return;
    }
    
    if( remaining == 1){
        if(msg.sender != pending.signer[1]){
            Voilation("Funds Transfer",msg.sender);
            delete pending;
            return;
        }
    }
  
    pending.signer[pending.confirmations] = msg.sender;
    pending.confirmations = pending.confirmations.add(1);
    Confirmed("Fund Transfer",msg.sender,remaining);
    
    if (pending.confirmations == 3){
        if(_to.send(ethers)){
            Transfer(pending.signer[0],pending.signer[1], pending.signer[2], _to,ethers);
        }
        delete pending;
    }
    
  }
  
  /**
   * @dev Reset values of pending (Transaction object)
   */
  function abortTransaction() external onlyAdmin{
       delete pending;
  }
  
  
  /** 
   * @dev Fallback function, receives value and emits a deposit event. 
   */
  function() payable {
    // just being sent some cash?
    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }
  
  /**
   * @dev Checks if given address is an administrator.
   * @param _addr address The address which you want to check.
   * @return True if the address is an administrator and fase otherwise.
   */
  function isAdministrator(address _addr) constant returns (bool) {
    return administrators[_addr];
  }

  
  struct KeyUpdate{
    address[3] signer;
    uint confirmations;
    address oldAddress;
    address newAddress;
  }
  
  KeyUpdate private updating;
  
  /**
   * @dev
   * @param 
   */
  function updateAdministratorKey(address _oldAddress, address _newAddress) external onlyAdmin {
    require(isAdministrator(msg.sender));
    require(isAdministrator(_oldAddress));
    require( _newAddress != 0x00 );
    require(!isAdministrator(_newAddress));
    require( msg.sender != _oldAddress );
    
    uint256 remaining;
    
    if( updating.confirmations == 0){
        
        updating.signer[updating.confirmations] = msg.sender;
        updating.oldAddress = _oldAddress;
        updating.newAddress = _newAddress;
        updating.confirmations = updating.confirmations.add(1);
        remaining = required.sub(updating.confirmations);
        Confirmed("Administrator key Update",msg.sender,remaining);
        return;
        
    }
    
    if(updating.oldAddress != _oldAddress){
        Voilation("Administrator key Update",msg.sender);
        delete updating;
        return;
    }
    
    if(updating.newAddress != _newAddress){
        Voilation("Administrator key Update",msg.sender);
        delete updating;
        return;
    }
    
    if(msg.sender == updating.signer[0]){
        Voilation("Funds Transfer",msg.sender);
        delete updating;
        return;
    }
    
    if( remaining == 1){
        if(msg.sender != updating.signer[1]){
            Voilation("Funds Transfer",msg.sender);
            delete updating;
            return;
        }
    }
    
    updating.signer[updating.confirmations] = msg.sender;
    updating.confirmations = updating.confirmations.add(1);
    Confirmed("Administrator key Update",msg.sender,remaining);
    
    if( updating.confirmations == 3 ){
        KeyReplaced(_oldAddress, _newAddress);
        delete updating;
        delete administrators[address(_oldAddress)];
        administrators[_newAddress] = true;
        return;
    }
  }

  function abortUpdate() external onlyAdmin{
      delete updating;
  }
    

  modifier onlyAdmin(){
      if( !administrators[msg.sender] ){
          revert();
      }
      _;
  }
  
}
