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
  event Confirmations(string action,address signer, bool success,uint256 required);
  
  // Administrator key updated
  event KeyReplaced(address oldKey,address newKey);
  
  function PreICO(address[4] admins){
    
    administrators[admins[0]] = true;
    administrators[admins[1]] = true;
    administrators[admins[2]] = true;
    administrators[admins[3]] = true;

  }
  

  function transfer(address _to, uint256 ethers){
    
    require(isAdministrator(msg.sender));
    require( _to != 0x00 );
    require( ethers > 0 );
    
    uint256 remaining = required.sub(pending.confirmations);
    
    if(pending.confirmations == 0){
        
        pending.signer[pending.confirmations] = address(msg.sender);
        pending.eth = ethers;
        pending.confirmations = pending.confirmations.add(1);
        Confirmations("Fund Transfer",msg.sender,remaining);
        return;
    
    }
        
    if( pending.eth != ethers){
        nullify();
        return;
    }
    
    pending.signer[pending.confirmations] = address(msg.sender);
    pending.confirmations = pending.confirmations.add(1);
    Confirmations("Fund Transfer",msg.sender,remaining);
    
    if (pending.confirmations == 3){
        if(_to.send(ethers)){
            Transfer(pending.signer[0],pending.signer[1], pending.signer[2], _to,ethers);
        }
        nullify();
    }
    
  }
  
  /**
   * @dev Reset values of pending (Transaction object)
   */
  function nullify() private{
       pending.confirmations = 0;
       delete(pending.signers);
       pending.eth  = 0;
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
    uint confirmations;
    address oldAddress;
    address newAddress;
  }
  
  KeyUpdate private updating;
  
  /**
   * @dev
   * @param 
   */
  function updateAdministratorKey(address _oldAddress, address _newAddress){
    require(isAdministrator(msg.sender));
    require(isAdministrator(_oldAddress));
    require( _newAddress != 0x00 );
    require(!isAdministrator(_newAddress));
    require( msg.sender != _oldAddress );
    
    if( updating.confirmations == 0){
        
        updating.oldAddress = _oldAddress;
        updating.newAddress = _newAddress;
        updating.confirmations = updating.confirmations.add(1);
        Confirmations("Fund Transfer",msg.sender,remaining);
        return;
    }
    
    if(updating.oldAddress != _oldAddress){
        updating = KeyUpdate(0,0x00,0x00);
        return;
    }
    
    if(updating.newAddress != _newAddress){
        updating = KeyUpdate(0,0x00,0x00);
        return;
    }
    
    updating.confirmations = updating.confirmations.add(1);
    
    if( updating.confirmations == 3 ){
        KeyReplaced(_oldAddress, _newAddress);
        updating = KeyUpdate(0,0x00,0x00);
        delete administrators[address(_oldAddress)];
        administrators[_newAddress] = true;
        
        return;
    }
  }
}
