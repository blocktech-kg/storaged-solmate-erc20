# Storaged Solmate ERC20

This is a minimalistic, storage-separated implementation of Solmate-style ERC20, built to support upgradable contracts.

## Motivation

The goal of this repository is to provide a lightweight and elegant ERC20 base contract that:

- Enables clean and modular access to state via storage libraries.
- Is ready to be inherited in upgradable smart contracts (e.g. UUPS/Transparent Proxy).
- Avoids storage collisions by isolating state via fixed storage slots.
- Preserves Solmate’s ethos: minimal, gas-efficient, and readable.

## Architecture

The state of the ERC20 contract is extracted to `ERC20StorageLib`, which accesses a fixed keccak256-based slot. This allows safe reuse across contract upgrades and multiple modules.

