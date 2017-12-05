/**
 *  mtxset - https://github.com/mtxset
 *  Draglet GbmH
 */

pragma solidity 0.4.18;

import '../misc/SafeMath.sol';
import '../misc/Ownable.sol';
import './TimeLockFund.sol';

contract Pool is Ownable, TimeLockFund
{
    using SafeMath for *;

    enum Funds 
    {
        FundProposal,               // Funds for proposals
        RewardCurator,              // Funds for curators
        RewardFoundation            // Funds for foundation
    }

    address[3] public WithdrawalAddresses;
    uint256[3] public AmountOfFunds;

    address public QuorumAddress;
    address public CuratorAddress;

    // Fallback function
    function () payable public
    { FundDistribution(); } 

    // Constructor
    function Pool
    (
        address fundProposalAddr,
        address rewardCuratorAddr, 
        address rewardFoundationAddr,
        address quorumAddr,
        address curatorAddr
    ) public
    {
        require(fundProposalAddr != address(0));
        require(rewardCuratorAddr != address(0));
        require(rewardFoundationAddr != address(0));
        require(quorumAddr != address(0));
        require(curatorAddr != address(0));

        WithdrawalAddresses[uint(Funds.FundProposal)] = fundProposalAddr;
        WithdrawalAddresses[uint(Funds.RewardCurator)] = rewardCuratorAddr;
        WithdrawalAddresses[uint(Funds.RewardFoundation)] = rewardFoundationAddr;

        QuorumAddress = quorumAddr;
        CuratorAddress = curatorAddr;
    }

    // Direct Fund distribution functions - do we need it?

    function SendProposalFunds() payable external
    SendingEther
    {
        AmountOfFunds[uint(Funds.FundProposal)].add(msg.value);
        
        // Event
        ProposalFundReceived(msg.value);
    }

    function SendCuratorReward() payable external
    SendingEther
    {
        AmountOfFunds[uint(Funds.RewardCurator)].add(msg.value);

        // Event
        CuratorRewardReceived(msg.value);
    }

    function SendFoundationReward() payable external
    SendingEther
    {
        AmountOfFunds[uint(Funds.RewardFoundation)].add(msg.value);

        // Event
        FoundationRewardReceived(msg.value);
    }

    function FundDistribution() payable public
    SendingEther
    {
        uint sentAmount = msg.value;

        // Let's distribute funds
        uint valueForProposalFunds = sentAmount.div(5).mul(4);  // 80 % or 4/5

        uint valueForCuratorReward = sentAmount.div(20).mul(3); // 15 % or 3/20

        uint valueForFoundation    = sentAmount
                                            .sub(valueForCuratorReward) // - 80 %
                                            .sub(valueForProposalFunds);// - 15 % and we are left with 5 %

        AmountOfFunds[uint(Funds.FundProposal)].add(valueForProposalFunds);
        AmountOfFunds[uint(Funds.RewardCurator)].add(valueForCuratorReward);
        AmountOfFunds[uint(Funds.RewardFoundation)].add(valueForFoundation);

        // Check if no value lost
        require(msg.value == valueForProposalFunds
                                .add(valueForCuratorReward)
                                .add(valueForFoundation));

        // Event
        FundsReceived(
            msg.value, 
            valueForProposalFunds,
            valueForCuratorReward,
            valueForFoundation);
    }

    // -- Fund distribution functions
    
    // Withdrawal functions
    
    function Withdraw(Funds fundOption) internal
    returns (uint payment)
    {
        payment = AmountOfFunds[uint(fundOption)];
        
        require(payment != 0);
        require(this.balance >= payment);

        AmountOfFunds[uint(fundOption)] = 0;

        WithdrawalAddresses[uint(fundOption)].transfer(payment);

        return payment;
    }

    function WithdrawProposalFunds(uint weiRequested) public
    CheckSenderAddress(QuorumAddress)
    CheckTimeForFundProposal
    {
        Funds fundOption = Funds.FundProposal;

        uint payment = AmountOfFunds[uint(fundOption)];

        // calculate 10 percent if more set to 10 payout
        if (weiRequested > payment.div(10))
            payment = payment.div(10);
        else
            payment = weiRequested;
        
        require(payment != 0);
        require(this.balance >= payment);

        AmountOfFunds[uint(fundOption)] = 0;

        WithdrawalAddresses[uint(fundOption)].transfer(payment);

        PushCuratorRewardDate();
        
        // Event
        ProposalFundsWithdrawn(payment, ProposalFundsDate);
    }

    function WithdrawCuratorReward() public
    CheckSenderAddress(CuratorAddress) 
    CheckTimeForCuratorReward
    {
        uint weiAmount = Withdraw(Funds.RewardCurator);

        PushCuratorRewardDate();
        
        // Event
        CuratorRewardWithdrawn(weiAmount, CuratorRewardDate);
    }

    function WithdrawFoundationReward() public
    CheckSenderAddress(WithdrawalAddresses[uint(Funds.RewardFoundation)])
    CheckTimeForFoundationReward
    {
        uint weiAmount = Withdraw(Funds.RewardFoundation);

        PushFoundationRewardDate();

        // Event
        FoundationRewardWithdrawn(weiAmount, FoundationRewardDate);
    }
    
    // -- Withdrawal functions

    // Getters

    function GetFundProposalBalance() external view
    returns (uint)
    { return AmountOfFunds[uint(Funds.FundProposal)]; }

    function GetRewardCuratorBalance() external view
    returns (uint)
    { return AmountOfFunds[uint(Funds.RewardCurator)]; }

    function GetRewardFoundationBalance() external view
    returns (uint)
    { return AmountOfFunds[uint(Funds.RewardFoundation)]; }

    // --Getters

    // Modifiers

    // Checks if ether is being sent along

    modifier CheckSenderAddress(address addr)
    { require(msg.sender == addr); _; }

    modifier SendingEther()
    { require(msg.value > 0); _;}

    // -- Modifiers

    // Events

    event ProposalFundReceived(uint weiReceived);
    event CuratorRewardReceived(uint weiReceived);
    event FoundationRewardReceived(uint weiReceived);

    event FundsReceived(
        uint totalWei, 
        uint proposalFundWei,
        uint curatorRewardWei,
        uint foundationRewardWei);

    event ProposalFundsWithdrawn(uint weiAmount, uint nextDate);
    event CuratorRewardWithdrawn(uint weiAmount, uint nextDate);
    event FoundationRewardWithdrawn(uint weiAmount, uint nextDate);
    // --Events
}