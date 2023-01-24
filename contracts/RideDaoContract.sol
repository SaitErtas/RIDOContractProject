// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RideDaoContract is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public FEE_RATIO_CHANGER_ROLE = keccak256("VARIABLE_CHANGER_ROLE");

    uint256 public _feeRatio; //State variable

    constructor() ERC20("RideDao", "RIDO") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(FEE_RATIO_CHANGER_ROLE, msg.sender);

        _mint(msg.sender, 50000000000000000000000000 * 18**decimals());
        _feeRatio = 0;
        grantRole(PAUSER_ROLE, 0x13C2870c285B2F2f5831E53700b4E5E139e73596);
        grantRole(PAUSER_ROLE, 0x668F723e961aab7089Ce61fB90989f7Bac49Bb5b);

        grantRole(
            FEE_RATIO_CHANGER_ROLE,
            0x13C2870c285B2F2f5831E53700b4E5E139e73596
        );
        grantRole(
            FEE_RATIO_CHANGER_ROLE,
            0x668F723e961aab7089Ce61fB90989f7Bac49Bb5b
        );
    }

    mapping(address => bool) _blacklist;
    event BlacklistUpdated(address indexed user, bool value);

    mapping(address => uint256) balances;

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) whenNotPaused {
        require(
            !isBlackListed(to),
            "Token transfer refused. Receiver is on the blacklist"
        );
        require(
            !isBlackListed(from),
            "Token transfer refused. You are on the blacklist"
        );
        super._beforeTokenTransfer(from, to, amount);
    }

    function burn(uint256 amount) public override onlyRole(PAUSER_ROLE) {
        _burn(_msgSender(), amount);
    }

    function transferToken(address payable recepient, uint256 _amount)
        external
    {
        _amount -= _amount * (_feeRatio / 100);
        recepient.transfer(_amount);
    }

    function setFeeRatio(uint256 feeRatio)
        public
        virtual
        onlyRole(FEE_RATIO_CHANGER_ROLE)
    {
        //require(_checkRole(FEE_RATIO_CHANGER_ROLE,sender.address), "Only authorized user is allowed to modify fee ration.");

        _feeRatio = feeRatio;
    }

    function getFeeRatio() public view returns (uint256) {
        return _feeRatio;
    }

    function blacklistUpdate(address user, bool value)
        public
        virtual
        onlyRole(PAUSER_ROLE)
    {
        // require(_owner == _msgSender(), "Only owner is allowed to modify blacklist.");
        _blacklist[user] = value;
        emit BlacklistUpdated(user, value);
    }

    function isBlackListed(address user) public view returns (bool) {
        return _blacklist[user];
    }
}
