let Quorum = artifacts.require("Quorum");
let ACTVote = artifacts.require("ACTVote");
let Proposal = artifacts.require("ProposalModule");

module.exports = function(deployer) 
{
    let owner = 0xb115997626d0bE91Ee4b17AAd8330eFC7506C009;
    let exchangeRate = 100;

    // function Quorum(address _owner) 
    Quorum.new(owner).then(function(quorumContract) 
    {
        console.log("Quorum Addr: " + quorumContract.address);
        
        //function ACTVote(address _owner, address _quorumAddr, address _proposalAddr, uint256 _exchangeRate)
        ACTVote.new(owner, quorumContract.address, owner, exchangeRate).then(function(actVoteContract)
        {
            console.log("ACTVote Addr: " + actVoteContract.address);

            //function ProposalModule(address _owner, address _actVoteAddr, address _quorumAddr)
            Proposal.new(owner, actVoteContract.address, quorumContract.address).then(function(proposalContract) 
            {
                console.log("Proposal Addr: " +proposalContract.address);
            })
        })    
    })
};
