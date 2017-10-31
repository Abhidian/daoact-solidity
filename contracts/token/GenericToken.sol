pragma solidity 0.4.17;

import '../misc/Ownable.sol';
import '../misc/SafeMath.sol';

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/// @title Migration Agent interface
contract MigrationAgent {

  uint256 public originalSupply;
  
  function migrateFrom(address from, uint256 value) external returns(bool);
  
  /** Interface marker */
  function isMigrationAgent() external constant returns (bool) {
    return true;
  }
}

contract GenericToken is StandardToken, Ownable, MigrationAgent
{
    string public name = "GenericToken";
    string public symbol = "GT";

    uint public decimals = 18; 
    uint private initialSupply = 10e9 * 1e18; // 10 Billions + 18 decimal places 100 Octilions

    function GenericToken() public
    {
        originalSupply = initialSupply;
    }
    
    function migrateFrom(address from, uint256 value) external
    returns (bool)
    {
        totalSupply = initialSupply;
        owner = msg.sender;
        balances[from] = value;

        return true;
    }
}