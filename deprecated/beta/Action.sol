pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Exchange{
    function isContract() constant returns (bool);
}


contract ACTION{
    using SafeMath for uint256;
    address private owner;
    
    string private name = "ACTION Token";
    string private tokenSymbol = "ACTION";
    uint256 private tokenDecimals = 18;
    
    string public contactInformation;
    
    address private exchangeContract;
    
    event ExchangeAddrUpdate(address indexed oldAddress, address indexed newAddress);
    event OwnershipTransfer(address indexed oldOnwer, address indexed newOwner);
    
    mapping(address => uint256) private balances; // Contains action token balance of user
    
    function ACTION(address _owner){
      // TODO: parameter validating conditions
      owner = _owner;
    }
    
    function balanceOf(address _owner) constant returns (uint256) {
    return balances[_owner];
    }
    
    function getOwner() constant external returns(address){
        return owner;
    }
    
    function tokenname() constant external returns (string){ return name; }
    function symbol() constant external returns (string){ return tokenSymbol; }
    function decimals() constant external returns (uint256){ return tokenDecimals; }
    
    function exchnage() constant external returns (address){
        return exchangeContract;
    }
    
    function updateExchangeAddress(address _newAddress) external onlyOwner returns (bool){
        require(_newAddress != 0x00);
        // Event may be broadcasted even in case of failure
        ExchangeAddrUpdate(exchangeContract,_newAddress); 
        exchangeContract = _newAddress;
        return Exchange(exchangeContract).isContract();
    }
    
    /**
     * @dev Allows the owner to set a string with their contact information.
     * @param info The contact information to attach to the contract.
     */
    function setContactInformation(string info) onlyOwner{
         contactInformation = info;
    }
    
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) onlyOwner {
        require(_newOwner != address(0));
        OwnershipTransfer(owner, _newOwner);   
        owner = _newOwner;
    }
    
    
    function deposit(address _to,uint256 _value) external onlyExchnage returns(bool){
        require(_to != 0x00);
        require(_value != 0);
        balances[_to] = balances[_to].add(_value);
        return true;
    }
    
    function withdraw(address _from,uint256 _value) external onlyExchnage returns(bool){
        require(_from != 0x00);
        require(_value != 0);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        return true;
    }
    
    function () payable {
        revert();
    }
    
    function isContract() external returns(bool){
        return true;
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyExchnage() {
        require(msg.sender == exchangeContract);
        _;
}
}

