# DAOACT Contract Deployment

DAOACT is splitted into multiple contracts so each contract have some interaface functions   
depends upon the address of interfaced contract. Therefor it is necessary to deploy these   
contracts in a specific order.    

## ACTToken contract
First of all deploye the ACTToken contract and note its address.   

## ACTION contract
Deploy the ACTION token contract and note its address.    

## Exchnage contract
Provide the address of ACTToken and ACTION contract in the constructor of Exchange contract    
and provide vesting time in months and deploy this contract.    

After deployment of above 3 contracts now note the address of Exchange contract and update   
the address of Exchange contract in ACTToken and ACTION contract by calling     
`updateExchangeAddress()` funcions.       
Now Token contracts are linked with exchange so user can exchange between ACT and ACTION.   

In order to exchange ACT to ACTION user will call `vestACT()` function of exchange contract    
by passing argument number of ACT tokens he or she want to vest. In return user ACTION     
balance will be updated according to exchange rate and an event will be broadcasted with 
some vest ID and other information. So when user try to exchange back ACTION to ACT then he or she have to provide that event information to `releaseACT` function.
Exchange of ACTION to ACT happen on the basis of age of vesting.


# Contract deployed on Rinkeby testnet
ACTIONToken: 0x784ec93f575c2206539a413eab93b9b737434d01
ACTToken: 0x39191e329b23d7054802acb69f87ee6d46795d2f
Exchange: 0xdcf44ac47d325ed758048dc68361abe61de21faf