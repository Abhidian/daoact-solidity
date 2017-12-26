let ProposalController = artifacts.require('./ProposalController.sol');
let Pool = artifacts.require('./Pool.sol');
let Curator = artifacts.require('./Curator.sol');
let ReputationGroup = artifacts.require('./ReputationGroup.sol');
let Quorum = artifacts.require('./Quorum.sol');
let CE7mock = artifacts.require('./CE7mock.sol');
let Vote = artifacts.require('./Vote.sol');

//migrate -f 4 to run only this migration
module.exports = function(deployer) {

    const ce7 = async () => {
        try {
            return CE7mock.new();
        } catch (err) {
            console.log(err);
        }
    };
    const propControl = async () => {
        try {
            return ProposalController.new();
        } catch (err) {
            console.log(err);
        }
    };
    const quorum = async () => {
        try {
            return Quorum.new();
        } catch (err) {
            console.log(err);
        }
    };
    const reputation = async () => {
        try {
            return ReputationGroup.new();
        } catch (err) {
            console.log(err);
        }
    };
    const vote = async etherPrice => {
        try {
            return Vote.new(etherPrice);
        } catch (err) {
            console.log(err);
        }
    };
    const pool = async (proposal, vote, curator, foundation, dao) => {
        try {
            return Pool.new(proposal, vote, curator, foundation, dao);
        } catch (err) {
            console.log(err);
        }
    };
    const curator = async (token, reputation) => {
        try {
            return Curator.new();
        } catch (err) {
            console.log(err);
        }
    };
    const migrate = async () => {
        try {
            // let token = await ce7();
            // console.log(token);
            // let proposal = await  propControl();
            // console.log(proposal);
            // let quorumContr = await quorum();
            // console.log(quorumContr);
            // let reput = await reputation();
            // console.log(reput);
            // let voteContr = await vote(45000);
            // console.log(voteContr);
            // let curat = await curator("0x1", "0x5");
            // console.log(curat);
            let poolContr = await pool();
            console.log(poolContr);

        } catch (err) {
            console.log(err);
        }
    };
    migrate();
};