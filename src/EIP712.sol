//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// EIP
contract EIP712 {

    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable _CHAIN_ID;
    address private immutable _CONTRACT;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    
    constructor(string memory name, string memory version) { 
        _HASHED_NAME = keccak256(bytes(name));
        _HASHED_VERSION = keccak256(bytes(version));
        _TYPE_HASH = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _CHAIN_ID = block.chainid;
        _CONTRACT = address(this);
        _DOMAIN_SEPARATOR = _buildDomainSeparator();
        
    }

    function _domainSeparator() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
    }

    function _buildDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _TYPE_HASH,
                    _HASHED_NAME,
                    _HASHED_VERSION,
                    _CHAIN_ID,
                    _CONTRACT
                )
            );
    }

}