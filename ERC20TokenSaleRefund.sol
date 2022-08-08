//SPDX License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSaleRefund is ERC20Capped, Ownable {
    uint rate;
   
    constructor(uint256 initialSupply) 
    ERC20("TokenSale", "TS") 
    ERC20Capped(1000000*10**18) // All mints capped to 1 mil tokens
    {
        _mint(msg.sender, initialSupply);
        rate = 500000000000000; // (0.5 / 1000) / 10^18 wei per token
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

    
    function sellBack(uint256 tokens, address from) external payable {
        // calculate amount of wei to give to sender
        // revert if contract doesnt have enough funds
        // check if user has enough tokens to send
        require(balanceOf(from) >= 1);
        uint256 amount = (rate * (tokens / 10**18));
        require(address(this).balance >= amount);

        transfer(address(this), tokens);
        payable(from).transfer(amount); // send appropriate eth amt
    }

    function withdraw() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

}