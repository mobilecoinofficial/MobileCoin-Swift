//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

enum SenderMemoUtils {
    static func isValid(
        memoData: Data64,
        senderPublicAddress: PublicAddress,
        receipientViewPrivateKey: RistrettoPrivate,
        txOutPublicKey: RistrettoPublic
    ) -> Bool {
        memoData.asMcBuffer { memoDataPtr in
            senderPublicAddress.withUnsafeCStructPointer { publicAddressPtr in
                receipientViewPrivateKey.asMcBuffer { receipientViewPrivateKeyPtr in
                    txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                        var matches = true
                        // Safety: mc_tx_out_matches_any_subaddress is infallible when preconditions are
                        // upheld.
                        let result = withMcError { errorPtr in
                            mc_memo_sender_memo_is_valid(
                                memoDataPtr,
                                publicAddressPtr,
                                receipientViewPrivateKeyPtr,
                                txOutPublicKeyPtr,
                                &matches,
                                &errorPtr)
                        }
                        print(matches)
                        switch result {
                        case .success():
                            return true
                        case .failure(let error):
                            print("\(error)")
                            return false
                        }
                    }
                }
            }
        }
    }
    
    static func getAddressHash(
        memoData: Data64
    ) -> AddressHash? {
        let bytes: Data16? = memoData.asMcBuffer { memoDataPtr in
            switch Data16.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                mc_memo_sender_memo_get_address_hash(
                    memoDataPtr,
                    bufferPtr,
                    &errorPtr)
            }) {
            case .success(let bytes):
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return bytes as Data16
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to mc_tx_out_reconstruct_commitment are
                    // supplied incorrectly.
                    logger.warning("error: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_tx_out_reconstruct_commitment should not throw
                    // non-documented errors.
                    logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                    return nil
                }
            }
        }
        guard let bytes = bytes else { return nil }
        print("address hash bytes \(bytes.data.hexEncodedString())")
        return AddressHash(bytes)
    }
    
    static func create(
        senderAccountKey: AccountKey,
        receipientPublicAddress: PublicAddress,
        txOutPublicKey: RistrettoPublic
    ) -> Data64? {
        senderAccountKey.withUnsafeCStructPointer { senderAccountKeyPtr in
            receipientPublicAddress.viewPublicKeyTyped.asMcBuffer { viewPublicKeyPtr in
                txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                    switch Data64.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                        mc_memo_sender_memo_create(
                            senderAccountKeyPtr,
                            viewPublicKeyPtr,
                            txOutPublicKeyPtr,
                            bufferPtr,
                            &errorPtr)
                    }) {
                    case .success(let bytes):
                        // TODO - Update
                        
                        // Safety: It's safe to skip validation because
                        // mc_tx_out_reconstruct_commitment should always return a valid
                        // RistrettoPublic on success.
                        return bytes as Data64
                    case .failure(let error):
                        switch error.errorCode {
                        case .invalidInput:
                            // Safety: This condition indicates a programming error and can only
                            // happen if arguments to mc_tx_out_reconstruct_commitment are
                            // supplied incorrectly.
                            logger.warning("error: \(redacting: error)")
                            return nil
                        default:
                            // Safety: mc_tx_out_reconstruct_commitment should not throw
                            // non-documented errors.
                            logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                            return nil
                        }
                    }
                }
            }
        }
    }
}

