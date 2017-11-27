pragma solidity 0.4.18;

import '../misc/SafeMath.sol';
import '../misc/Ownable.sol';

contract BeckySale is Ownable 
{
    using SafeMath for *;

    // array for user addresses who should get funds in distribution
    address[100] public UsersAddrList;
    
    // address for Foundation which will get remaining funds after distribution
    address public FoundationAddr;

    // Duration of fund acceptance
    uint public constant SaleDuration = 7 days;

    // Date which will be used to check if funding happens in sale timeframe
    uint public SaleStartDate;

    // Fallback function
    function () payable public { ObtainFunds(); }

    // Constructor
    function BeckySale(address foundationAddr, address[100] list) public
    {
        FoundationAddr = foundationAddr;
        SaleStartDate = now;
        UsersAddrList = list;
    }

    // Function to obtain funds called from fallback or directly
    function ObtainFunds() public payable
    OnlyInSaleDuration 
    { }

    // Ability to retrieve all funds
    function RetrieveFunds() external
    onlyOwner
    { owner.transfer(this.balance); }

    // Function to send out funds
    function SendOutFunds() external
    onlyOwner
    {
        uint amount = 0.1 ether;
        require(this.balance >= amount * 100);

        for (uint i = 0; i < UsersAddrList.length; i++)
            UsersAddrList[i].transfer(amount);

        if (this.balance > 0)
            FoundationAddr.transfer(this.balance);
    }

    // Modifier to check if fund is in timeframe
    modifier OnlyInSaleDuration
    { 
        require(now <= SaleStartDate + SaleDuration); 
        _;
    }

}