//SPDX License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is ERC20Capped, Ownable {
    using SafeMath for uint256;
   
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

        // Get tokens per wei passed in
        uint256 amount = 1000 * msg.value; 

        _mint(msg.sender, amount);
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}