var ProposalController = artifacts.require('./ProposalController.sol');
var Pool = artifacts.require('./Pool.sol');
var Curator = artifacts.require('./Curator.sol');
var ReputationGroup = artifacts.require('./ReputationGroup.sol');
var Quorum = artifacts.require('./Quorum.sol');
var CE7 = artifacts.require('./CE7.sol');

//migrate -f 3 to run only this migration
module.exports = function(deployer) {
    // CE7.new(function () {
    //     console.log('ok');
    // });
};