pragma solidity 0.4.18;

import "../misc/SafeMath.sol";

contract SafeMathMock
{
    uint256 public res;

    function mul(uint256 a, uint256 b) public
    { res = SafeMath.mul(a,b); }

    function div(uint256 a, uint256 b) public
    { res = SafeMath.div(a,b); }

    function sub(uint256 a, uint256 b) public
    { res = SafeMath.sub(a,b); }

    function add(uint256 a, uint256 b) public
    { res = SafeMath.add(a,b); }
}