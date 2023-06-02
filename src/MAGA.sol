// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UltraVerifier} from '../circuits/contract/plonk_vk.sol';

contract MAGA {
    
    // identifier => attestation
    mapping(bytes32 => string[]) attestations;
    
    // _identifier is the message_hash used in the circuit
    function attest(bytes32 _identifier, string _data) public {
        attestions[_identifier].push(_data);
    }

    // _publicInputs[0] - _indentifier
    function verifyAttestation(
        bytes _proof, 
        bytes32[] _publicInputs, 
        uint _attestationIndex) 
    public
    returns (string memory) {
        UltraVerifier.verify(bytes _proof, bytes32[] _publicInputs);
        // return the encoded string of the provided _identifier
        return attestations[_publicInputs[0]][_attestationIndex];
    }
}
