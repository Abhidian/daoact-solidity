pragma solidity 0.4.17;

contract ReentrancyGuardAttack 
{
    function callSender(bytes4 data) public
    {
        if (!msg.sender.call(data)) 
            revert();
    }
}