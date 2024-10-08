// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address public owner;

    // Modified constructor to accept name, symbol, and decimals
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        owner = msg.sender;

        // Mint the initial supply of tokens to the owner
        _mint(msg.sender, _initialSupply * 10 ** uint256(_decimals));
    }
    
    function mint(uint256 _amount) external {
        require(msg.sender == owner, "You are not the owner");
        _mint(msg.sender, _amount * 10 ** decimals());
    }


   
    
}
