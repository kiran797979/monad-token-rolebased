# MonadToken

## Project Title

**MonadToken - Role-Based Access Controlled ERC20 Token on Monad Testnet**

A production-ready ERC20 token implementation built on OpenZeppelin contracts with comprehensive role-based access control, ownership management, and pausable functionality. Deployed on the Monad Testnet.

---

## 1. Overview

MonadToken is an ERC20-compliant fungible token that implements enterprise-grade access control mechanisms using OpenZeppelin's battle-tested security contracts. The token incorporates three distinct authorization patterns:

- **AccessControl**: Role-based permissions with granular function access
- **Ownable**: Single-owner administrative functions for streamlined management
- **Pausable**: Emergency stop mechanism for transfer halting

The contract follows the principle of least privilege by restricting sensitive operations to specific role holders while providing convenient owner wrappers for simplified administration.

---

## 2. Features

| Feature | Description |
|---------|-------------|
| ERC20 Standard | Full compliance with EIP-20 token standard |
| Role-Based Access Control | Three custom roles for minting, burning, and pausing |
| Owner Functions | Convenience wrappers for role management |
| Pausable Transfers | Emergency stop capability for all token transfers |
| Burnable | Token burning with allowance-based burnFrom |
| Initial Supply | Constructor mints initial supply to deployer |
| OpenZeppelin Integration | Uses audited, production-ready contracts |

---

## 3. Role-Based Access Control Explanation

### 3.1 Role Definitions

The contract defines three custom roles using OpenZeppelin's `AccessControl`:

```
MINTER_ROLE  = keccak256("MINTER_ROLE")
BURNER_ROLE  = keccak256("BURNER_ROLE")
PAUSER_ROLE  = keccak256("PAUSER_ROLE")
```

### 3.2 Role Permissions Matrix

| Role | Function Access | Description |
|------|-----------------|-------------|
| `MINTER_ROLE` | `mint(address to, uint256 amount)` | Create new tokens and assign to any address |
| `BURNER_ROLE` | `burnFrom(address account, uint256 amount)` | Burn tokens from any account (requires allowance) |
| `PAUSER_ROLE` | `pause()`, `unpause()` | Toggle transfer pause state |
| `DEFAULT_ADMIN_ROLE` | `grantRole()`, `revokeRole()` | Manage all role assignments |

### 3.3 Role Assignment Flow

1. Deployer receives all roles plus `DEFAULT_ADMIN_ROLE` upon deployment
2. `DEFAULT_ADMIN_ROLE` holders can grant/revoke any role via `grantRole()` / `revokeRole()`
3. Contract owner can use convenience functions (`grantMinter`, `revokeMinter`, etc.) for simpler role management

### 3.4 Owner Wrappers

The contract provides owner-only functions that internally call AccessControl methods:

```solidity
grantMinter(address) / revokeMinter(address)
grantBurner(address) / revokeBurner(address)
grantPauser(address) / revokePauser(address)
```

These functions emit standard `RoleGranted` and `RoleRevoked` events for full transparency.

---

## 4. Smart Contract Architecture

### 4.1 Inheritance Hierarchy

```
MonadToken
    |
    +-- ERC20 (base token functionality)
    +-- ERC20Burnable (burn + burnFrom)
    +-- Pausable (pause/unpause hooks)
    +-- AccessControl (role management)
    +-- Ownable (single-owner functions)
```

### 4.2 Key Functions

| Function | Visibility | Modifier | Description |
|----------|------------|----------|-------------|
| `constructor` | Public | - | Initializes token, grants roles, mints initial supply |
| `mint` | External | `onlyRole(MINTER_ROLE)` | Creates new tokens |
| `burnFrom` | Public | `onlyRole(BURNER_ROLE)` | Burns tokens with allowance check |
| `pause` | External | `onlyRole(PAUSER_ROLE)` | Halts all transfers |
| `unpause` | External | `onlyRole(PAUSER_ROLE)` | Resumes transfers |
| `grantMinter` | External | `onlyOwner` | Grants MINTER_ROLE |
| `revokeMinter` | External | `onlyOwner` | Revokes MINTER_ROLE |
| `grantBurner` | External | `onlyOwner` | Grants BURNER_ROLE |
| `revokeBurner` | External | `onlyOwner` | Revokes BURNER_ROLE |
| `grantPauser` | External | `onlyOwner` | Grants PAUSER_ROLE |
| `revokePauser` | External | `onlyOwner` | Revokes PAUSER_ROLE |

### 4.3 Constructor Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `string memory` | Token display name |
| `symbol` | `string memory` | Token ticker symbol |
| `initialSupply` | `uint256` | Initial tokens minted to deployer (in wei) |

