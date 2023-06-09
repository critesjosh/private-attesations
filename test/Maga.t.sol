// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Given the updated identifier generation based on pedersen hashes, testing
// might have to be done in typescript. The noir TS implementations should match
// the language implementions.

// TODO: check if this Solidity implementation of pedersen matches
// https://github.com/Kelvyne/starknet-storage-proof-solidity/blob/main/contracts/PedersenHash.sol

// I am keeping this file for reference.

import "forge-std/Test.sol";
import "../src/Maga.sol";
import "../circuits/contract/plonk_vk.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MagaTest is Test {
    using ECDSA for bytes32;
    
    Maga public attestationsContract;
    UltraVerifier public verifier;

    bytes proofBytes;

    uint256 user_private_key = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address user;
    bytes32[] identifiers;

    uint256 attester_private_key = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address attester;

    function setUp() public {
        verifier = new UltraVerifier();
        attestationsContract = new Maga(address(verifier));

        user = vm.addr(user_private_key);
        attester = vm.addr(attester_private_key);

        // make 10 identifiers
        for(uint i; i <10 ; i++){
            bytes memory message = abi.encodePacked("message nonce:", i);
            bytes32 digest = keccak256(message).toEthSignedMessageHash();
            (, bytes32 r, bytes32 s) = vm.sign(user_private_key, digest);
            // the signature that will be hashed in the circuit is just r, s
            bytes memory signature = bytes.concat(r, s);
            // need to update to use pedersen hashes
            // maybe foreign function util https://book.getfoundry.sh/cheatcodes/ffi?highlight=#ffi
            identifiers.push(sha256(signature));
        }

        // string memory proof = vm.readLine("./circuits/proofs/p.proof");
        // proofBytes = vm.parseBytes(proof);
    }

    function test_AddAttestation() public {
        bytes memory message = abi.encodePacked("I am attesting to", identifiers[0]);
        bytes32 digest = keccak256(message).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(attester_private_key, digest);
        // pack the attestions, message hash and signature together

        // digest is bytes 0-31
        // r is byte 32 - 63
        // s is byte 64 - 95
        // v is byte 96
        // message is the rest

        bytes memory attestation = abi.encodePacked(digest, r, s, v, message);
        attestationsContract.attest(identifiers[0], string(attestation));
        emit log_bytes32(digest);
        emit log_bytes(attestation);
    }
}
