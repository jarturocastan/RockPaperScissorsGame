// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Wrapped is ERC20{
    constructor()  ERC20("Wrapped ", "W") {}

    function deposit(uint256 amount) public payable {
        require(amount == msg.value);
        _mint(msg.sender, msg.value);
    }
}