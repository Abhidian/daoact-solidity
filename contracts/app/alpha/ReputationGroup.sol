pragma solidity ^0.4.18;

import "../../misc/SafeMath.sol";
import '../../misc/Ownable.sol';

contract Curator { function getFullReputation () view public returns (uint);}

contract ReputationGroup is Ownable {
    
    using SafeMath for uint;
       
    uint fullReputation; 
    uint groupA;
    uint groupB;
    uint groupC;
    uint groupD;
    uint reputationRate;
    Curator curator;

    function ReputationGroup() public {
        owner = msg.sender;
    }

    function setCuratorContractAddress(address _address) public {
        require(_address != address(0));
        curator = Curator(_address);
    }

    function getFullReputation() public returns (uint) {
        fullReputation = curator.getFullReputation();
        return fullReputation;
    }
    
    //groupA = 1, bottom 5% 
    //groupB = 2
    //groupC = 3
    //groupD = 4
    
    //will be triggered by foundation by clicking button to calculate groups rate accordig to the reputation
    function calculateRates() public {
        fullReputation = curator.getFullReputation();
        groupA = fullReputation.mul(5).div(100);
        groupB = fullReputation.mul(35).div(100);
        groupC = fullReputation.mul(80).div(100);
    }
    
    function getGroupRate(uint _rep) public constant returns (uint) {
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