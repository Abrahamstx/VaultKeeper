# VaultKeeper 🔐

A decentralized escrow service built on Stacks blockchain for secure peer-to-peer transactions.

## Overview

VaultKeeper enables users to create secure escrow agreements where funds are held in a smart contract until transaction conditions are met. This eliminates the need for trusted third parties in peer-to-peer transactions.

## Features

- **Secure Escrow Creation**: Buyers can create escrow agreements with sellers
- **Trustless Transactions**: Smart contract holds funds until release conditions are met
- **Buyer Protection**: Buyers can release funds once satisfied with goods/services
- **Seller Protection**: Sellers can initiate refunds if buyers are unresponsive
- **Transparent Process**: All escrow states are publicly verifiable on-chain

## Smart Contract Functions

### Read-Only Functions
- `get-escrow(escrow-id)` - Retrieve escrow details by ID
- `get-next-escrow-id()` - Get the next available escrow ID
- `get-contract-owner()` - Get contract owner address

### Public Functions
- `create-escrow(seller, amount)` - Create new escrow agreement
- `release-escrow(escrow-id)` - Release funds to seller (buyer only)
- `refund-escrow(escrow-id)` - Refund funds to buyer (seller only)

## Escrow Status Codes

- `1` - Active (funds locked in escrow)
- `2` - Released (funds sent to seller)
- `3` - Refunded (funds returned to buyer)

## Usage

1. **Create Escrow**: Buyer calls `create-escrow` with seller address and STX amount
2. **Complete Transaction**: Buyer and seller complete their off-chain agreement
3. **Release Funds**: Buyer calls `release-escrow` to send funds to seller
4. **Alternative**: Seller can call `refund-escrow` if needed

## Security Features

- Funds are locked in the contract until explicitly released
- Only authorized parties can trigger releases or refunds
- All state changes are immutable and verifiable

## Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/vaultkeeper.git

# Install dependencies
cd vaultkeeper
npm install

# Check contract
clarinet check

# Run tests
clarinet test
```

