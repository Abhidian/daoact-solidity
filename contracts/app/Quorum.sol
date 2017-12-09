pragma solidity ^0.4.18;

import '../misc/SafeMath.sol';
import '../misc/Ownable.sol';

contract Pool { function requestFunds() external returns(bool); }

contract Quorum is Ownable {
    
    using SafeMath for *;
    
    function Quorum() public {
        owner = msg.sender;
    }

    function checkCitizenQuorum(uint _upVotes, uint _downVotes) pure external returns(bool, uint) {
        var allVotes = _upVotes.add(_downVotes);
        var citizensQuorum = uint(_upVotes).mul(uint(100)).div(uint(allVotes));
        if (citizensQuorum >= 60) {

        } else {

        }
    }

    function checkQuratorsQuorum(uint _upTicks, uint _downTicks) pure external returns(bool) {
        var allTicks = _upTicks.add(_downTicks);
        var curatorsQuorum = uint(_upTicks).mul(uint(100)).div(uint(allTicks));
        if (curatorsQuorum >= 70) {
            return true;
        } else {
            return false;
        }
    }
}