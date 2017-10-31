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
var ACTToken = artifacts.require("./ACTToken.sol");
var GenericToken = artifacts.require("./GenericToken.sol");
var BigNumber = web3.BigNumber;
var chai_1 = require("chai");
var index_1 = require("./helpers/index");
var actToken = null; // ActToken instance
var gt = null; // Generic Token instance
var hardOwner = "0x1538ef80213cde339a333ee420a85c21905b1b2d";
var hardSupplyOwner = "0x244092a2FECFC48259cf810b63BA3B3c0B811DCe";
var name = "ACT Token";
var symbol = "ACT";
var decimals = 18;
var supply = 10e9 * 1e18; // 10 Billions + 18 decimals or 100 Octilions
var version = "v1.0.0";
function ReturnEventAndArgs(returnVal) {
    return { eventName: returnVal.logs[0].event,
        eventArgs: returnVal.logs[0].args.action,
        raw: returnVal };
}
var king, queen, jack, ace, joker, magpie;
contract("ACTToken", function (accounts) {
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
    describe("Initialize", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            it("Should init ACTToken", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c;
                return __generator(this, function (_d) {
                    switch (_d.label) {
                        case 0: return [4 /*yield*/, ACTToken.new(king, king)];
                        case 1:
                            actToken = _d.sent();
                            _a = chai_1.expect;
                            return [4 /*yield*/, actToken.owner()];
                        case 2:
                            _a.apply(void 0, [_d.sent(),
                                "Owners should match"])
                                .to.equal(king);
                            _b = chai_1.expect;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 3:
                            _b.apply(void 0, [(_d.sent()).toNumber(),
                                "Total supply should match"])
                                .to.equal(supply);
                            _c = chai_1.expect;
                            return [4 /*yield*/, actToken.balanceOf(king)];
                        case 4:
                            _c.apply(void 0, [(_d.sent()).toNumber(),
                                "Balance should equal to initial supply"])
                                .to.equal(supply);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should correctly init GenericToken for migration", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c;
                return __generator(this, function (_d) {
                    switch (_d.label) {
                        case 0: return [4 /*yield*/, GenericToken.new()];
                        case 1:
                            gt = _d.sent();
                            return [4 /*yield*/, ACTToken.new(king, king)];
                        case 2:
                            actToken = _d.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, gt.originalSupply()];
                        case 3:
                            _c = (_a = _b.apply(void 0, [(_d.sent()).toNumber(),
                                "Supplies should be equal"])
                                .to).equal;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 4:
                            _c.apply(_a, [(_d.sent()).toNumber()]);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("ACTToken transfers", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            beforeEach(function () { return __awaiter(_this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            king = accounts[0];
                            queen = accounts[1];
                            return [4 /*yield*/, ACTToken.new(king, king)];
                        case 1:
                            actToken = _a.sent();
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should return correct totalSupply after contstruction", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a;
                return __generator(this, function (_b) {
                    switch (_b.label) {
                        case 0:
                            _a = chai_1.expect;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 1:
                            _a.apply(void 0, [(_b.sent()).toNumber(),
                                "Total supply does not match"])
                                .to.equal(supply);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should return correct balances after transfer", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0: return [4 /*yield*/, actToken.transfer(queen, supply, { from: king })];
                        case 1:
                            _c.sent();
                            _a = chai_1.expect;
                            return [4 /*yield*/, actToken.balanceOf(king)];
                        case 2:
                            _a.apply(void 0, [(_c.sent()).toNumber(),
                                "Should be empty"])
                                .to.equal(0);
                            _b = chai_1.expect;
                            return [4 /*yield*/, actToken.balanceOf(queen)];
                        case 3:
                            _b.apply(void 0, [(_c.sent()).toNumber(),
                                "Should be lot of money"])
                                .to.equal(supply);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should throw when trying to transfer more than balance", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a;
                return __generator(this, function (_b) {
                    switch (_b.label) {
                        case 0:
                            console.log();
                            _a = chai_1.expect;
                            return [4 /*yield*/, index_1.expectThrow(actToken.transfer(queen, supply * 2, { from: king }))];
                        case 1:
                            _a.apply(void 0, [_b.sent(),
                                "Expected a throw"])
                                .to.be.true;
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
    describe("Migration", function () { return __awaiter(_this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            it("Should switch Upgrading on/off", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0: return [4 /*yield*/, ACTToken.new(king, king)];
                        case 1:
                            actToken = _c.sent();
                            _a = chai_1.expect;
                            return [4 /*yield*/, actToken.upgradingEnabled()];
                        case 2:
                            _a.apply(void 0, [_c.sent(),
                                "Upgrading should be off"])
                                .to.equal(false);
                            return [4 /*yield*/, actToken.tweakUpgrading({ from: king })];
                        case 3:
                            _c.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, actToken.upgradingEnabled()];
                        case 4:
                            _b.apply(void 0, [_c.sent(),
                                "Upgrading should be on"])
                                .to.equal(true);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should set Migration Agent", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, _d, _e, _f;
                return __generator(this, function (_g) {
                    switch (_g.label) {
                        case 0: return [4 /*yield*/, GenericToken.new()];
                        case 1:
                            gt = _g.sent();
                            return [4 /*yield*/, ACTToken.new(king, king)];
                        case 2:
                            actToken = _g.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, gt.originalSupply()];
                        case 3:
                            _c = (_a = _b.apply(void 0, [(_g.sent()).toNumber(),
                                "Supplies should be equal"])
                                .to).equal;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 4:
                            _c.apply(_a, [(_g.sent()).toNumber()]);
                            return [4 /*yield*/, actToken.tweakUpgrading({ from: king })];
                        case 5:
                            _g.sent();
                            _d = chai_1.expect;
                            return [4 /*yield*/, gt.isMigrationAgent.call()];
                        case 6:
                            _d.apply(void 0, [_g.sent(),
                                "Should be MigrationAgent"])
                                .to.be.true;
                            _e = chai_1.expect;
                            return [4 /*yield*/, actToken.upgradingEnabled()];
                        case 7:
                            _e.apply(void 0, [_g.sent(),
                                "Should be upgrading"])
                                .to.be.true;
                            return [4 /*yield*/, actToken.setMigrationAgent(gt.address)];
                        case 8:
                            _g.sent();
                            _f = chai_1.expect;
                            return [4 /*yield*/, actToken.migrationAgent()];
                        case 9:
                            _f.apply(void 0, [_g.sent(),
                                "Migration addresses should match"])
                                .to.equal(gt.address);
                            return [2 /*return*/];
                    }
                });
            }); });
            it("Should migrate", function () { return __awaiter(_this, void 0, void 0, function () {
                var _a, _b, _c, value, balanceOfKing, r, _d, _e, _f;
                return __generator(this, function (_g) {
                    switch (_g.label) {
                        case 0: return [4 /*yield*/, GenericToken.new()];
                        case 1:
                            gt = _g.sent();
                            return [4 /*yield*/, ACTToken.new(king, king)];
                        case 2:
                            actToken = _g.sent();
                            _b = chai_1.expect;
                            return [4 /*yield*/, gt.originalSupply()];
                        case 3:
                            _c = (_a = _b.apply(void 0, [(_g.sent()).toNumber(),
                                "Supplies should be equal"])
                                .to).equal;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 4:
                            _c.apply(_a, [(_g.sent()).toNumber()]);
                            return [4 /*yield*/, actToken.tweakUpgrading()];
                        case 5:
                            _g.sent();
                            return [4 /*yield*/, actToken.setMigrationAgent(gt.address)];
                        case 6:
                            _g.sent();
                            value = supply / 10;
                            return [4 /*yield*/, actToken.balanceOf(king)];
                        case 7:
                            balanceOfKing = (_g.sent()).toNumber();
                            _d = ReturnEventAndArgs;
                            return [4 /*yield*/, actToken.migrate(value)];
                        case 8:
                            r = _d.apply(void 0, [_g.sent()]);
                            chai_1.expect(r.eventName, "Event Migrate was not fired")
                                .to.be.equal("Migrate");
                            chai_1.expect(r.raw.logs[0].args._from, "Sender should be king")
                                .to.equal(king);
                            chai_1.expect(r.raw.logs[0].args._to, "To should be addres of new token")
                                .to.equal(gt.address);
                            chai_1.expect(r.raw.logs[0].args._value.toNumber(), "Value is incorrect")
                                .to.equal(value);
                            _e = chai_1.expect;
                            return [4 /*yield*/, actToken.balanceOf(king)];
                        case 9:
                            _e.apply(void 0, [(_g.sent()).toNumber(),
                                "Transfer was not correct"])
                                .to.equal(balanceOfKing - value);
                            _f = chai_1.expect;
                            return [4 /*yield*/, actToken.totalSupply()];
                        case 10:
                            _f.apply(void 0, [(_g.sent()).toNumber(),
                                "Supply should drop"])
                                .to.equal(supply - value);
                            return [2 /*return*/];
                    }
                });
            }); });
            return [2 /*return*/];
        });
    }); });
});
//# sourceMappingURL=ACTToken.js.map