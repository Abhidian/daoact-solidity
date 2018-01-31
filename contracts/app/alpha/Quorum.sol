pragma solidity ^0.4.18;

import '../../misc/SafeMath.sol';
import '../../misc/Ownable.sol';

contract Pool { function proposalFund(address _proposal, uint _value) external returns(uint); }

contract Quorum is Ownable {

    using SafeMath for *;

    Pool public poolContract;
    address public proposalContract;

    function Quorum() public {
        owner = msg.sender;
    }

    function setPoolAddress (address _poolContract) public onlyOwner {
        poolContract = Pool(_poolContract);
    }

    function setProposalContract(address _proposalContract) public onlyOwner {
        proposalContract = _proposalContract;
    }

    modifier onlyProposalContract() {
        require(msg.sender == proposalContract);
        _;
    }

    function checkCitizenQuorum(uint _upVotes, uint _downVotes, address _proposal, uint _value) external onlyProposalContract returns(bool, uint) {
        var allVotes = _upVotes.add(_downVotes);
        var citizensQuorum = uint(_upVotes).mul(uint(100)).div(uint(allVotes));
        if (citizensQuorum >= 60) {
            var result = poolContract.proposalFund(_proposal, _value);
            return (true, result);
        } else {
            return (false, 0);
        }
    }

    function checkCuratorsQuorum(uint _upTicks, uint _downTicks) external view onlyProposalContract returns(bool) {
        var allTicks = _upTicks.add(_downTicks);
        var curatorsQuorum = uint(_upTicks).mul(uint(100)).div(uint(allTicks));
        if (curatorsQuorum >= 70) {
            return true;
        } else {
            return false;
        }
    }
}