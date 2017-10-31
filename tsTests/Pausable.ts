const PausableMock = artifacts.require("PausableMock")
import { expectThrow } from "./helpers/index"
import { expect } from "chai"

var ps = null; // instance for Pausable

contract("Pausable", (accounts)=>
{
    beforeEach(async()=>
    {
        ps = await PausableMock.new(accounts[0]);
    })

    it("Can perform random action in non-pause", async()=>
    {
        let count = (await ps.count()).toNumber();

        expect(count,
            "Should equal to 0")
            .to.equal(0);

        await ps.RandomAction();
        count = (await ps.count()).toNumber();
        
        expect(count,
            "Should equal to 1")
            .to.equal(1);
    })

    it("Should not perfrom random action in pause", async()=>
    {
        await ps.tweakState();
        let count = (await ps.count()).toNumber();

        expect(count,
            "Should equal to 0")
            .to.equal(0);
        
        expect(await (expectThrow(ps.RandomAction())),
            "Should throw")
            .to.be.true;

        count = (await ps.count()).toNumber();

        expect(count,
            "Should equal to 0")
            .to.equal(0);
    })

    it("Should be allowed to take crazy action in a pause", async()=>
    {
        await ps.tweakState();
        await ps.CrazyAction();
        
        expect(await ps.action.call(),
            "Action was not taken")
            .to.equal(true);
    })

    it("Resuming actions after unpause", async()=>
    {
        await ps.tweakState(); // Pause
        await ps.tweakState(); // Unpause
        await ps.RandomAction();
        let count = (await ps.count()).toNumber();

        expect(count,
            "Should equal to 1")
            .to.equal(1);
    })

    it("Should prevent CrazyAction after unpause", async()=>
    {
        await ps.tweakState();
        await ps.tweakState();

        expect(await (expectThrow(ps.CrazyAction())),
            "Should throw")
            .to.be.true;

        expect(await ps.action.call(),
            "Action was taken")
            .to.equal(false);
    })
})