pragma solidity ^0.4.18;

import "../../misc/SafeMath.sol";
import '../../misc/Ownable.sol';

contract Ce7 { function getBalance(address _curator) public view returns (uint);}
contract ReputationGroupDividing { function getGroupRate (uint _rep) public returns (uint);}
contract Pool {
    function getTransit() external returns(uint, uint);
}

contract Curator {

    using SafeMath for *;

    Ce7 ce7Token;
    ReputationGroupDividing repGroup;
    Pool pool;

    //accumulating all reputation that have curators of the platform to calculate reputation groups for curators
    //and limits. Group id dividing through button and only foundation is able to click it
    uint fullPlatformReputation;
    uint fullEffortA;  //group A according to the reputation
    uint fullEffortB;  //group C according to the reputation
    uint fullEffortC;  //group A according to the reputation

    struct CuratorInstance {
    bool exist;
    uint reputation;
    uint rewarding;
    uint reputationGroup;
    uint limitLike;
    uint limitFlag;
    uint limitComment;
    uint limitLikeComment;
    uint timestampLimits;
    uint effortA;  //these effort groups is taken according to the number of tokens held every time when effort is calculating
    uint effortB;
    uint effortC;
    }

    // rate of reputation, depends on was proposal activated or not, reached quorum or not and curator's reaction
    uint activationQuorumUptick; //if proposal was activated, reached the quorum and curator uptick this proposal
    uint noActivationNoQuorumDowntick; //if proposal was not activated, not reached the quorum and curator downtick this proposal
    uint activationNoQuorumDowntick; //if proposal was activated, not reached the quorum and curator downtick this proposal
    uint activationNoQuorumUptick; //if proposal was activated, not reached the quorum and curator uptick this proposal
    uint noActivationNoQuorumUptick; //if proposal was not activated,not reached the quorum and curator uptick this proposal
    uint activationQuorumDowntick; //if proposal was activated, reached the quorum and curator downtick this proposal

    mapping (address => CuratorInstance) curators;
    mapping(address => uint) balances;

    address public proposalController;  //ProposalController contract address

    function Curator(address _ce7Token, address _repGroup) public {
        require(_ce7Token != address(0));
        require(_repGroup != address(0));
        ce7Token = Ce7(_ce7Token);
        repGroup = ReputationGroupDividing(_repGroup);


        // sum of reputation from all curators on the fullPlatformReputation
        fullPlatformReputation = 0;

        //reputation rates
        activationQuorumUptick = 160;
        noActivationNoQuorumDowntick = 2;
        activationNoQuorumDowntick = 7;
        activationNoQuorumUptick = 5;
        noActivationNoQuorumUptick = 2;
        activationQuorumDowntick = 5;
    }

    function setAddressPool (address _pool) public {
        pool = Pool(_pool);
    }

    function setProposalControllerAddress (address _proposalController) public {
        require(_proposalController != address(0));
        proposalController = _proposalController;
    }

    //only ProposalController contract can call some functions
    modifier onlyProposalControler() {
        require(msg.sender == proposalController);
        _;
    }

    //create curator with 0 reputation, 0 rewarding and 1 reputation group
    function createCurator() public {
        var ce7Balance = ce7Token.getBalance(msg.sender);
        if (ce7Balance < 1000 ) {
            curators[msg.sender] = CuratorInstance(true, 0, 0, 1, 30, 0, 0, 5, now, 0, 0, 0);
        }
        if (ce7Balance >= 1000 && ce7Balance < 2000) {
            curators[msg.sender] = CuratorInstance(true, 0, 0, 1, 20, 1, 1, 10, now, 0, 0, 0);
        }
        if (ce7Balance >= 2000 && ce7Balance < 10000) {
            curators[msg.sender] = CuratorInstance(true, 0, 0, 1, 20, 3, 4, 10, now, 0, 0, 0);
        }
        if (ce7Balance >= 10000 ) {
            curators[msg.sender] = CuratorInstance(true, 0, 0, 1, 30, 5, 5, 10000, now, 0, 0, 0);
        }
    }

    //getter for Pool contract to extract curator's rewarding for payment (curator is going to click the button and get rewarding every 30 days)
    function getCuratorRewarding() public view returns (uint) {
        return curators[msg.sender].rewarding;
    }

    //getter for ReputationGroup contract to divide curators for different reputation group
    function getFullReputation() public view returns (uint) {
        return fullPlatformReputation;
    }

    //get curator's reputation from proposal contract in order to store data about reputation of those curators who uptick comment
    function getReputation(address _curator) external view returns (uint) {
        return curators[_curator].reputation;
    }

    //calculate curator's effort
    function calcEffort(uint _effort, address _curator) external onlyProposalControler {
        require(curators[_curator].exist == true);
        var (poolRewarding, timestamp)  = pool.getTransit();
        var ce7Balance = ce7Token.getBalance(_curator);

        if (now <= timestamp.add(30 days)) {
            accumulateEffort(ce7Balance, _curator, _effort);
        }
        if (now >= timestamp.add(30 days) && now <= timestamp.add(60 days)) {
            calculateRewarding(_curator, poolRewarding);
            accumulateEffort(ce7Balance, _curator, _effort);
        }
        if (now >= timestamp.add(60 days)) {
            curators[_curator].rewarding = 0;
            fullEffortA = 0;
            fullEffortB = 0;
            fullEffortC = 0;
            accumulateEffort(ce7Balance, _curator, _effort);
        }
    }

    function accumulateEffort(uint ce7Balance, address _curator, uint _effort) internal {
        if (ce7Balance >= 5 && ce7Balance <= 1999) {
            curators[_curator].effortC = curators[_curator].effortC.add(_effort);
            fullEffortC = fullEffortC.add(curators[_curator].effortC);
        }
        if (ce7Balance >= 2000 && ce7Balance <= 19999) {
            curators[_curator].effortB = curators[_curator].effortC.add(_effort);
            fullEffortB = fullEffortB.add(curators[_curator].effortB);
        }
        if (ce7Balance >= 20000) {
            curators[_curator].effortA = curators[_curator].effortC.add(_effort);
            fullEffortA = fullEffortA.add(curators[_curator].effortA);
        }
    }

    function calculateRewarding(address _curator, uint poolRewarding) internal {
        require(curators[_curator].exist == true);
        uint oneEffortA;
        uint oneEffortB;
        uint oneEffortC;
        oneEffortA = (poolRewarding.mul(60).div(100)).div(fullEffortA);
        oneEffortB = (poolRewarding.mul(30).div(100)).div(fullEffortB);
        oneEffortC = (poolRewarding.mul(10).div(100)).div(fullEffortC);
        fullEffortA = 0;
        fullEffortB = 0;
        fullEffortC = 0;
        curators[_curator].rewarding = curators[_curator].effortA*oneEffortA + curators[_curator].effortB * oneEffortB + curators[_curator].effortC * oneEffortC;
    }

    //poolController call these two functions (calcPos, calcNeg - positive and negative reputation)
    //one by one to calculate reputation and rates of group
    //according to curator's reputation. Also here we calculate 'fullPlatformReputation'
    //groupA = 1
    //groupB = 2
    //groupC = 3
    //groupD = 4
    function calcPos(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public onlyProposalControler returns (uint) {
        require(curators[_curator].exist == true);
        if (_activation == true && _quorum == true && _uptick == true) {
            curators[_curator].reputation += activationQuorumUptick;
            fullPlatformReputation += activationQuorumUptick;
        }
        if (_activation == false && _quorum == false && (_downtick == true || _flag == true)) {
            curators[_curator].reputation = curators[_curator].reputation.add(noActivationNoQuorumDowntick);
            fullPlatformReputation = fullPlatformReputation.add(activationQuorumUptick);
        }
        if (_activation == true && _quorum == false && (_downtick == true || _flag == true)) {
            curators[_curator].reputation = curators[_curator].reputation.add(activationNoQuorumDowntick);
            fullPlatformReputation = fullPlatformReputation.add(activationQuorumUptick);
        }
        curators[_curator].reputationGroup = repGroup.getGroupRate(curators[_curator].reputation);
    }

    function calcNeg(address _curator, bool _activation, bool _quorum, bool _uptick, bool _downtick, bool _flag) public onlyProposalControler returns (uint) {
        require(curators[_curator].exist == true);
        if (_activation == false && _quorum == false && _uptick == true) {
            if (curators[_curator].reputation <= noActivationNoQuorumUptick) {
                fullPlatformReputation -= curators[_curator].reputation;
                curators[_curator].reputation = 0;
            } else {
                curators[_curator].reputation -= noActivationNoQuorumUptick;
                fullPlatformReputation -= activationQuorumDowntick;
            }
        }
        if (_activation == true && _quorum == false && _uptick == true) {
            if (curators[_curator].reputation <= activationNoQuorumUptick) {
                fullPlatformReputation -= curators[_curator].reputation;
                curators[_curator].reputation = 0;
            } else {
                curators[msg.sender].reputation -= activationNoQuorumUptick;
                fullPlatformReputation -= activationQuorumDowntick;
            }
        }
        if (_activation == true && _quorum == true && (_downtick == true || _flag == true)) {
            if (curators[_curator].reputation <= activationQuorumDowntick) {
                fullPlatformReputation -= curators[_curator].reputation;
                curators[_curator].reputation = 0;
            } else {
                curators[_curator].reputation -= activationQuorumDowntick;
                fullPlatformReputation -= activationQuorumDowntick;
            }
        }
        curators[_curator].reputationGroup = repGroup.getGroupRate(curators[_curator].reputation);
    }

    //getter to get reputation group for exact curator
    //function getCuratorGroup(address _curator) public view returns (uint) {
    //   return curators[_curator].reputationGroup;
    //}

    //proposal contract checks curator's limits for 24 hours once he made some action with proposal
    //1 == uptick proposal, 2 == downtick proposal, 3 == flag proposal, 4 == comment, 5 == commentLike
    function limits(address _curator, uint8 _action) external onlyProposalControler returns (bool) {
        if (now > (curators[_curator].timestampLimits + 24 hours)) {
            if (_action == 1 || _action == 2) {
                if (curators[_curator].limitLike > 0) {
                    curators[_curator].limitLike - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 3) {
                if (curators[_curator].limitFlag > 0) {
                    curators[_curator].limitLike - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 4) {
                if (curators[_curator].limitComment > 0) {
                    curators[_curator].limitComment - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 5) {
                if (curators[_curator].limitLikeComment > 0) {
                    curators[_curator].limitLikeComment - 1;
                    return true;
                } else {
                    return false;
                }
            }
        }
        if (now < (curators[_curator].timestampLimits + 24 hours)) {
            curators[_curator].timestampLimits = now;  //if timestamp is more then + 24 hours we set timestamp 'now'
            setLimits(_curator);     //and call function to refresh limits
            if (_action == 1 || _action == 2) { //then we need to subtract of limits exact action
                if (curators[_curator].limitLike > 0) {
                    curators[_curator].limitLike - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 3) {
                if (curators[_curator].limitFlag > 0) {
                    curators[_curator].limitLike - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 4) {
                if (curators[_curator].limitComment > 0) {
                    curators[_curator].limitComment - 1;
                    return true;
                } else {
                    return false;
                }
            }
            if (_action == 5) {
                if (curators[_curator].limitLikeComment > 0) {
                    curators[_curator].limitLikeComment - 1;
                    return true;
                } else {
                    return false;
                }
            }
        }
    }

    //groupA = 1
    //groupB = 2
    //groupC = 3
    //groupD = 4
    //update curator's limits if 24 hours is passed
    function setLimits(address _curator) internal {
        require(curators[_curator].exist == true);
        var ce7Balance = ce7Token.getBalance(_curator);
        if (curators[_curator].reputationGroup == 1) {
            curators[_curator].limitLike = 30;
            curators[_curator].limitFlag = 0;
            curators[_curator].limitComment = 0;
            curators[_curator].limitLikeComment = 0;
            curators[_curator].timestampLimits = now;
        }
        if (curators[_curator].reputationGroup == 2 || (ce7Balance >= 1000 && ce7Balance < 2000)) {
            curators[_curator].limitLike = 20;
            curators[_curator].limitFlag = 1;
            curators[_curator].limitComment = 1;
            curators[_curator].limitLikeComment = 10;
            curators[_curator].timestampLimits = now;
        }
        if (curators[_curator].reputationGroup == 3 || (ce7Balance >= 2000 && ce7Balance < 10000)) {
            curators[_curator].limitLike = 20;
            curators[_curator].limitFlag = 3;
            curators[_curator].limitComment = 4;
            curators[_curator].limitLikeComment = 10;
            curators[_curator].timestampLimits = now;
        }
        if (curators[_curator].reputationGroup == 4 || ce7Balance >= 10000) {
            curators[_curator].limitLike = 30;
            curators[_curator].limitFlag = 5;
            curators[_curator].limitComment = 5;
            curators[_curator].limitLikeComment = 10000;
            curators[_curator].timestampLimits = now;
        }
    }
    // function getLimits (address _curator) public returns (uint,uint,uint,uint) {
    //     require(curators[_curator].exist == true);
    //     return ( 
    //     curators[_curator].limitLike,
    //     curators[_curator].limitFlag,
    //     curators[_curator].limitComment,
    //     curators[_curator].limitLikeComment
    //     );
    // }
}