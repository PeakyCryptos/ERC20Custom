//SPDX License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sanctions is ERC20, Ownable {

    mapping(address => bool) private blacklist;

    constructor(uint256 initialSupply) ERC20("Sanctions", "Sanc") {
        _mint(msg.sender, initialSupply);
    }

    function addToBlacklist (address[] memory toAdd) external onlyOwner {
        // add single or multiple items to blacklist
        for (uint i; i < toAdd.length; i++) {
            blacklist[toAdd[i]] = true;
        }
    }

    function removeFromBlacklist (address[] memory toRemove) external onlyOwner {
       // remove single or multiple items to blacklist 
        for (uint i; i < toRemove.length; i++) {
            blacklist[toRemove[i]] = false;
        }       
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override view{
        require(
            !blacklist[from] && !blacklist[to],
            "Recipient or Sender is blacklisted!"
        );
    }
}