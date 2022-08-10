//SPDX License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sanctions is ERC20, Ownable {

    mapping(address => bool) public blacklist;

    constructor(uint256 initialSupply) ERC20("Sanctions", "Sanc") {
        _mint(msg.sender, initialSupply);
    }

    function addToBlacklist (address[] calldata toAdd) external onlyOwner {
        // add single or multiple items to blacklist
        for (uint i; i < toAdd.length; i++) {
            blacklist[toAdd[i]] = true;
        }
    }

    function removeFromBlacklist (address[] calldata toRemove) external onlyOwner {
       // remove single or multiple items from blacklist 
        for (uint i; i < toRemove.length; i++) {
            blacklist[toRemove[i]] = false;
        }       
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override view{
        require(!blacklist[from],
        "Recipient or Sender is blacklisted!"
        );
        require(!blacklist[to],
        "Recipient or Sender is blacklisted!"
        );
    }
}
