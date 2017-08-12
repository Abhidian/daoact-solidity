"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var _this = this;
Object.defineProperty(exports, "__esModule", { value: true });
var ForecasterReward = artifacts.require("./ForecasterReward.sol");
var Tempo = require('@digix/tempo');
var _a = require('@digix/tempo')(web3), wait = _a.wait, waitUntilBlock = _a.waitUntilBlock;
var chai_1 = require("chai");
var index_1 = require("./helpers/index");
var fr = null; // forecaster instance
var startTimeOffset = 10 * 60;
var endTimeOffset = 10 * 60;
var owner;
var startTime;
var endTime;
var forecaster;
var preICO;
var investor0;
var investor1;
var state = {
    'PreFunding': 0,
    'Funding': 1,
    'Closed': 2
};
function currentTimeInSec() { return Math.floor(new Date().getTime() / 1000); }
function lastBlockTimeInSec() { return web3.eth.getBlock(web3.eth.blockNumber).timestamp; }
contract("ForecasterReward", function (accounts) {
    describe("Initialization", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            before(function () { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    owner = accounts[0];
                    startTime = lastBlockTimeInSec() + startTimeOffset;
                    endTime = startTime + endTimeOffset;
                    forecaster = accounts[1];
                    preICO = accounts[2];
                    investor0 = accounts[3];
                    investor1 = accounts[4];
                    return [2 /*return*/];
                });
            }); });
            it("Should init correctly ", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d, _e;
                return __generator(this, function (_f) {
                    switch (_f.label) {
                        case 0: return [4 /*yield*/, ForecasterReward.new(owner, startTime, endTime, forecaster, preICO)];
                        case 1:
                            fr = _f.sent();
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.owner()];
                        case 2:
                            _a.apply(void 0, [_f.sent(), "Owner incorrect/not set"]).to.equal(owner);
                            _b = chai_1.expect;
                            return [4 /*yield*/, fr.forecastersAddress()];
                        case 3:
                            _b.apply(void 0, [_f.sent(), "Forecasters incorrect/not set"]).to.equal(forecaster);
                            _c = chai_1.expect;
                            return [4 /*yield*/, fr.preICOAddress()];
                        case 4:
                            _c.apply(void 0, [_f.sent(), "PreICO incorrect/not set"]).to.equal(preICO);
                            _d = chai_1.expect;
                            return [4 /*yield*/, fr.fundingStartAt()];
                        case 5:
                            _d.apply(void 0, [(_f.sent()).toNumber(), "Start Time incorrect/not set"]).to.equal(startTime);
                            _e = chai_1.expect;
                            return [4 /*yield*/, fr.fundingEndsAt()];
                        case 6:
                            _e.apply(void 0, [(_f.sent()).toNumber(), "End Time incorrect/not set"]).to.equal(endTime);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Incorrect Initialization", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            it("Should fail (passing wrong params)", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d, _e, _f;
                return __generator(this, function (_g) {
                    switch (_g.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(0, 0, 0, 0, 0))];
                        case 1:
                            _a.apply(void 0, [_g.sent()]).to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(0, startTime, endTime, forecaster, preICO))];
                        case 2:
                            _b.apply(void 0, [_g.sent(),
                                "Passing owner as 0 should throw"])
                                .to.be.true;
                            _c = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, 0, endTime, forecaster, preICO))];
                        case 3:
                            _c.apply(void 0, [_g.sent(),
                                "Passing start block as 0 should throw"])
                                .to.be.true;
                            _d = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, startTime, 0, forecaster, preICO))];
                        case 4:
                            _d.apply(void 0, [_g.sent(),
                                "Passing end block as 0 should throw"])
                                .to.be.true;
                            _e = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, startTime, endTime, 0, preICO))];
                        case 5:
                            _e.apply(void 0, [_g.sent(),
                                "Passing forecaster as 0 should throw"])
                                .to.be.true;
                            _f = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, startTime, endTime, forecaster, 0))];
                        case 6:
                            _f.apply(void 0, [_g.sent(),
                                "Passing preIco as 0 should throw"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Testing Incorrect start/end block numbers", function () { return __awaiter(_this, void 0, void 0, function () {
                var blockNumber, _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            blockNumber = web3.eth.blockNumber;
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, blockNumber - 1, endTime, forecaster, preICO))];
                        case 1:
                            _a.apply(void 0, [_c.sent(),
                                "Passing already passed block number"])
                                .to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(ForecasterReward.new(owner, blockNumber - 1, endTime, forecaster, preICO))];
                        case 2:
                            _b.apply(void 0, [_c.sent(),
                                "End block should be ahead of start block"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Should not be allowed buying in halted mode", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            before(function () { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            owner = accounts[0];
                            startTime = lastBlockTimeInSec() + startTimeOffset;
                            endTime = startTime + endTimeOffset;
                            forecaster = accounts[1];
                            preICO = accounts[2];
                            investor0 = accounts[3];
                            investor1 = accounts[4];
                            return [4 /*yield*/, ForecasterReward.new(owner, startTime, endTime, forecaster, preICO)];
                        case 1:
                            fr = _a.sent();
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Contract should be initiated with PreFunding state", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a;
                return __generator(this, function (_b) {
                    switch (_b.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 1:
                            _a.apply(void 0, [(_b.sent()).toNumber()]).to.deep.equal(state["PreFunding"]);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Contract should traverse to Funding state", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 1:
                            _a.apply(void 0, [(_c.sent()).toNumber()]).to.deep.equal(state["PreFunding"]);
                            return [4 /*yield*/, wait(startTime - lastBlockTimeInSec() + 10)];
                        case 2:
                            _c.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 3:
                            _b.apply(void 0, [(_c.sent()).toNumber()]).to.deep.equal(state["Funding"]);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Contract should traverse to last Closed state", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 1:
                            _a.apply(void 0, [(_c.sent()).toNumber()]).to.deep.equal(state["Funding"]);
                            return [4 /*yield*/, wait(endTime - lastBlockTimeInSec() + 10)];
                        case 2:
                            _c.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 3:
                            _b.apply(void 0, [(_c.sent()).toNumber()]).to.deep.equal(state["Closed"]);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Investment flow", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            beforeEach(function () { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            owner = accounts[0];
                            startTime = lastBlockTimeInSec() + startTimeOffset;
                            endTime = startTime + endTimeOffset;
                            forecaster = accounts[1];
                            preICO = accounts[2];
                            investor0 = accounts[3];
                            investor1 = accounts[4];
                            return [4 /*yield*/, ForecasterReward.new(owner, startTime, endTime, forecaster, preICO)];
                        case 1:
                            fr = _a.sent();
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Try Sending in halt mode", function () { return __awaiter(_this, void 0, void 0, function () {
                var investment, _a, _b, _c, _d, _e, _f, _g;
                return __generator(this, function (_h) {
                    switch (_h.label) {
                        case 0:
                            investment = web3.toWei(1, "ether");
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 1:
                            _a.apply(void 0, [(_h.sent()).toNumber(),
                                "State should be Prefunding"])
                                .to.deep.equal(state["PreFunding"]);
                            return [4 /*yield*/, wait(startTime - lastBlockTimeInSec() + 10)];
                        case 2:
                            _h.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 3:
                            _b.apply(void 0, [(_h.sent()).toNumber(),
                                "State should be Funding"])
                                .to.deep.equal(state["Funding"]);
                            return [4 /*yield*/, fr.buy(investor0, { value: investment, from: investor0 })];
                        case 4:
                            _h.sent();
                            return [4 /*yield*/, fr.buy(investor0, { value: investment, from: investor0 })];
                        case 5:
                            _h.sent();
                            return [4 /*yield*/, fr.buy(investor1, { value: investment, from: investor1 })];
                        case 6:
                            _h.sent();
                            _c = chai_1.expect;
                            return [4 /*yield*/, fr.distinctInvestors()];
                        case 7:
                            _c.apply(void 0, [(_h.sent()).toNumber(), "Should be 2 investors"]).to.equal(2);
                            _d = chai_1.expect;
                            return [4 /*yield*/, fr.investments()];
                        case 8:
                            _d.apply(void 0, [(_h.sent()).toNumber(), "Should be 3 investments"]).to.equal(3);
                            _e = chai_1.expect;
                            return [4 /*yield*/, fr.fundingRaised()];
                        case 9:
                            _e.apply(void 0, [(_h.sent()).toNumber(), "Should be 3 ethers"]).to.equal(3 * investment);
                            return [4 /*yield*/, fr.halt({ from: owner })];
                        case 10:
                            _h.sent();
                            _f = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(fr.buy(investor0, { value: investment, from: investor0 }))];
                        case 11:
                            _f.apply(void 0, [_h.sent(),
                                "Buying in halted mode should not work"])
                                .to.be.true;
                            _g = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(fr.buy(investor0, { value: investment, from: investor1 }))];
                        case 12:
                            _g.apply(void 0, [_h.sent(),
                                "Buying in halted mode should not work"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Traversing through all states and buying in between", function () { return __awaiter(_this, void 0, void 0, function () {
                var forecasterBalance, preICOBalance, investment, _a, _b, _c, _d, _e, _f, forecastersPart, expectedForForecaster, expectedForPreICO, _g, _h, _j;
                return __generator(this, function (_k) {
                    switch (_k.label) {
                        case 0:
                            forecasterBalance = web3.eth.getBalance(forecaster);
                            preICOBalance = web3.eth.getBalance(preICO);
                            investment = web3.toWei(1, "ether");
                            _a = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 1:
                            _a.apply(void 0, [(_k.sent()).toNumber(),
                                "State should be Prefunding"])
                                .to.deep.equal(state["PreFunding"]);
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(fr.buy(investor0, { value: investment, from: investor0 }))];
                        case 2:
                            _b.apply(void 0, [_k.sent(),
                                "Buying in PreFunding should be now allowed"])
                                .to.be.true;
                            return [4 /*yield*/, wait(startTime - lastBlockTimeInSec() + 10)];
                        case 3:
                            _k.sent();
                            _c = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 4:
                            _c.apply(void 0, [(_k.sent()).toNumber(),
                                "State should be Funding"])
                                .to.deep.equal(state["Funding"]);
                            return [4 /*yield*/, fr.buy(investor0, { value: investment, from: investor0 })];
                        case 5:
                            _k.sent();
                            return [4 /*yield*/, fr.buy(investor0, { value: investment, from: investor0 })];
                        case 6:
                            _k.sent();
                            return [4 /*yield*/, fr.buy(investor1, { value: investment, from: investor1 })];
                        case 7:
                            _k.sent();
                            _d = chai_1.expect;
                            return [4 /*yield*/, fr.distinctInvestors()];
                        case 8:
                            _d.apply(void 0, [(_k.sent()).toNumber(), "Should be 2 investors"]).to.equal(2);
                            _e = chai_1.expect;
                            return [4 /*yield*/, fr.investments()];
                        case 9:
                            _e.apply(void 0, [(_k.sent()).toNumber(), "Should be 3 investments"]).to.equal(3);
                            _f = chai_1.expect;
                            return [4 /*yield*/, fr.fundingRaised()];
                        case 10:
                            _f.apply(void 0, [(_k.sent()).toNumber(), "Should be 3 ethers"]).to.equal(3 * investment);
                            forecastersPart = ((investment * 3) / 20);
                            expectedForForecaster = forecasterBalance.toNumber() + forecastersPart;
                            expectedForPreICO = preICOBalance.toNumber() + (investment * 3 - forecastersPart);
                            _g = chai_1.expect;
                            return [4 /*yield*/, web3.eth.getBalance(forecaster).toNumber()];
                        case 11:
                            _g.apply(void 0, [_k.sent(),
                                "Forecasters balance is incorrect"])
                                .to.equal(expectedForForecaster);
                            _h = chai_1.expect;
                            return [4 /*yield*/, web3.eth.getBalance(preICO).toNumber()];
                        case 12:
                            _h.apply(void 0, [_k.sent(),
                                "PreICO balance is incorrect"])
                                .to.equal(expectedForPreICO);
                            return [4 /*yield*/, wait(endTime - lastBlockTimeInSec() + 10)];
                        case 13:
                            _k.sent();
                            _j = chai_1.expect;
                            return [4 /*yield*/, fr.getState()];
                        case 14:
                            _j.apply(void 0, [(_k.sent()).toNumber(),
                                "State should be Closed"])
                                .to.deep.equal(state["Closed"]);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
});
//# sourceMappingURL=testForecaster.js.map