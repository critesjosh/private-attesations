use dep::std;

// We must know how many identifiers to generate at compile time.
// starting with 20 as an arbitrary number
global NUM_IDENTIFIERS = 20;

// identifier_index should be even since we are getting the 'x' output of flattened array of [x,y] values
// keep identifier as the first input so its always at _publicInputs[0] in the Solidity contract
fn main(identifier : pub Field,
        identifier_index : Field,
        pub_key_x : [u8; 32], 
        pub_key_y : [u8; 32], 
        signature: [u8; 64], 
        message_hash : [u8; 32] 
        ) 
        // -> pub Field 
    {
    let isValid = std::ecdsa_secp256k1::verify_signature(pub_key_x, pub_key_y, signature, message_hash);
    assert(isValid == 1);
    
    let mut signature_as_field: [Field; 64] = [0;64];
    for i in 0..signature_as_field.len() {
        signature_as_field[i] = signature[i] as Field;
    }

    let master_seed = std::hash::pedersen(signature_as_field);

    // flattened array of [Field; 2] elements
    let mut identifiers: [Field; NUM_IDENTIFIERS*2] = [0;NUM_IDENTIFIERS*2];
    identifiers[0] = master_seed[0];
    identifiers[1] = master_seed[1];

    let mut target_identifier = 0;

    if(identifier_index > 0) {
        for i in 0..20 {
            // if the target has been found, skip future iterations
            if(target_identifier == 0){
                // multiply by 2 since we are working with a flattened array
                let j = i * 2;
                // new identifier is the hash of the previous
                let prev_identifier = [identifiers[j-2], identifiers[j-1]];

                // hash the previous identifier to get the new identifier
                let new_identifier = std::hash::pedersen(prev_identifier);
                identifiers[j] = new_identifier[0];
                identifiers[j+1] = new_identifier[1];

                if(identifier == identifiers[j]){
                    target_identifier = identifiers[j];
                    assert(target_identifier == identifier);
                }
            }
        }
    } else {
        assert(identifiers[0] == identifier);
    }
}

// #[test]
// fn test_main() {
//     main(1, 2);

//     // Uncomment to make test fail
//     // main(1, 1);
// }
