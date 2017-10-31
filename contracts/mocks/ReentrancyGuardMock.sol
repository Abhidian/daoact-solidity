pragma solidity 0.4.17;

import "../misc/ReentrancyGuard.sol";
import "./ReentrancyGuardAttack.sol";

contract ReentrancyGuardMock is ReentrancyGuard
{
    uint256 public counter;

    function count() private
    { counter += 1;}

    function CountLocalRecursive(uint256 n) public
    nonReentrant
    {
        require(n > 0);

        count();
        CountLocalRecursive(n - 1);
    }

    function CountThisRecursive(uint256 n) public
    nonReentrant
    {
        bytes4 f = bytes4(keccak256("CountLocalRecursive(uint256"));

        require(n > 0);
        
        count();
        bool res = this.call(f, n-1);
        
        if (res != true) 
            revert();
    }

    function CountAndCall(ReentrancyGuardAttack attacker) public
    nonReentrant
    {
        count();

        bytes4 f = bytes4(keccak256("callback()"));

        attacker.callSender(f);
    }

    function callback() external
    nonReentrant
    { count(); }
}