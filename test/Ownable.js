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
var Ownable = artifacts.require("Ownable");
var index_1 = require("./helpers/index");
var chai_1 = require("chai");
contract("Ownable", function (accounts) {
    var ow; // Ownable contract
    var king = accounts[0];
    beforeEach(function () { return __awaiter(_this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, Ownable.new({ from: king })];
                case 1:
                    ow = _a.sent();
                    return [2 /*return*/];
            }
        });
    }); });
    it("Should initialize", function () { return __awaiter(_this, void 0, void 0, function () {
        var owner;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, Ownable.new()];
                case 1:
                    owner = _a.sent();
                    chai_1.expect(owner !== 0).to.be.true;
                    return [2 /*return*/];
            }
        });
    }); });
    it("Correct owner", function () { return __awaiter(_this, void 0, void 0, function () {
        var _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0:
                    _a = chai_1.expect;
                    return [4 /*yield*/, ow.owner()];
                case 1:
                    _a.apply(void 0, [_b.sent(), "Owner is incorrect"])
                        .to.equal(king);
                    return [2 /*return*/];
            }
        });
    }); });
    it("Should prevent non-owners from transfering", function () { return __awaiter(_this, void 0, void 0, function () {
        var owner, loser, _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, ow.owner.call()];
                case 1:
                    owner = _b.sent();
                    loser = accounts[1];
                    _a = chai_1.expect;
                    return [4 /*yield*/, (index_1.expectThrow(ow.transferOwnership(loser, { from: loser })))];
                case 2:
                    _a.apply(void 0, [_b.sent(),
                        "Should throw"])
                        .to.be.true;
                    return [2 /*return*/];
            }
        });
    }); });
    it("Should not allow transfer to 0", function () { return __awaiter(_this, void 0, void 0, function () {
        var owner, _a;
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, ow.owner.call()];
                case 1:
                    owner = _b.sent();
                    _a = chai_1.expect;
                    return [4 /*yield*/, (index_1.expectThrow(ow.transferOwnership(0, { from: owner })))];
                case 2:
                    _a.apply(void 0, [_b.sent(),
                        "Should throw"])
                        .to.be.true;
                    return [2 /*return*/];
            }
        });
    }); });
});
//# sourceMappingURL=Ownable.js.map