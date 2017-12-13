var ProposalController = artifacts.require('./ProposalController.sol');
var Pool = artifacts.require('./Pool.sol');
var Curator = artifacts.require('./Curator.sol');
var ReputationGroup = artifacts.require('./ReputationGroup.sol');
var Quorum = artifacts.require('./Quorum.sol');
var CE7mock = artifacts.require('./CE7mock.sol');
var Vote = artifacts.require('./Vote.sol');

//migrate -f 4 to run only this migration
module.exports = function(deployer) {

    var foundationAddress = 0x01;
    var daoactLTDAddress = 0x01;

    CE7mock.new().then(function(ce7Contract) {
        console.log('CE7 contract address: ', ce7Contract.address);

        ProposalController.new().then(function(proposalController) {
            //SET vote contract address MANUALY!
            console.log('Proposal contract address: ', proposalController.address);
            
            Quorum.new().then(function(quorumContract) {
                //SET pool contract address MANUALY!
                console.log('Quorum contract address: ', quorumContract.address);

                ReputationGroup.new().then(function(reputationContract) {
                    //SET Curator contract address MANUALY!
                    console.log('Reputation contract address: ', reputationContract.address);

                    Vote.new(quorumContract.address, proposalController.address, 65000).then(function(voteContract) {
                        //last argument is ETH price in USD, multiplied by 100. It should be uint value!
                        console.log('Vote contract address: ', voteContract.address);

                        Pool.new(proposalController.address, voteContract.address, quorumContract.address, foundationAddress, daoactLTDAddress). then(function(poolContract) {
                            //SET Curator contract address MANUALY!
                            console.log('Pool contract address: ', poolContract.address);

                            Curator.new(proposalController.address, ce7Contract.address, reputationContract.address, poolContract.address).then(function(curatorContract) {
                                console.log('Curator contract address: ', curatorContract.address);
                                console.log('ALL CONTRACT DEPLOYED! Set required addresses!');
                            });
                        });
                    });
                });
            });
        });

    });
};