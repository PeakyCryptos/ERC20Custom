//SPDX License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is ERC20Capped, Ownable {
    constructor(uint256 initialSupply) 
    ERC20("TokenSale", "TS") 
    ERC20Capped(1000000*10**18) // All mints capped to 1 mil tokens
    {
        _mint(msg.sender, initialSupply);
    }

    function mintTokens() external payable {
        // Check if total supply already reached 
        uint256 totalSupply = totalSupply();
        require(totalSupply < 1000000 * 10**18);

        // 1000 tokens per 1 eth, refund excess to user
        uint256 excess = msg.value % 10**18; // fractional porition
        uint256 amount = (msg.value / 10**18) * 10**18; // get integer value
        _mint(msg.sender, amount * 1000);

        if (excess != 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    function withdraw() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}