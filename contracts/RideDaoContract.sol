// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RideDaoContract is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("RideDaoContract", "RIDO") {
        _mint(msg.sender, 50000000000000000000000000 * 18**decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 16;
    }

    mapping(address => uint256) balances;

    address payable[] recipients;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function invest() external payable {
        if (msg.value < 1 ether) {
            revert();
        }
        balances[msg.sender] += msg.value;
    }

    function burn(uint256 amount) public override onlyOwner {
        _burn(_msgSender(), amount);
    }

    function balanceOf1() external view returns (uint256) {
        return address(this).balance;
    }

    function transferToken(address payable recepient, uint256 _amount)
        external
    {
        recepient.transfer(_amount);
    }
}
