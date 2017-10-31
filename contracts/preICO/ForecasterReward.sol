pragma solidity 0.4.17;

import '../misc/Haltable.sol';
import '../misc/SafeMath.sol';

contract ForecasterReward is Haltable {

  using SafeMath for uint;

  /* the starting time of the crowdsale */
  uint private startsAt;

  /* the ending time of the crowdsale */
  uint private endsAt;

  /* How many wei of funding we have received so far */
  uint private weiRaised = 0;

  /* How many distinct addresses have invested */
  uint private investorCount = 0;
  
  /* How many total investments have been made */
  uint private totalInvestments = 0;
  
  /* Address of forecasters contract*/
  address private forecasters;
  
  /* Address of pre-ico contract*/
  address private preICOContract;
 

  /** How much ETH each address has invested to this crowdsale */
  mapping (address => uint256) public investedAmountOf;

  
  /** State machine
   *
   * - Prefunding: We have not passed start time yet
   * - Funding: Active crowdsale
   * - Closed: Funding is closed.
   */
  enum State{PreFunding, Funding, Closed}

  // A new investment was made
  event Invested(uint index, address indexed investor, uint weiAmount);

  // Funds transfer to other address
  event Transfer(address indexed receiver, uint weiAmount);

  // Crowdsale end time has been changed
  event EndsAtChanged(uint endTimestamp);

  function ForecasterReward(
      address frOwner,
      uint startTimestamp, 
      uint endTimestamp, 
      address forecastersAddr, 
      address preICOContractAddr) public
  {
    
    require(frOwner != 0x00);
    require(forecastersAddr != 0x00);
    require(preICOContractAddr != 0);
    require(startTimestamp >= now); 
    require(endTimestamp  >= startTimestamp); 

    owner = frOwner;
    forecasters = forecastersAddr;
    preICOContract = preICOContractAddr;
    
    startsAt = startTimestamp;
    endsAt = endTimestamp;
  }

  /**
   * Allow investor to just send in money
   */
  function() nonZero payable public{
    buy(msg.sender);
  }

  /**
   * Make an investment.
   *
   * Crowdsale must be running for one to invest.
   * We must have not pressed the emergency brake.
   *
   * @param receiver The Ethereum address who have invested
   *
   */
  function buy(address receiver) stopInEmergency inState(State.Funding) nonZero public payable{
    require(receiver != 0x00);
    
    uint weiAmount = msg.value;
   
    if(investedAmountOf[receiver] == 0) {
      // A new investor
      investorCount++;
    }

    // count all investments
    totalInvestments++;

    // Update investor
    investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
    
    // Up total accumulated fudns
    weiRaised = weiRaised.add(weiAmount);
    
    // Pocket the money
    if(!distributeFunds()) revert();
    
    // Tell us invest was success
    Invested(totalInvestments, receiver, weiAmount);
  }

  /**
   * @return forecasters Address of forecaster reward contract
   */
  function forecastersAddress() public constant returns(address){
      return forecasters;
  }
  
  /**
   * @return preICO Address of PreICO Wallet contract
   */
  function preICOAddress() public constant returns(address){
      return preICOContract;
  }
  
  /**
   * @return startDate Crowdsale opening date
   */
  function fundingStartAt() public constant returns(uint ){
      return startsAt;
  }
  
  /**
   * @return endDate Crowdsale closing date
   */
  function fundingEndsAt() public constant returns(uint){
      return endsAt;
  }
  
  /**
   * @return investors Total of distinct investors
   */
  function distinctInvestors() public constant returns(uint){
      return investorCount;
  }
  
  /**
   * @return investments Crowdsale closing date
   */
  function investments() public constant returns(uint){
      return totalInvestments;
  }
  
  
  /**
   * Send out contributions imediately
   */
  function distributeFunds() private returns(bool){
   
    // calculate 5% of forecasters  
    uint forecasterReward = this.balance.div(20);
    
    if (!forecasters.send(forecasterReward)){
      return false;
    }
    
    Transfer(forecasters,forecasterReward);
        
    uint remaining = this.balance;
    
    if(!preICOContract.send(this.balance)){
      return false;
    }
    
    Transfer(preICOContract,remaining);
    return true;
  }
  
  /**
   * Allow crowdsale owner to close early or extend the crowdsale.
   *
   * This is useful e.g. for a manual soft cap implementation:
   * - after X amount is reached determine manual closing
   *
   * This may put the crowdsale to an invalid state,
   * but we trust owners know what they are doing.
   *
   */
  function setEndsAt(uint _endsAt) public onlyOwner {
    
    // Don't change past
    require(_endsAt > now);

    endsAt = _endsAt;
    EndsAtChanged(_endsAt);
  }

  /**
   * @return total of amount of wie collected by the contract 
   */
  function fundingRaised() public constant returns (uint){
    return weiRaised;
  }
  
  
  /**
   * Crowdfund state machine management.
   *
   * We make it a function and do not assign the result to a variable, so there is no chance of the variable being stale.
   */
  function getState() public constant returns (State) {
    if (now < startsAt) return State.PreFunding;
    else if (now <= endsAt) return State.Funding;
    else if (now > endsAt) return State.Closed;
  }

  /** Interface marker. */
  function isCrowdsale() public constant returns (bool) {
    return true;
  }

  //
  // Modifiers
  //
  /** Modifier allowing execution only if the crowdsale is currently running.  */
  modifier inState(State state) {
    require(getState() == state);
    _;
  }

  /** Modifier allowing execution only if received value is greater than zero */
  modifier nonZero(){
    require(msg.value > 0);
    _;
  }
}

