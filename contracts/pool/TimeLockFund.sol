/**
 *  mtxset - https://github.com/mtxset
 *  Draglet GbmH
 */

pragma solidity 0.4.18;

import '../misc/SafeMath.sol';

contract TimeLockFund
{
    using SafeMath for *;

    // Time period for withdrawals
    uint public constant Period = 30 days;

    uint public ProposalFundsDate;
    uint public CuratorRewardDate;
    uint public FoundationRewardDate;
    
    function TimeLockFund() public
    {
        uint currentTime = now;
        
        ProposalFundsDate = currentTime.add(Period);
        CuratorRewardDate = currentTime.add(Period);
        FoundationRewardDate = currentTime.add(Period);
    }

    function PushProposalFundDate() internal
    { ProposalFundsDate = ProposalFundsDate.add(Period); }

    function PushCuratorRewardDate() internal
    { CuratorRewardDate = CuratorRewardDate.add(Period); }

    function PushFoundationRewardDate() internal
    { FoundationRewardDate = FoundationRewardDate.add(Period); }

    modifier CheckTimeForFundProposal
    { require(ProposalFundsDate < now); _; }

    modifier CheckTimeForCuratorReward
    { require(CuratorRewardDate < now); _; }

    modifier CheckTimeForFoundationReward
    { require(FoundationRewardDate < now); _; }

}