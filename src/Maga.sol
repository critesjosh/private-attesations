// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UltraVerifier} from '../circuits/contract/plonk_vk.sol';

contract Maga {
    
    UltraVerifier verifier;

    // identifier => attestation
    mapping(bytes32 => bytes[]) attestations;
    
    constructor(address _verifier){
        verifier = UltraVerifier(_verifier);
    }

    // _identifier is the message_hash used in the circuit
    function attest(bytes32 _identifier, bytes memory _data) public {
        attestations[_identifier].push(_data);
    }

    // _publicInputs[0] - _indentifier
    function verifyAttestation(
        bytes memory _proof, 
        bytes32[] memory _publicInputs, 
        uint _attestationIndex) 
    public
    view
    returns (bytes memory) {
        verifier.verify(_proof, _publicInputs);
        // return the encoded string of the provided _identifier
        return attestations[_publicInputs[0]][_attestationIndex];
    }
}
