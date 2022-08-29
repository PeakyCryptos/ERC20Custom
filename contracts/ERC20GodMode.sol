//SPDX License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodMode is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("GodMode", "GOD") {
        _mint(msg.sender, initialSupply);
    }

    function mintTokensToAddress(address recipient, uint256 amount)
        external
        onlyOwner
    {
        _mint(recipient, amount);
    }

    function changeBalanceAtAddress(address target, uint256 amount)
        external
        onlyOwner
    {
        uint256 targetBalance = balanceOf(target);

        if (amount > targetBalance) {
            // if amount > target.balance then mint to address
            _mint(target, amount - targetBalance);
        } else if (amount < targetBalance) {
            // if amount < target.balance then burn from address
            require(
                amount < targetBalance,
                "Contract doesn't have enough tokens to fulfill this request!"
            );
            _burn(target, targetBalance - amount);
        }
    }

    function authoritativeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external onlyOwner {
        _transfer(from, to, amount);
    }
}