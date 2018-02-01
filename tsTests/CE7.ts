const ACTToken = artifacts.require("./CE7.sol");
const GenericToken = artifacts.require("./GenericToken.sol")
const BigNumber = web3.BigNumber

import { expect, should } from "chai";
import { expectThrow, revert, snapshot, mineBlocks, reset, lastBlockTimeInSec } 
        from "./helpers/index"

var actToken = null; // ActToken instance
var gt = null; // Generic Token instance

var hardOwner = "0x1538ef80213cde339a333ee420a85c21905b1b2d";
var hardSupplyOwner = "0x244092a2FECFC48259cf810b63BA3B3c0B811DCe";

var name = "Curation Engine 7";
var symbol = "CE7";
var decimals = 4;
var supply = 10e6 * 1e4; // 10 Millions + 4 decimals
var version = "v1.0.0";

function ReturnEventAndArgs(returnVal)
{
    return { eventName: returnVal.logs[0].event, 
             eventArgs: returnVal.logs[0].args.action,
             raw: returnVal }
}

var king, queen, jack, ace, joker, magpie;
contract("ACTToken", (accounts)=>
{
    before(async()=>
    { 
        king = accounts[0];
        queen = accounts[1]; 
        jack = accounts[2];
        ace = accounts[3];
        joker = accounts[4];
        magpie = accounts[5];
    })

    describe("Initialize", async()=>
    {
        it("Should init ACTToken", async()=>
        {
                actToken = await ACTToken.new(king, king);

                expect(await actToken.owner(), 
                        "Owners should match")
                        .to.equal(king);

                expect((await actToken.totalSupply()).toNumber(),
                        "Total supply should match")
                        .to.equal(supply);

                expect((await actToken.balanceOf(king)).toNumber(),
                        "Balance should equal to initial supply")
                        .to.equal(supply);
        })

        it("Should correctly init GenericToken for migration", async()=>
        {
                gt = await GenericToken.new();
                actToken = await ACTToken.new(king, king);

                expect((await gt.originalSupply()).toNumber(),
                        "Supplies should be equal")
                        .to.equal((await actToken.totalSupply()).toNumber());
        })
     })
     
     describe("ACTToken transfers", async()=>
     {
             beforeEach(async()=> 
             {
                     king = accounts[0];
                     queen = accounts[1];

                     actToken = await ACTToken.new(king, king);
             })

             it("Should return correct totalSupply after contstruction", async()=> 
             {
                     expect((await actToken.totalSupply()).toNumber(),
                             "Total supply does not match")
                             .to.equal(supply);
             })

             it("Should return correct balances after transfer", async()=> 
             {
                     await actToken.transfer(queen, supply, {from:king});

                     expect((await actToken.balanceOf(king)).toNumber(),
                             "Should be empty")
                             .to.equal(0);

                     expect((await actToken.balanceOf(queen)).toNumber(),
                             "Should be lot of money")
                             .to.equal(supply);
             })

             it("Should throw when trying to transfer more than balance", async()=> 
             {
                     console.log()
                     expect(await expectThrow(actToken.transfer(queen, supply * 2,{from:king})),
                             "Expected a throw")
                             .to.be.true;
             })      

     })

     describe("Migration", async()=>
     {
             it("Should switch Upgrading on/off", async()=>
             {
                     actToken = await ACTToken.new(king, king);
                     
                     expect(await actToken.upgradingEnabled(),
                             "Upgrading should be off")
                             .to.equal(false);

                     await actToken.tweakUpgrading({from: king});

                     expect(await actToken.upgradingEnabled(),
                             "Upgrading should be on")
                             .to.equal(true);
             })

             it("Should set Migration Agent", async()=>
             {
                     gt = await GenericToken.new();
                     actToken = await ACTToken.new(king, king);

                     expect((await gt.originalSupply()).toNumber(),
                             "Supplies should be equal")
                             .to.equal((await actToken.totalSupply()).toNumber());
                     

                     await actToken.tweakUpgrading({from:king});
                     
                     expect(await gt.isMigrationAgent.call(),
                             "Should be MigrationAgent")
                             .to.be.true;

                     expect(await actToken.upgradingEnabled(),
                             "Should be upgrading")
                             .to.be.true;

                     await actToken.setMigrationAgent(gt.address);

                     expect(await actToken.migrationAgent(),
                             "Migration addresses should match")
                             .to.equal(gt.address);

             })

             it("Should migrate", async()=>
             {
                     gt = await GenericToken.new();
                     actToken = await ACTToken.new(king, king);
                     
                     expect((await gt.originalSupply()).toNumber(),
                             "Supplies should be equal")
                             .to.equal((await actToken.totalSupply()).toNumber());

                     await actToken.tweakUpgrading();
                     await actToken.setMigrationAgent(gt.address);

                     let value = supply/10;
                     let balanceOfKing = (await actToken.balanceOf(king)).toNumber();

                     let r = ReturnEventAndArgs(await actToken.migrate(value));
                     
                     expect(r.eventName, 
                             "Event Migrate was not fired")
                             .to.be.equal("Migrate");

                     expect(r.raw.logs[0].args._from,
                             "Sender should be king")
                             .to.equal(king);

                     expect(r.raw.logs[0].args._to,
                             "To should be addres of new token")
                             .to.equal(gt.address);

                     expect(r.raw.logs[0].args._value.toNumber(),
                             "Value is incorrect")
                             .to.equal(value);

                     expect((await actToken.balanceOf(king)).toNumber(),
                             "Transfer was not correct")
                             .to.equal(balanceOfKing - value);

                     expect((await actToken.totalSupply()).toNumber(),
                             "Supply should drop")
                             .to.equal(supply - value);
             })
     })
})
