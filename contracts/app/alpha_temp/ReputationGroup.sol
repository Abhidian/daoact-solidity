pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}
contract Curator { function getFullReputation () view public returns (uint) ; }

contract ReputationGroupDividing {

    using SafeMath for uint;

    uint fullReputation;
    uint groupA;
    uint groupB;
    uint groupC;
    uint groupD;
    uint reputationRate;
    Curator curator;

    //set curator contract address
    function setCurator(address _cur)public {
        curator = Curator(_cur);
    }


    function getFullReputation () public view returns (uint) {
        fullReputation = curator.getFullReputation();
        return fullReputation;
    }

    //groupA = 1, bottom 5% form
    //groupB = 2
    //groupC = 3
    //groupD = 4

    //will be triggered by foundation by clicking button to calculate groups rate accordig to the reputation
    function calculateRates () public {
        fullReputation = curator.getFullReputation();
        groupA = (fullReputation.mul(5)).div(100);
        groupB = (fullReputation.mul(35)).div(100);
        groupC = (fullReputation.mul(80)).div(100);
    }

    function getGroupRate (uint _rep) public returns (uint) {
        if (_rep <= groupA) {
            return 1;
        } if (_rep > groupA && _rep <= groupB) {
        return 2;
    } if (_rep > groupB && _rep <= groupC) {
        return 3;
    } if (_rep > groupC) {
        return 4;
    }
        return reputationRate;
    }

    function returnA() public view returns (uint) {
        return groupA;
    }

}