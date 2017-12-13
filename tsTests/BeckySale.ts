const BeckySale = artifacts.require("./BeckySale.sol");
const BigNumber = web3.BigNumber;

const Tempo = require('@digix/tempo');
const { wait, waitUntilBlock } = require('@digix/tempo')(web3)

import { expect, should } from "chai";
import { expectThrow, revert, snapshot, mineBlocks, reset, lastBlockTimeInSec } 
        from "./helpers/index"

var beckySale = null; 

var king, queen, jack, ace, joker, magpie;

function lastBlockTimeInSec()
{ return web3.eth.getBlock(web3.eth.blockNumber).timestamp; }

contract("BeckySale", (accounts) =>
{
    function GetListOfAddresses()
    {
        var addrs = []
        for (var i = 0; i < 100; i++)
            addrs.push(accounts[5]);

        return addrs;
    }

    before(async()=>
    {
        king = accounts[0];
        queen = accounts[1]; 
        jack = accounts[2];
        ace = accounts[3];
        joker = accounts[4];
        magpie = accounts[5];
    })

    describe("Internal function: generatedAddresses", async()=>
    {
        it("Array and result should be equal", async()=>
        {
            var tempAddr = GetListOfAddresses();
            for (var i = 0; i < 100; i++)
            {
                expect(tempAddr[i])
                    .to.equal(accounts[5]);
            }
        })
    })

    describe("Initialize", async()=>
    {
        // function BeckySale(address foundationAddr, address[100] list)
        it("Should init BeckySale Contract", async()=>
        {
            beckySale = await BeckySale.new(queen, GetListOfAddresses(), {from: king});
            
            expect(await beckySale.owner(), 
                "Owners should match")
                .to.equal(king);

            expect(await beckySale.FoundationAddr(),
                "Foundation addresses should match")
                .to.equal(queen);

            var tempAddr = GetListOfAddresses();
            for (var i = 0; i < 100; i++)
            {
                expect(await beckySale.UsersAddrList(i))
                    .to.equal(accounts[5]);
            }

            expect((await beckySale.SaleDuration()).toNumber(),
                "Time duration is incorrect")
                .to.equal(7 * 24 * 3600); // 7 days
        })
    })

    describe("Functions", async()=>
    {
        it("Fallback function test", async()=>
        {
            beckySale = await BeckySale.new(queen, GetListOfAddresses(), {from: king});

            var valueInWei = 11e18; 
            await beckySale.sendTransaction({from: king, value: valueInWei});

            expect((web3.eth.getBalance(beckySale.address)).toNumber(),
                "Balance is icorrect")
                .to.equal(valueInWei);
        })

        it("ObtainFunds function test", async()=>
        {
            beckySale = await BeckySale.new(queen, GetListOfAddresses(), {from: king});
            
            var valueInWei = 11e18; 
            await beckySale.ObtainFunds({from: queen, value: valueInWei});

            expect((web3.eth.getBalance(beckySale.address)).toNumber(),
                "Balance is icorrect")
                .to.equal(valueInWei);
        })

        it("Retrieve Funds function test", async()=>
        {
            beckySale = await BeckySale.new(queen, GetListOfAddresses(), {from: king});
            
            var valueInWei = 11e18; 
            await beckySale.ObtainFunds({from: queen, value: valueInWei});

            var valueInWeiBefore = await (web3.eth.getBalance(king)).toNumber();

            var tx = await beckySale.RetrieveFunds({from: king});
            
            var gasPrice = web3.eth.getTransaction(tx.receipt.transactionHash).gasPrice;

            var txInWei = tx.receipt.gasUsed * gasPrice;

            expect((await web3.eth.getBalance(king)).toNumber(),
                "Balance is incorrect")
                .to.equal(+valueInWeiBefore + +valueInWei - +txInWei);
        })

        it("SendOutFunds function test", async()=>
        {
            beckySale = await BeckySale.new(joker, GetListOfAddresses(), {from: king});
            
            var valueInWei = 11e18; 
            await beckySale.ObtainFunds({from: queen, value: valueInWei});

            var weiBeforeFoundation = await web3.eth.getBalance(joker);
            var weiBeforeUsers = await web3.eth.getBalance(magpie);
            
            await beckySale.SendOutFunds({from: king});

            expect(await expectThrow(beckySale.SendOutFunds({from: queen})),
                "Expected a throw (incorrect owner)")
                .to.be.true;

            expect((await web3.eth.getBalance(joker)).toNumber(),
                "Foundation Balance is incorrect")
                .to.equal(+weiBeforeFoundation + +1e18);

            expect((await web3.eth.getBalance(magpie)).toNumber(),
                "Users Balance is incorrect")
                .to.equal(+weiBeforeUsers + +valueInWei - +1e18);
        })

        it("Modifier OnlyInSaleDuration", async()=>
        {
            beckySale = await BeckySale.new(joker, GetListOfAddresses(), {from: king});

            var valueInWei = 1e18; 
            await beckySale.ObtainFunds({from: queen, value: valueInWei});

            await wait(7*24*3600 + 1); // 7 days + 1 sec
            
            expect(await expectThrow(beckySale.ObtainFunds({from: jack, value: valueInWei})),
                "Should throw because too late")
                .to.be.true;
        })
    })
})