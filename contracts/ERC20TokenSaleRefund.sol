//SPDX License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSaleRefund is ERC20Capped, Ownable {
    uint256 private rate;

    constructor(uint256 initialSupply)
        ERC20("TokenSale", "TS")
        ERC20Capped(1_000_000 * 10**18) // All mints capped to 1 mil tokens
    {
        _mint(msg.sender, initialSupply);
        rate = 500_000_000_000_000; // (0.5 / 1000) / 10^18 wei per token
    }

    function mintTokens() external payable {
        // 1000 tokens per 1 eth, refund excess to user
        uint256 excess = msg.value % 10**18; // fractional porition
        uint256 amount = (msg.value / 10**18) * 10**18; // get integer value (Intentionally discarding numbers after decimal point)
        _mint(msg.sender, amount * 1000);

        if (excess != 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    function sellBack(uint256 tokens) external payable {
        // check if user has tokens to send
        require(balanceOf(msg.sender) >= 1, "You do not have any tokens to send!");

        // calculate amount of wei to give to sender
        uint256 amount = (rate * (tokens / 10**18));

        // revert if contract doesnt have enough funds
        require(address(this).balance >= amount, "Contract doesn't have enough Ether!");

        // transfer specified token amt to contract
        transfer(address(this), tokens);
        // send appropriate eth amt back
        payable(msg.sender).transfer(amount);
    }

    function withdraw() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
