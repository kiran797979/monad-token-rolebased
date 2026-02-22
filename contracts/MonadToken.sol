// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonadToken is ERC20, ERC20Burnable, Pausable, AccessControl, Ownable {
    bytes32 public constant MINTER_ROLE  = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE  = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE  = keccak256("PAUSER_ROLE");

    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        _mint(msg.sender, initialSupply);
        transferOwnership(msg.sender);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyRole(BURNER_ROLE) {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function grantMinter(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }
    function revokeMinter(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }

    function grantBurner(address account) external onlyOwner {
        grantRole(BURNER_ROLE, account);
    }
    function revokeBurner(address account) external onlyOwner {
        revokeRole(BURNER_ROLE, account);
    }

    function grantPauser(address account) external onlyOwner {
        grantRole(PAUSER_ROLE, account);
    }
    function revokePauser(address account) external onlyOwner {
        revokeRole(PAUSER_ROLE, account);
    }
}
