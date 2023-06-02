use dep::std;

fn main(pub_key_x : [u8; 32], pub_key_y : [u8; 32], signature: [u8; 64], message_hash: [u8; 32]) -> pub [u8; 32] {
    let isValid = std::ecdsa_secp256k1::verify_signature(pub_key_x, pub_key_y, signature, message_hash);
    assert(isValid == 1);
    
    // This is the identifier
    std::hash::sha256(signature)
}

// #[test]
// fn test_main() {
//     main(1, 2);

//     // Uncomment to make test fail
//     // main(1, 1);
// }
