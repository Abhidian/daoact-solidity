
module.exports = {
  networks: {
    t: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },

    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 4000000
    },
    
    ropsten: {
      host: "localhost",
      port: 8585,
      network_id: "3",
      gas: 4000000
    }
  }
};
