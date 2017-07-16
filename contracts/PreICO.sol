pragma solidity ^0.4.13;

import "SafeMath.sol";

/**
 * PreICO is designed to hold funds of pre ico. Account is controlled by four administratos. To trigger a payout
 * three out of four administrators will must agree on same amount of ethers to be transferred. During the signing
 * process if one administrator sends different targetted address or amount of ethers, process will abort and they
 * need to start again.
 * Administrator can be replaced but three out of four must agree upon replacement of fourth administrator. Three
 * admins will send address of fourth administrator along with address of new one administrator. If a single one
 * sends different address the updating process will abort and they need to start again. 
 */

contract PreICO{
  
  using SafeMath for uint256;
  
  // Maintain state funds transfer signing process
  struct Transaction{
    address[3] signer;
    uint confirmations;
    uint256 eth;
  }
  
  // count and record signers with ethers they agree to transfer
  Transaction private pending;
    
  // the number of administrator that must confirm the same operation before it is run.
  uint256 constant public required = 3;

  mapping(address => bool) private administrators;
 
  // Funds has arrived into the contract (record how much).
  event Deposit(address _from, uint256 value);
  
  // Funds transfer to other contract
  event Transfer(address fristSigner, address secondSigner, address thirdSigner, address to,uint256 eth);
  
  // Administrator successfully signs a transaction
  event Confirmed(string action,address signer, uint256 remaining);
  
  // Administrator voilated consensus
  event Voilation(string action, address sender); 
  
  // Administrator key updated (administrator replaced)
  event KeyReplaced(address oldKey,address newKey);
  
  
  function PreICO(address[4] admins){
    administrators[admins[0]] = true;
    administrators[admins[1]] = true;
    administrators[admins[2]] = true;
    administrators[admins[3]] = true;

  }
  
  /**
   * @dev  To trigger payout three out of four administrators call this
   * function, funds will be transferred right after verification of
   * third signer call.
   * @param _to The address of recipient
   * @param ethers Amount of ethers to be transferred
   */
  function transfer(address _to, uint256 ethers) external onlyAdmin {
    
    // input validations
    require( _to != 0x00 );
    require( ethers > 0 );
    require( ethers >= this.balance);
    
    // verifications remaining
    uint256 remaining;
    
    // Start of signing process, first signer will finalize inputs for remaining two
    if(pending.confirmations == 0){
        
        pending.signer[pending.confirmations] = msg.sender;
        pending.eth = ethers;
        pending.confirmations = pending.confirmations.add(1);
        remaining = required.sub(pending.confirmations);
        Confirmed("Fund Transfer",msg.sender,remaining);
        return;
    
    }
    
    // Compare amount of ethers with previous confirmtaion
    if( pending.eth != ethers){
        Voilation("Funds Transfer",msg.sender);
        delete pending;  // abort signing process
        return;
    }
    
    // make sure admin is not trying to spam
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
    
    // If three confirmation are done, trigger payout
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
  function isAdministrator(address _addr) public constant returns (bool) {
    return administrators[_addr];
  }

  
  // Maintian state of administrator key update process
  struct KeyUpdate{
    address[3] signer;
    uint confirmations;
    address oldAddress;
    address newAddress;
  }
  
  KeyUpdate private updating;
  
  /**
   * @dev Three admnistrator can replace key of fourth administrator. 
   * @param _oldAddress Address of adminisrator needs to be replaced
   * @param _newAddress Address of new administrator
   */
  function updateAdministratorKey(address _oldAddress, address _newAddress) external onlyAdmin {
    
    // input verifications
    require(isAdministrator(_oldAddress));
    require( _newAddress != 0x00 );
    require(!isAdministrator(_newAddress));
    require( msg.sender != _oldAddress );
    
    // count confirmation 
    uint256 remaining;
    
    // start of updating process, first signer will finalize address to be replaced
    // and new address to be registered, remaining two must confirm
    if( updating.confirmations == 0){
        
        updating.signer[updating.confirmations] = msg.sender;
        updating.oldAddress = _oldAddress;
        updating.newAddress = _newAddress;
        updating.confirmations = updating.confirmations.add(1);
        remaining = required.sub(updating.confirmations);
        Confirmed("Administrator key Update",msg.sender,remaining);
        return;
        
    }
    
    // voilated consensus
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
    
    // make sure admin is not trying to spam
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
    
    // if three confirmation are done, register new admin and remove old one
    if( updating.confirmations == 3 ){
        KeyReplaced(_oldAddress, _newAddress);
        delete updating;
        delete administrators[_oldAddress];
        administrators[_newAddress] = true;
        return;
    }
  }

  /**
   * @dev Reset values of updating (KeyUpdate object)
   */
  function abortUpdate() external onlyAdmin{
      delete updating;
  }
  
  /**
   * @dev modifier allow only if function is called by administrator
   */
  modifier onlyAdmin(){
      if( !administrators[msg.sender] ){
          revert();
      }
      _;
  }
  
}