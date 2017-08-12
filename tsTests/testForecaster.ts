const ForecasterReward = artifacts.require("./ForecasterReward.sol");
const Tempo = require('@digix/tempo');
const { wait, waitUntilBlock } = require('@digix/tempo')(web3)
import { expect, should } from "chai";
import { expectThrow } from "./helpers/index"

    var fr = null; // forecaster instance

    var startBlockOffset = 5;
    var endBlockOffset = 10;
    var owner;
    var startBlock;
    var endBlock;
    var forecaster;
    var preICO;
    var investor0;
    var investor1;

    const state = 
    {
        'PreFunding':0, 
        'Funding':1, 
        'Closed':2
    }
    
contract("ForecasterReward", (accounts) =>
{
    describe("Initialization", async()=>
    {
        before(async()=>
        {
            owner = accounts[0];
            startBlock = web3.eth.blockNumber + startBlockOffset;
            endBlock = startBlock + endBlockOffset;
            forecaster = accounts[1];
            preICO = accounts[2];
            investor0 = accounts[3];
            investor1 = accounts[4];
        });

        it("Should init correctly ", async()=>
        {     
            fr = await ForecasterReward.new
                (owner, 
                startBlock, 
                endBlock,
                forecaster, 
                preICO);

            expect(await fr.owner(), "Owner incorrect/not set").to.equal(owner);
            expect(await fr.forecastersAddress(), "Forecasters incorrect/not set").to.equal(forecaster);
            expect(await fr.preICOAddress(), "PreICO incorrect/not set").to.equal(preICO);
            expect((await fr.fundingStartAt()).toNumber(), "Start Block incorrect/not set").to.equal(startBlock);
            expect((await fr.fundingEndsAt()).toNumber(), "End BLock incorrect/not set").to.equal(endBlock);
        });
    });

    describe("Incorrect Initialization", async()=>
    {
        it("Should fail (passing wrong params)", async()=>
        {
            expect(await expectThrow(ForecasterReward.new(0,0,0,0,0))).to.be.true;

            expect(await expectThrow(
                ForecasterReward.new(0,startBlock,endBlock,forecaster,preICO)),
                "Passing owner as 0 should throw")
                    .to.be.true;
                    
            expect(await expectThrow(
                ForecasterReward.new(owner,0,endBlock,forecaster,preICO)),
                "Passing start block as 0 should throw")
                    .to.be.true;

            expect(await expectThrow(
                ForecasterReward.new(owner,startBlock,0,forecaster,preICO)),
                "Passing end block as 0 should throw")
                    .to.be.true;

            expect(await expectThrow(
                ForecasterReward.new(owner,startBlock,endBlock,0,preICO)),
                "Passing forecaster as 0 should throw")
                    .to.be.true;

            expect(await expectThrow(
                ForecasterReward.new(owner,startBlock,endBlock,forecaster,0)),
                "Passing preIco as 0 should throw")
                    .to.be.true;
            
        });

        it("Testing Incorrect start/end block numbers", async()=>
        {
            let blockNumber = web3.eth.blockNumber;

            expect(await expectThrow(
                ForecasterReward.new(owner,blockNumber - 1,endBlock,forecaster,preICO)),
                "Passing already passed block number")
                    .to.be.true;

            expect(await expectThrow(
                ForecasterReward.new(owner,blockNumber - 1,endBlock,forecaster,preICO)),
                "End block should be ahead of start block"
                )
                    .to.be.true;
        })
    });

    describe("Testing states", async()=>
    {
        before(async()=>
        {
            owner = accounts[0];
            startBlock = web3.eth.blockNumber + startBlockOffset;
            endBlock = startBlock + endBlockOffset;
            forecaster = accounts[1];
            preICO = accounts[2];
            investor0 = accounts[3];
            investor1 = accounts[4];

            fr = await ForecasterReward.new
                (owner, 
                startBlock, 
                endBlock,
                forecaster, 
                preICO);
        });

        it("Contract should be initiated with PreFunding state", async()=>
        {
            expect((await fr.getState()).toNumber()).to.deep.equal(state["PreFunding"]);
        });

        it("Contract should traverse to Funding state", async()=>
        {
            expect((await fr.getState()).toNumber()).to.deep.equal(state["PreFunding"]);
            await waitUntilBlock(0, startBlock + 1);
            expect((await fr.getState()).toNumber()).to.deep.equal(state["Funding"]);
        });

        it("Contract should traverse to last Closed state", async()=>
        {
            expect((await fr.getState()).toNumber()).to.deep.equal(state["Funding"]);
            await waitUntilBlock(0, endBlock + 1);
            expect((await fr.getState()).toNumber()).to.deep.equal(state["Closed"]);
        });
    });

    describe("Investment flow", async()=>
    {
        before(async()=>
        {
            owner = accounts[0];
            startBlock = web3.eth.blockNumber + startBlockOffset;
            endBlock = startBlock + endBlockOffset;
            forecaster = accounts[1];
            preICO = accounts[2];
            investor0 = accounts[3];
            investor1 = accounts[4];

            fr = await ForecasterReward.new
                (owner, 
                startBlock, 
                endBlock,
                forecaster, 
                preICO);
        });

        it("Funding", async()=>
        {
            let forecasterBalance = web3.eth.getBalance(forecaster);
            let preICOBalance = web3.eth.getBalance(preICO);

            let investment = web3.toWei(1, "ether");
            expect((await fr.getState()).toNumber()).to.deep.equal(state["PreFunding"]);

            expect(await expectThrow(fr.buy(investor0, {value:investment, from:investor0})),
                "Buying in PreFunding should be now allowed")
                    .to.be.true;
            
            await waitUntilBlock(0, startBlock + 1);
            expect((await fr.getState()).toNumber()).to.deep.equal(state["Funding"]);

            await fr.buy(investor0, {value:investment, from:investor0});
            await fr.buy(investor0, {value:investment, from:investor0});
            await fr.buy(investor1, {value:investment, from:investor1});

            expect((await fr.distinctInvestors()).toNumber(), "Should be 2 investors").to.equal(2);
            expect((await fr.investments()).toNumber(), "Should be 3 investments").to.equal(3);
            expect((await fr.fundingRaised()).toNumber(), "Should be 3 ethers").to.equal(3*investment);
            
            let expectedForForecaster = forecasterBalance + (investment*3) / 20; // 5%
            let expectedForPreICO = preICOBalance + investment*3 - expectedForForecaster;
            
            console.log("EFore: " + expectedForForecaster);
            console.log("PreICO: "+ expectedForPreICO);

            expect(await web3.eth.getBalance(forecaster).valueOf(), 
                "Forecasters balance is incorrect")
                .to.deep.equal(expectedForForecaster);

            expect(await web3.eth.getBalance(preICO).valueOf(),
                "PreICO balance is incorrect")
                .to.deep.equal(expectedForPreICO);

            console.log("Fore: "  + web3.fromWei(web3.eth.getBalance(forecaster)));
            console.log("PreICO: " + web3.fromWei(web3.eth.getBalance(preICO)));
        });
    })
});