---

## 5. Security Design

### 5.1 Access Control Patterns

**Role-Based Authorization**: Each sensitive function is protected by a specific role, ensuring that only authorized addresses can execute critical operations.

**Multi-Signature Readiness**: The contract supports separating duties - different addresses can hold different roles, enabling secure operational workflows.

**Owner Convenience Layer**: Owner-only wrappers provide a simplified administrative interface while maintaining the underlying AccessControl event emission for audit trails.

### 5.2 Pausable Mechanism

The `_beforeTokenTransfer` hook is overridden to check the paused state:

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20)
    whenNotPaused
{
    super._beforeTokenTransfer(from, to, amount);
}
```

This ensures that `transfer`, `transferFrom`, `mint`, and `burn` operations are blocked when paused.

### 5.3 BurnFrom Authorization

The `burnFrom` function requires two authorization checks:

1. Caller must have `BURNER_ROLE`
2. Caller must have sufficient allowance from the account being burned

```solidity
function burnFrom(address account, uint256 amount) 
    public 
    override 
    onlyRole(BURNER_ROLE) 
{
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
}
```

### 5.4 Security Considerations

- Deployer private key should be stored securely
- Consider using hardware wallets for production deployments
- Role assignments should follow the principle of least privilege
- The `DEFAULT_ADMIN_ROLE` can grant any role - protect this carefully
- Owner can bypass role checks via wrapper functions - secure the owner account

---

## 6. Deployment Instructions

### 6.1 Prerequisites

- Node.js v16 or higher
- npm or yarn package manager
- Private key with MONAD testnet tokens for gas fees

### 6.2 Step-by-Step Deployment

**Step 1: Clone or Create Project Directory**

```bash
mkdir monad-token-rolebased
cd monad-token-rolebased
```

**Step 2: Initialize Project**

```bash
npm init -y
```

**Step 3: Install Dependencies**

```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts dotenv
```

**Step 4: Configure Hardhat**

Create `hardhat.config.js` with Monad network configuration:

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    monad: {
      url: process.env.MONAD_RPC_URL || "https://testnet-rpc.monad.xyz/",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  }
};
```

**Step 5: Create Environment File**

Create `.env` file:

```
MONAD_RPC_URL=https://testnet-rpc.monad.xyz/
PRIVATE_KEY=0xYourPrivateKeyHere
```

**Step 6: Compile Contract**

```bash
npx hardhat compile
```

**Step 7: Deploy to Monad Testnet**

```bash
npx hardhat run --network monad scripts/deploy.js
```

### 6.3 Expected Output

```
Deploying with: 0xeC0907EC536317d22b188e2acb22cB6c232fA243
MonadToken deployed to: 0xd49FD4d59baF264970E38aEe98D02B55F4D63a58
Owner (deployer): 0xeC0907EC536317d22b188e2acb22cB6c232fA243
Explorer link: https://testnet.monadvision.com/address/0xd49FD4d59baF264970E38aEe98D02B55F4D63a58
```

---

## 7. Deployment Proof

Contract Name: MonadToken  
Standard: ERC20 (OpenZeppelin)  
Network: Monad Testnet  

Contract Address:
0xd49FD4d59baF264970E38aEe98D02B55F4D63a58  

Explorer Link:
https://testnet.monadvision.com/address/0xd49FD4d59baF264970E38aEe98D02B55F4D63a58

### 7.1 Deployment Details

| Parameter | Value |
|-----------|-------|
| Network | Monad Testnet |
| Contract Address | `0xd49FD4d59baF264970E38aEe98D02B55F4D63a58` |
| Deployer Address | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |
| Token Name | MonadToken |
| Token Symbol | MONAD |
| Initial Supply | 1,000,000 MONAD (10^24 wei) |
| Solidity Version | ^0.8.20 |
| Block Explorer | https://testnet.monadvision.com/address/0xd49FD4d59baF264970E38aEe98D02B55F4D63a58 |

### 7.2 Constructor Arguments

```
name: "MonadToken"
symbol: "MONAD"
initialSupply: 1000000000000000000000000 (1,000,000 * 10^18)
```

### 7.3 Initial Role Assignments

| Role | Holder |
|------|--------|
| DEFAULT_ADMIN_ROLE | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |
| MINTER_ROLE | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |
| BURNER_ROLE | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |
| PAUSER_ROLE | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |
| Owner | `0xeC0907EC536317d22b188e2acb22cB6c232fA243` |

---

## 8. How to Test Roles Using Hardhat Console

