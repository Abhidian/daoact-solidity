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
var PreICO = artifacts.require("./PreICO.sol");
var Tempo = require('@digix/tempo');
var _a = require('@digix/tempo')(web3), wait = _a.wait, waitUntilBlock = _a.waitUntilBlock;
var chai_1 = require("chai");
var index_1 = require("./helpers/index");
var pr = null; // forecaster instance
var king;
var queen;
var jack;
var ace;
var joker;
var amount;
var magpie;
function GetBalance(addr) { return web3.eth.getBalance(addr).toNumber(); }
function SendWei(from, to, amount) { web3.eth.sendTransaction({ from: from, to: to, value: amount }); }
contract("PreICO", function (accounts) {
    before(function () { return __awaiter(_this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            king = accounts[0];
            queen = accounts[1];
            jack = accounts[2];
            ace = accounts[3];
            joker = accounts[4];
            magpie = accounts[5];
            return [2 /*return*/];
        });
    }); });
    describe("Initialization", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            it("Should init correctly", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d;
                return __generator(this, function (_e) {
                    switch (_e.label) {
                        case 0: return [4 /*yield*/, PreICO.new(king, queen, jack, ace)];
                        case 1:
                            pr = _e.sent();
                            _a = chai_1.expect;
                            return [4 /*yield*/, pr.isAdministrator(king)];
                        case 2:
                            _a.apply(void 0, [_e.sent(), "King incorrect/not set"]).to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, pr.isAdministrator(queen)];
                        case 3:
                            _b.apply(void 0, [_e.sent(), "Queen incorrect/not set"]).to.be.truue;
                            _c = chai_1.expect;
                            return [4 /*yield*/, pr.isAdministrator(jack)];
                        case 4:
                            _c.apply(void 0, [_e.sent(), "Jack incorrect/not set"]).to.be.true;
                            _d = chai_1.expect;
                            return [4 /*yield*/, pr.isAdministrator(ace)];
                        case 5:
                            _d.apply(void 0, [_e.sent(), "Ace incorrect/not set"]).to.be.true;
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
            it("Should fail (passing empty admins)", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d, _e;
                return __generator(this, function (_f) {
                    switch (_f.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(0, 0, 0, 0))];
                        case 1:
                            _a.apply(void 0, [_f.sent(),
                                "Passing 0 as param"])
                                .to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(0, queen, jack, ace))];
                        case 2:
                            _b.apply(void 0, [_f.sent(),
                                "Passing first admin as 0 "])
                                .to.be.true;
                            _c = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, 0, jack, ace))];
                        case 3:
                            _c.apply(void 0, [_f.sent(),
                                "Passing second admin as 0"])
                                .to.be.true;
                            _d = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, queen, 0, ace))];
                        case 4:
                            _d.apply(void 0, [_f.sent(),
                                "Passing third admin as 0"])
                                .to.be.true;
                            _e = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, queen, jack, 0))];
                        case 5:
                            _e.apply(void 0, [_f.sent(),
                                "Passing fourth admin as 0"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should fail (passing same admins)", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d;
                return __generator(this, function (_e) {
                    switch (_e.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, king, queen, jack))];
                        case 1:
                            _a.apply(void 0, [_e.sent(),
                                "Passing 0 as param"])
                                .to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, jack, queen, jack))];
                        case 2:
                            _b.apply(void 0, [_e.sent(),
                                "Passing 0 as param"])
                                .to.be.true;
                            _c = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(ace, ace, ace, ace))];
                        case 3:
                            _c.apply(void 0, [_e.sent(),
                                "Passing 0 as param"])
                                .to.be.true;
                            _d = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(PreICO.new(king, jack, queen, queen))];
                        case 4:
                            _d.apply(void 0, [_e.sent(),
                                "Passing 0 as param"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Test fallback function", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            it("Contract balance should increase", function () { return __awaiter(_this, void 0, void 0, function () {
                var amount;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            amount = web3.toWei(1, "ether");
                            return [4 /*yield*/, PreICO.new(king, queen, jack, ace)];
                        case 1:
                            pr = _a.sent();
                            chai_1.expect(function () { return SendWei(joker, pr.address, amount); }, // send 1 ether
                            "Balance was not increased")
                                .to.increase(function () { return GetBalance(pr.address); }) // check balance
                                .by(amount);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Penetrating transfer function", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            before(function () { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0: return [4 /*yield*/, PreICO.new(king, queen, jack, ace)];
                        case 1:
                            pr = _a.sent();
                            amount = web3.toWei(1, "ether");
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Passing incorrect params", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c;
                return __generator(this, function (_d) {
                    switch (_d.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(pr.transfer(joker, 0, { from: king }))];
                        case 1:
                            _a.apply(void 0, [_d.sent(),
                                "Passing 0 for amount"])
                                .to.be.true;
                            _b = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(pr.transfer("0x0000000000000000000000000000000000000000", 0, { from: king }))];
                        case 2:
                            _b.apply(void 0, [_d.sent(),
                                "Passing 0xasd for recipient"])
                                .to.be.true;
                            _c = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(pr.transfer(0, 0, { from: king }))];
                        case 3:
                            _c.apply(void 0, [_d.sent(),
                                "Passing 0 for recipient"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            it.only("Should correctly transfer funds to address", function () { return __awaiter(_this, void 0, void 0, function () {
                var balance;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            // Add funds to contract address
                            chai_1.expect(function () { return SendWei(joker, pr.address, amount); }, // send 1 ether
                            "Balance was not increased")
                                .to.increase(function () { return GetBalance(pr.address); }) // check balance
                                .by(amount);
                            balance = GetBalance(magpie);
                            return [4 /*yield*/, pr.transfer(magpie, amount, { from: king })];
                        case 1:
                            _a.sent();
                            return [4 /*yield*/, pr.transfer(magpie, amount, { from: queen })];
                        case 2:
                            _a.sent();
                            return [4 /*yield*/, pr.transfer(magpie, amount, { from: jack })];
                        case 3:
                            _a.sent();
                            chai_1.expect(GetBalance(magpie), "Transfer should've increase balance")
                                .to.equal(+balance + +amount);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
});
//# sourceMappingURL=testPreICO.js.map