import { expect, increase } from "chai";
import Web3 = require('web3');
import { expectThrow, revert, snapshot, mineBlocks, reset } from "./helpers/index"

const PreICO = artifacts.require("./PreICO.sol");
const Tempo = require('@digix/tempo');
const { wait, waitUntilBlock } = require('@digix/tempo')(web3)
const web3Instance: Web3 = web3;

var pr = null; // forecaster instance

var king;
var queen;
var jack;
var ace;
var joker;
var amount:number;
var magpie;

function ReturnEventAndArgs(returnVal)
{
    return { eventName: returnVal.logs[0].event, 
             eventArgs: returnVal.logs[0].args.action,
             raw: returnVal }
}

function GetBalance(addr)
{ return web3.eth.getBalance(addr).toNumber(); }

function SendWei(from, to, amount)
{ web3.eth.sendTransaction({from:from, to:to, value:amount }); }

contract("PreICO", (accounts) =>
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

    describe("Initialization", async()=>
    {
        it("Should init correctly", async()=>
        {
            pr = await PreICO.new(king, queen, jack, ace);

            expect(await pr.isAdministrator(king), "King incorrect/not set").to.be.true;
            expect(await pr.isAdministrator(queen), "Queen incorrect/not set").to.be.true;
            expect(await pr.isAdministrator(jack), "Jack incorrect/not set").to.be.true;
            expect(await pr.isAdministrator(ace), "Ace incorrect/not set").to.be.true;
        })
    })

    
    describe("Incorrect Initialization", async()=>
    {
        it("Should fail (passing empty admins)", async()=>
        {
            expect(await expectThrow(PreICO.new(0,0,0,0)),
                "Passing 0 as param")
                .to.be.true;

           expect(await expectThrow(PreICO.new(0, queen, jack, ace)), 
                "Passing first admin as 0 ")
                .to.be.true;

            expect(await expectThrow(PreICO.new(king, 0, jack, ace)), 
                "Passing second admin as 0")
                .to.be.true;

            expect(await expectThrow(PreICO.new(king, queen, 0, ace)), 
                "Passing third admin as 0")
                .to.be.true;

            expect(await expectThrow(PreICO.new(king, queen, jack, 0)), 
                "Passing fourth admin as 0")
                .to.be.true;
        })

        it("Should fail (passing same admins)", async()=>
        {
            expect(await expectThrow(PreICO.new(king,king,queen,jack)),
                "Passing 0 as param")
                .to.be.true;

            expect(await expectThrow(PreICO.new(king,jack,queen,jack)),
                "Passing 0 as param")
                .to.be.true;

            expect(await expectThrow(PreICO.new(ace,ace,ace,ace)),
                "Passing 0 as param")
                .to.be.true;

            expect(await expectThrow(PreICO.new(king,jack,queen,queen)),
                "Passing 0 as param")
                .to.be.true;
        })
    })

    describe("Test fallback function", async()=>
    {
        it("Contract balance should increase", async()=>
        {  
            var amount = web3.toWei(1, "ether");

            pr = await PreICO.new(king, queen, jack, ace);

            expect(() => SendWei(joker, pr.address, amount),  // send 1 ether
                "Balance was not increased") 
                .to.increase(() => GetBalance(pr.address))    // check balance
                .by(amount);
        })  
    })

    describe("Penetrating transfer function", async()=>
    {
        before(async()=>
        {
            pr = await PreICO.new(king, queen, jack, ace);
            amount = web3.toWei(1, "ether");
        })

        it("Passing incorrect params", async()=>
        {
            expect(await expectThrow(pr.transfer(joker, 0, {from: king})), 
                "Passing 0 for amount")
                .to.be.true;
                                                  
            expect(await expectThrow(
                pr.transfer("0x0000000000000000000000000000000000000000", 0, {from: king})), 
                "Passing 0xasd for recipient")
                .to.be.true;

            expect(await expectThrow (pr.transfer(0, 0, {from: king})), 
                "Passing 0 for recipient")
                .to.be.true;
        })

        it("Should correctly transfer funds to address", async()=>
        {
            // Add funds to contract address
            expect(() => SendWei(joker, pr.address, amount),  // send 1 ether
                "Balance was not increased") 
                .to.increase(() => GetBalance(pr.address))    // check balance
                .by(amount);
            
            let balance = GetBalance(magpie);
            
            let r = ReturnEventAndArgs(await pr.transfer(magpie, amount, {from: king}))

            expect(r.eventName, 
                "Event Violation was not fired")
                .to.be.equal("TransferConfirmed");

            await pr.transfer(magpie, amount, {from: queen});
            r = ReturnEventAndArgs(await pr.transfer(magpie, amount, {from: jack}));

            expect(r.raw.logs[1].args.success, 
                "Trasnfer was not successful")
                .to.be.true;

            expect(GetBalance(magpie),
                "Transfer should've increase balance")
                .to.equal(+balance + +amount);        
        })

        describe("Invoking transfer violations", async()=>
        {
            beforeEach(async()=>
            {
                pr = await PreICO.new(king, queen, jack, ace);
                
                expect(() => SendWei(joker, pr.address, amount),  // send 1 ether
                    "Balance was not increased") 
                    .to.increase(() => GetBalance(pr.address))    // check balance
                    .by(amount);
            })
            
            it("Sending different amount of ether", async()=>
            {            
                let balance = GetBalance(magpie);
                
                await pr.transfer(magpie, amount, {from: king});

                let r = ReturnEventAndArgs(await pr.transfer(magpie, amount/2, {from: king}));

                expect(r.eventArgs, 
                    "Event Violation was not fired")
                    .to.be.equal("Incorrect amount of wei passed");
                    
                await pr.transfer(magpie, amount, {from: king});
                await pr.transfer(magpie, amount, {from: jack}); 
                await pr.transfer(magpie, amount, {from: queen});

                expect(GetBalance(magpie),
                    "Transfer should've increase balance")
                    .to.equal(+balance + +amount);     
            })

            it("Trying to spam", async()=>
            {
                let balance = GetBalance(magpie);
                
                await pr.transfer(magpie, amount, {from: king});
                let r = ReturnEventAndArgs(await pr.transfer(magpie, amount, {from: king}));

                expect(r.eventArgs, 
                    "Event Violation was notfired")
                    .to.be.equal("Signer is spamming");
                
                // Previous transfer confirmation sequence got dropped - need to start from begining 
                await pr.transfer(magpie, amount, {from: king});
                await pr.transfer(magpie, amount, {from: jack}); 
                await pr.transfer(magpie, amount, {from: queen}); 

                expect(GetBalance(magpie),
                    "Transfer should've increase balance")
                    .to.equal(+balance + +amount);  
            })

            it("Trying to spam (level2)", async()=>
            {
                let balance = GetBalance(magpie);

                await pr.transfer(magpie, amount, {from: king});
                await pr.transfer(magpie, amount, {from: queen});

                let r = ReturnEventAndArgs(await pr.transfer(magpie, amount, {from: queen}));

                expect(r.eventArgs, 
                    "Event Violation was notfired")
                    .to.be.equal("One of signers is spamming");
            })
        })
    })

    describe("Testing updateAdministratorKey", async()=>
    {
        beforeEach(async()=>
        {
            pr = await PreICO.new(king, queen, jack, ace);
            amount = web3.toWei(1, "ether");
        })

        it("Passing Incorrect params", async()=>
        {
            expect(await expectThrow(pr.updateAdministratorKey(king, king, {from:king})), 
                "Giving admin to admin")
                .to.be.true;

            expect(await expectThrow(pr.updateAdministratorKey(king, 0, {from:king})), 
                "Giving admin to 0")
                .to.be.true;
        })

        it("Should correctly change admins", async()=>
        {
            let r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:queen}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:jack}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            expect(r.raw.logs[1].event, 
                "Event KeyReplaced was not fired")
                .to.be.equal("KeyReplaced");
        })

        it  ("Violating admin change (oldAddress)", async()=>
        {
            let r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(jack, joker, {from:queen}));
            expect(r.eventArgs, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("Old addresses do not match");
        })

        it("Violating admin change (newAddress)", async()=>
        {
            let r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, magpie, {from:queen}));
            expect(r.eventArgs, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("New addresses do not match");
        })

        it("Violating admin change (Spamming #0)", async()=>
        {
            let r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventArgs, 
                "Event UpdateConfirmed was not fired")
                .to.be.equal("Signer is spamming");
        })

        it("Violating admin change (Spamming #1)", async()=>
        {
            let r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:king}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired (First Admin)")
                .to.be.equal("UpdateConfirmed");

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:queen}));
            expect(r.eventName, 
                "Event UpdateConfirmed was not fired (Second Admin)")
                .to.be.equal("UpdateConfirmed");
            
             expect((await pr.isAdministrator(joker)),
                "Should not be admin")
                .to.be.false;

            r = ReturnEventAndArgs(await pr.updateAdministratorKey(ace, joker, {from:queen}));
            expect(r.eventArgs, 
                "Event Event with arg: One of signers is spamming was not fired")
                .to.be.equal("One of signers is spamming");

            expect((await pr.isAdministrator(joker)),
                "Should not be admin")
                .to.be.false;
        })
    })
})