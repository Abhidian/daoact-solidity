pragma solidity 0.4.18;


import '../ico/CappedCrowdsale.sol';


contract CappedCrowdsaleMock is CappedCrowdsale {

  function CappedCrowdsaleMock
  (
    address tokenAddr,
    address tokenStoreAddr,
    uint256 startTime,
    uint256 endTime,
    uint256 rate,
    address wallet,
    uint256 softCap,
    uint256 hardCap
  ) public
    Crowdsale(
        tokenAddr, 
        tokenStoreAddr,
        startTime, 
        endTime, 
        rate, 
        wallet
    )
    CappedCrowdsale(softCap, hardCap)
  { }

}