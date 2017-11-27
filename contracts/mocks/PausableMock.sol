pragma solidity 0.4.18;

import "../misc/Pausable.sol";

contract PausableMock is Pausable
{
    bool public action;
    uint256 public count;

    function PausableMock(address setOwner) public
    { owner = setOwner; }

    function RandomAction() external whenNotPaused
    { count++; }

    function CrazyAction() external whenPaused
    { action = true; }
}