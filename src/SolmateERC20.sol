// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20StorageLib} from "./ERC20StorageLib.sol";

/// @notice ERC20 implementation using externalized storage layout.
contract SolmateERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function name() public view virtual returns (string memory) {
        return ERC20StorageLib.get().name;
    }

    function symbol() public view virtual returns (string memory) {
        return ERC20StorageLib.get().symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return ERC20StorageLib.get().decimals;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function totalSupply() public view virtual returns (uint256) {
        return ERC20StorageLib.get().totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return ERC20StorageLib.get().balanceOf[account];
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return ERC20StorageLib.get().allowance[owner][spender];
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        s.allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        s.balanceOf[msg.sender] -= amount;

        unchecked {
            s.balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        uint256 allowed = s.allowance[from][msg.sender];

        if (allowed != type(uint256).max) s.allowance[from][msg.sender] = allowed - amount;

        s.balanceOf[from] -= amount;

        unchecked {
            s.balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                         INTERNAL MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 amount) external virtual {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        s.totalSupply += amount;

        unchecked {
            s.balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        return block.chainid == s.INITIAL_CHAIN_ID ? s.INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        ERC20StorageLib.ERC20Storage storage s = ERC20StorageLib.get();
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(s.name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }
}
