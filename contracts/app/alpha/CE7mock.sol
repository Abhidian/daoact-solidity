pragma solidity ^0.4.18;

contract CE7mock {

    mapping (address => uint) balances;

    function setBalance(address _curator, uint _balance) public {
        balances[_curator] = _balance;
    }

    function getBalance(address _curator) public view returns (uint) {
        return balances[_curator];
    }

}