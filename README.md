# From Bricks to Bytes - RealEstate Tokenization 

The project title is : "From Bricks to Bytes"

The objective : Real-Estate Tokenization. 

We would like to create a marketplace where investors can buy shares (tokens) in order to get fractional ownership of real-estate. 

We developed a Factory smart contract : "PropertyTokenFactory" that will create a new instance of "PropertyToken" smart contract, each time it is needed to sell a new property.

The smart contract allows following main functionnalities : 
1- constructor() : mints token according to the specificities of the property. The money is stored in the smart contract (not in the deployer wallet). The smart contract works then as an escrow smart contract.
2- buyTokens() : allows to an investor to buy an amount of tokens from the property
3- transferTokens() : allows the investor to transfer their tokens from a wallet to another
4- sellTokens() & buyTokens_secondMarket() : this allows to initiate a sell/buy transaction between 2 investors : the seller is sending tokens to the smart contract, the buyer sends the money to the smart contract and then the latter sends the tokens to the buyer and sends funds (ETH) to the seller.
5- withdrawFunds(): the owner of the smart contract can withdraw funds from the smart contract to his own wallet, when the crowdfunding period is closed.
6- burn(): if needed, there may be a need to burn unneded tokens.
7- updatePropertyPrice() : the price of the property in ETH may be changed by owner only, if needed.

Unitary tests in TypeScript have been added in order to validate the smart contract behavior.
The unitary tests need to be enriched by more cases.