### 8.1 Launch Hardhat Console

```bash
npx hardhat console --network monad
```

### 8.2 Connect to Deployed Contract

```javascript
const tokenAddress = "0xd49FD4d59baF264970E38aEe98D02B55F4D63a58";
const MonadToken = await ethers.getContractFactory("MonadToken");
const token = MonadToken.attach(tokenAddress);
const [deployer, user1, user2] = await ethers.getSigners();
```

### 8.3 Check Role Constants

```javascript
const MINTER_ROLE = await token.MINTER_ROLE();
const BURNER_ROLE = await token.BURNER_ROLE();
const PAUSER_ROLE = await token.PAUSER_ROLE();
const DEFAULT_ADMIN_ROLE = await token.DEFAULT_ADMIN_ROLE();
```

### 8.4 Check Role Assignments

```javascript
// Check if deployer has MINTER_ROLE
await token.hasRole(MINTER_ROLE, deployer.address);
// Output: true

// Check if user1 has MINTER_ROLE
await token.hasRole(MINTER_ROLE, user1.address);
// Output: false
```

### 8.5 Test Minting

```javascript
// Mint tokens (deployer has MINTER_ROLE)
await token.mint(user1.address, ethers.parseUnits("1000", 18));

// Check balance
await token.balanceOf(user1.address);
// Output: 1000000000000000000000n (1000 tokens)
```

### 8.6 Test Pause/Unpause

```javascript
// Pause transfers
await token.pause();

// Try to transfer (should fail)
await token.connect(user1).transfer(user2.address, 100);
// Error: ERC20Pausable: token transfer while paused

// Unpause
await token.unpause();

// Transfer now works
await token.connect(user1).transfer(user2.address, 100);
```

### 8.7 Grant Role to Another Address

```javascript
// Grant MINTER_ROLE to user1 (owner only)
await token.grantMinter(user1.address);

// Verify role granted
await token.hasRole(MINTER_ROLE, user1.address);
// Output: true

// user1 can now mint
await token.connect(user1).mint(user2.address, ethers.parseUnits("500", 18));
```

### 8.8 Revoke Role

```javascript
// Revoke MINTER_ROLE from user1
await token.revokeMinter(user1.address);

// Verify role revoked
await token.hasRole(MINTER_ROLE, user1.address);
// Output: false
```

---

## 9. Folder Structure

```
monad-token-rolebased/
|
+-- contracts/
|   +-- MonadToken.sol          # Main ERC20 token contract
|
+-- scripts/
|   +-- deploy.js               # Deployment script for Monad network
|
+-- test/                       # Test files (to be added)
|
+-- artifacts/                  # Compiled contract artifacts (generated)
|
+-- cache/                      # Hardhat cache (generated)
|
+-- node_modules/               # Dependencies (generated)
|
+-- .env                        # Environment variables (private key, RPC URL)
+-- .env.example                # Example environment file
+-- .gitignore                  # Git ignore patterns
+-- hardhat.config.js           # Hardhat configuration
+-- package.json                # Project dependencies and scripts
+-- README.md                   # Project documentation
```

---

## 10. Technology Stack

| Component | Technology |
|-----------|------------|
| Smart Contract Language | Solidity ^0.8.20 |
| Development Framework | Hardhat v2.16.0 |
| Contract Library | OpenZeppelin Contracts v4.9.3 |
| Target Network | Monad Testnet |
| RPC Endpoint | https://testnet-rpc.monad.xyz/ |
| Block Explorer | https://explorer.monad.xyz/ |

---

## 11. License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 12. Conclusion

MonadToken successfully demonstrates the implementation of a production-ready ERC20 token with comprehensive role-based access control. The contract leverages OpenZeppelin's audited contracts to provide secure, battle-tested functionality.

### Key Achievements

- Implemented ERC20 standard with burnable and pausable extensions
- Established granular access control with three distinct roles
- Provided owner convenience functions for simplified administration
- Successfully deployed to Monad Testnet with verified functionality
- Maintained security best practices throughout the implementation

### Contract Verification

The deployed contract can be viewed on the Monad Block Explorer:

**https://testnet.monadvision.com/address/0xd49FD4d59baF264970E38aEe98D02B55F4D63a58**

### Future Enhancements

- Add comprehensive unit tests using Hardhat/Chai
- Implement role-based timelock for sensitive operations
- Add token vesting functionality
- Implement snapshot functionality for governance
- Add EIP-2612 permit functionality for gasless approvals

---

**Document Version**: 1.0  
**Last Updated**: February 2026  
**Author**: MonadToken Development Team
