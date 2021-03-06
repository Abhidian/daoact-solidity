pragma solidity ^0.4.18;

import '../../misc/Ownable.sol';

contract CE7mock is Ownable {

    mapping (address => uint) balances;

    function CE7mock() public {
        owner = msg.sender;
    }

    // set balance for curator by address
    function setBalance(address _curator, uint _balance) public {
        balances[_curator] = _balance;
    }

    // check curator's balance
    function getBalance(address _curator) public view returns (uint) {
        return balances[_curator];
    }

}