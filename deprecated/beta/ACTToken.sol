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

contract ACTToken  {
    
    using SafeMath for uint256;
    
    address private owner;
    
    string private tokenname = "ACT Token";
    string private tokenSymbol = "ACT";
    uint256 private tokenDecimals = 18;
    uint256 private supply;
    
    string private contactInformation;
    
    uint256 private vested = 0;
    
    address private exchangeContract = 0x00;
    
    mapping(address => uint256) balances;
    
    mapping (address => mapping (address => uint256)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ExchangeAddrUpdate(address indexed oldAddress, address indexed newAddress);
    event OwnershipTransfer(address indexed oldOnwer, address indexed newOwner);

    function ACTToken(address _owner,uint256 _totalSupply){
        // TODO: parameter validating conditions
        owner = _owner;
        supply = _totalSupply * 10 ** tokenDecimals;
        balances[owner] = supply;
    }


    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(allowed[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function balanceOf(address _owner) constant returns (uint256) {
        return balances[_owner];
    }
  
    function getOwner() constant external returns(address){ return owner; }
    function name() constant external returns (string){ return tokenname; }
    function symbol() constant external returns (string){ return tokenSymbol; }
    function decimals() constant external returns (uint256){ return tokenDecimals; }
    function totalSupply() constant external returns(uint256){ return supply; }
    function contact() constant external returns(string){ return contactInformation; }
    function totalVested() constant  external returns(uint256){ return vested; }
    function exchange() constant external returns (address){ return exchangeContract; }
  
    function updateExchangeAddress(address _newAddress) external onlyOwner returns (bool){
        require(_newAddress != 0x00);
        // Event may be broadcasted even in case of failure
        ExchangeAddrUpdate(exchangeContract,_newAddress); 
        exchangeContract = _newAddress;
        return Exchange(exchangeContract).isContract();
    }
   
    function withdrawEth(address _to) onlyOwner {
        _to.transfer(this.balance);
    }
    
    function setContactInformation(string _info) onlyOwner returns (bool){
        contactInformation = _info;
        return true;
    }
    
    function transferOwnership(address _newOwner) external onlyOwner returns(bool){
        // Todo: validate params
        if(!transfer(_newOwner,balances[owner])){
            revert();
        }
        OwnershipTransfer(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    
    function deposit(address _to,uint256 _value) external onlyExchnage returns(bool){
        require(_to != 0x00);
        require(_value != 0);
        balances[_to] = balances[_to].add(_value);
        vested = vested.sub(_value);
        return true;
    }
    
    function withdraw(address _from,uint256 _value) external onlyExchnage returns(bool){
        require(_from != 0x00);
        require(_value != 0);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        vested = vested.add(_value);
        return true;
    }
    
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

    modifier onlyExchnage() {
        require(msg.sender == exchangeContract);
        _;
    }
}