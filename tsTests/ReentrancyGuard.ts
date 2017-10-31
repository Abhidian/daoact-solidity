const ReentrancyGuardMock = artifacts.require("ReentrancyGuardMock")
const ReentrancyGuardAttack = artifacts.require("ReentrancyGuardAttack")
import { expectThrow } from "./helpers/index"
import { expect } from "chai"

var rg = null; // ReentrancyGuardMock 
var ra = null; // ReentrancyGuardAttack

contract("ReentrancyGuard", (accounts) =>
{
    beforeEach(async()=>
    {
        rg = await ReentrancyGuardMock.new();
        
        expect((await rg.counter()).toNumber(),
            "Count should be 0") 
          .to.equal(0);
    })

    it("Should not allow remote callback", async()=>
    {
        ra = await ReentrancyGuardAttack.new();

        expect(await (expectThrow(rg.CountAndCall(ra.address))),
            "Should throw")
            .to.be.true;
    })

    it("Should not allow local recursion", async()=>
    {
        expect(await (expectThrow(rg.CountLocalRecursive(10))),
            "Should throw")
            .to.be.true;
    })

    it("Should not allow indirect local recursion", async()=>
    {
        expect(await (expectThrow(rg.CountThisRecursive(10))),
            "Should throw")
            .to.be.true;
    })
})

