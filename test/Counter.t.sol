// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MAGA.sol";
import "../circuits/contract/plonk_vk.sol";

contract MagaTest is Test {
    MAGA public attestationsContract;
    UltraVerifier public verifier;

    bytes proofBytes;

    function setUp() public {
        verifier = new UltraVerifier();
        
        string memory proof = vm.readLine("./circuits/proofs/p.proof");
        proofBytes = vm.parseBytes(proof);
    }

    function test_AddAttestation() public {
    }

    function test_Revert_InvalidProof() public {
        vm.expectRevert();
        bytes32[] memory inputs = new bytes32[](4);
        inputs[0] = merkleRoot;
        inputs[1] = bytes32(0);
        inputs[2] = bytes32(abi.encodePacked(uint(1)));
        inputs[3] = nullifierHash;
        verifier.verify(hex"01", inputs);
    }

    function test_Revert_DoubleVote() public {
        test_ValidVote();
        vm.expectRevert();
        voteContract.castVote(
            proofBytes,
            0, // proposal ID
            1, // vote in favor
            nullifierHash // nullifier hash
        );
    }
}
