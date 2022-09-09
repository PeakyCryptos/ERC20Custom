//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodMode is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("GodMode", "GOD") {
        // mint an initial specified amount of tokens to deployer
        _mint(msg.sender, initialSupply);
    }

    function mintTokensToAddress(address _recipient, uint256 _amount)
        external
        onlyOwner
    {
        // mints to specified address any amount of tokens
        _mint(_recipient, _amount);
    }

    function changeBalanceAtAddress(address _target, uint256 _amount)
        external
        onlyOwner
    {
        uint256 targetBalance = balanceOf(_target);
        if (_amount > targetBalance) {
            // if target has less tokens than specified amount mint excess
            _mint(_target, _amount - targetBalance);
        } else if (_amount < targetBalance) {
            // if targest has more tokens than specified burn excess
            _burn(_target, targetBalance - _amount);
        }
    }

    function authoritativeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external onlyOwner {
        // _transfer call has checks to ensure 
        // sender has appropriate amount of funds
        _transfer(from, to, amount);
    }
}