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

    function nonces(address owner) public view virtual returns (uint256) {
        return ERC20StorageLib.get().nonces[owner];
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
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        $.allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        $.balanceOf[msg.sender] -= amount;

        unchecked {
            $.balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        uint256 allowed = $.allowance[from][msg.sender];

        if (allowed != type(uint256).max) $.allowance[from][msg.sender] = allowed - amount;

        $.balanceOf[from] -= amount;

        unchecked {
            $.balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                         MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 amount) public virtual {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        $.balanceOf[to] += amount;
        $.totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) public virtual {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();

        $.balanceOf[from] -= amount;
        $.totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();

        require(block.timestamp <= deadline, "PERMIT_DEADLINE_EXPIRED");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        value,
                        $.nonces[owner]++,
                        deadline
                    )
                )
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_PERMIT_SIGNATURE");

        $.allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        return block.chainid == $.INITIAL_CHAIN_ID ? $.INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        ERC20StorageLib.ERC20Storage storage $ = ERC20StorageLib.get();
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes($.name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }
}
