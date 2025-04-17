// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Library for accessing ERC20 storage via fixed slot.
library ERC20StorageLib {
    bytes32 internal constant STORAGE_SLOT = keccak256("storaged.solmate.erc20");

    struct ERC20Storage {
        string name;
        string symbol;
        uint8 decimals;

        uint256 totalSupply;
        mapping(address => uint256) balanceOf;
        mapping(address => mapping(address => uint256)) allowance;

        uint256 INITIAL_CHAIN_ID;
        bytes32 INITIAL_DOMAIN_SEPARATOR;
        mapping(address => uint256) nonces;
    }

    function get() internal pure returns (ERC20Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }
} 