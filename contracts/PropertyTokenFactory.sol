// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.9;
pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 
import "./PropertyToken.sol";

contract PropertyTokenFactory {
    mapping(string => PropertyToken) public propertyTokens;

    function createPropertyToken(
        string memory symbol,

        string memory name,
        uint256 price_in_ETH,
        uint256 totalTokens,
        string memory official_docs_link
    ) public {
        require(propertyTokens[name] == PropertyToken(address(0)), "Token already exists");
        PropertyToken newPropertyToken = new PropertyToken(
        name,
        symbol,
        price_in_ETH,
        totalTokens,
        official_docs_link
    );
        propertyTokens[name] = newPropertyToken;
    }
}