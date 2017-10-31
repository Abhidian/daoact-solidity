/**
 *  CappedCrowdsale.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Draglet GbmH
 */

pragma solidity 0.4.17;

import './Crowdsale.sol';

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  // Wie equall to one million usd depending upon ethPrice
  uint256 public softCap;
 
  // Wie equall to five million usd depending upon ethPrice
  uint256 public hardCap;
  
  // price of ether in usd
  uint256 public ethPrice = 300;

  function CappedCrowdsale(uint256 _softCap,uint256 _hardCap) public {
    require(_softCap > 0);
    require(_hardCap > 0);
    
    softCap = _softCap * 1 ether;
    
    hardCap = _hardCap * 1 ether;
  }

  // set Cap of the crowdsale
  // @return true if cap is set successfully
  function setEthPrice(uint256 _softCap,uint256 _hardCap) external onlyOwner returns (bool) {
    require(_softCap > 0);
    require(_hardCap > 0);
    
    softCap = _softCap * 1 ether;
    hardCap = _hardCap * 1 ether;
    return true;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    return super.validPurchase() && weiRaised.add(msg.value) <= hardCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= softCap;
    return super.hasEnded() || capReached;
  }

}