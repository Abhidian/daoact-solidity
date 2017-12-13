var ProposalController = artifacts.require('./ProposalController.sol');
var Pool = artifacts.require('./Pool.sol');
var Curator = artifacts.require('./Curator.sol');
var ReputationGroup = artifacts.require('./ReputationGroup.sol');
var Quorum = artifacts.require('./Quorum.sol');
var CE7mock = artifacts.require('./CE7mock.sol');

//migrate -f 4 to run only this migration
module.exports = function(deployer) {
    CE7mock.new(function () {
        console.log('ok');
    });
};