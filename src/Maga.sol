// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UltraVerifier} from '../circuits/contract/plonk_vk.sol';

contract Maga {

    UltraVerifier verifier;
 
    mapping(bytes32 => bytes[]) attestations;
    
    constructor(address _verifier){
        verifier = UltraVerifier(_verifier);
    }

    // possible to batch attestations
    function attest(
        bytes32[] memory _identifiers, 
        bytes[][] memory _attestations) 
    public {
        for (uint i = 0; i < _identifiers.length; i++) {
            for (uint j = 0; j < _attestations[i].length; j++) {
                // push all of the attestations onto the identifier
                attestations[_identifiers[i]].push(_attestations[i][j]);
            }
        }
    }
    
    // This function will only work for attestations that
    // have an associated signature. The attestation can only be revoked 
    // by the account that issued it.
    // Can also batch these calls
    // This function assumes that signatures are located 
    // in the bytes locations discussed (in #attestation-structure) above.
    function revokeAttestations(
        bytes32[] memory _identifiers, 
        uint8[][] memory _attestationIndexes, 
        bytes32[][] memory _messageHashes // calculate off-chain for simplicity
    )
    public {
        for (uint i = 0; i < _identifiers.length; i++) {
            for (uint j = 0; j < _attestationIndexes[i].length; j++) {
                uint8 index = _attestationIndexes[i][j];
                bytes memory attestation = attestations[_identifiers[i]][index];
                uint8 v = uint8(subset(attestation, 128, 0)[0]);
                bytes32 r;
                bytes32 s;
                bytes memory rBytes = subset(attestation, 64, 32);
                bytes memory sBytes = subset(attestation, 96, 32);
                assembly {
                    r := mload(add(rBytes, 32))
                    s := mload(add(sBytes, 32))
                }       
                require(msg.sender == ecrecover(_messageHashes[i][j], v, r, s));
                delete attestations[_identifiers[i]][index];
            }
        }
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
            return attestations[_publicInputs[0]][_attestationIndex];
    }
    
    function verifyAttestationFromSafe(
        bytes memory _proof, 
        bytes32[] memory _publicInputs, 
        uint _attestationIndex) 
        public
        view
        returns (bytes memory) {
            // requires a different circuit that takes
            //  multiple ECDSA signatures (from the safe account signers)
            //  the circuit 
            //  1. takes an array of signatures
            //  2. gets the signer addresses for the sigs
            //  3. proves that the signers are owners of the safe
            //  4. proves there are >= the required signatures 
            //  to meet the multisig threshold
            // Waiting on ethereum storage proofs in noir
            // to implement this.

            return attestations[_publicInputs[0]][_attestationIndex];
    }

    // helper function
    function subset(bytes memory _b, uint _startIndex, uint _length) 
        pure 
        internal
        returns(bytes memory) 
    {
        bytes memory newSet = new bytes(_length);
        for (uint i = 0; i < _length; i++) {
            newSet[i] = _b[_startIndex + i];
        }
        return newSet;
    }
}