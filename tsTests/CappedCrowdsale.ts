const CappedCrowdsale = artifacts.require("./CappedCrowdsaleMock.sol");
const BigNumber = web3.BigNumber

import { expect, should } from "chai";
import { expectThrow, revert, snapshot, mineBlocks, reset, lastBlockTimeInSec } 
        from "./helpers/index"

var cc = null; // CappedCrowdsale instance

const cap = 10 * 10**18; // cap in wei
const lessThanCap = cap / 2; 
const rate = new BigNumber(100);
const weekInSec = 604800;

var startTime, endTime;
contract("CappedCrowdsale", (accounts) =>
{
    before(async()=>
    {
        await mineBlocks();
    })

    beforeEach(async=>
    {
        startTime = lastBlockTimeInSec() + weekInSec;
        endTime = startTime + weekInSec;

        //cc = await CappedCrowdsale.new(startTime, endTime, accounts[0])
    })
})