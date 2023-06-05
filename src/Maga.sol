// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UltraVerifier} from '../circuits/contract/plonk_vk.sol';

contract Maga {
    
    UltraVerifier verifier;


    struct Attestation {
        string data;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    
    // identifier => attestation
    mapping(bytes32 => Attestation[]) attestations;
    
    constructor(address _verifier){
        verifier = UltraVerifier(_verifier);
    }

    // _identifier is the message_hash used in the circuit
    function attest(bytes32 _identifier, Attestation memory _a) public {
        attestations[_identifier].push(_a);
    }

    // _publicInputs[0] - _indentifier
    function verifyAttestation(
        bytes memory _proof, 
        bytes32[] memory _publicInputs, 
        uint _attestationIndex) 
        public
        view
        returns (Attestation memory) {
            verifier.verify(_proof, _publicInputs);
            return attestations[_publicInputs[0]][_attestationIndex];
    }
}
