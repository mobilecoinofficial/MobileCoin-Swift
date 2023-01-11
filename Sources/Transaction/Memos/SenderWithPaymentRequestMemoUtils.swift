//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

enum SenderWithPaymentRequestMemoUtils {

    static func isValid(
        memoData: Data64,
        senderPublicAddress: PublicAddress,
        receipientViewPrivateKey: RistrettoPrivate,
        txOutPublicKey: RistrettoPublic
    ) -> Bool {
        // using in-line function to keep closure levels lower
        // swiftlint:disable closure_body_length
        func ffiCall(
            memoDataPtr: UnsafePointer<McBuffer>,
            publicAddressPtr: UnsafePointer<McPublicAddress>
        ) -> Bool {
            receipientViewPrivateKey.asMcBuffer { receipientViewPrivateKeyPtr in
                txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                    var matches = false
                    let result = withMcError { errorPtr in
                        mc_memo_sender_with_payment_request_memo_is_valid(
                            memoDataPtr,
                            publicAddressPtr,
                            receipientViewPrivateKeyPtr,
                            txOutPublicKeyPtr,
                            &matches,
                            &errorPtr)
                    }
                    switch result {
                    case .success:
                        return matches
                    case .failure(let error):
                        switch error.errorCode {
                        case .invalidInput:
                            // Safety: This condition indicates a programming error and can only
                            // happen if arguments to the above FFI func are supplied incorrectly.
                            logger.warning("error: \(redacting: error)")
                            return false
                        default:
                            // Safety: mc_memo_sender_with_payment_request_memo_is_valid
                            // should not throw non-documented errors.
                            logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                            return false
                        }
                    }
                }
            }
        }
        return memoData.asMcBuffer { memoDataPtr in
            senderPublicAddress.withUnsafeCStructPointer { publicAddressPtr in
                ffiCall(memoDataPtr: memoDataPtr, publicAddressPtr: publicAddressPtr)
            }
        }
        // swiftlint:enable closure_body_length
    }

    static func getAddressHash(
        memoData: Data64
    ) -> AddressHash {
        let bytes: Data16 = memoData.asMcBuffer { memoDataPtr in
            switch Data16.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                mc_memo_sender_with_payment_request_memo_get_address_hash(
                    memoDataPtr,
                    bufferPtr,
                    &errorPtr)
            }) {
            case .success(let bytes):
                return bytes as Data16
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to
                    // mc_memo_sender_with_payment_request_memo_get_address_hash are
                    // supplied incorrectly.
                    logger.warning("error: \(redacting: error)")
                    return Data16()
                default:
                    // Safety: mc_memo_sender_with_payment_request_memo_get_address_hash
                    // should not throw non-documented errors.
                    logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                    return Data16()
                }
            }
        }
        return AddressHash(bytes)
    }

    static func create(
        senderAccountKey: AccountKey,
        receipientPublicAddress: PublicAddress,
        txOutPublicKey: RistrettoPublic,
        paymentRequestId: UInt64
    ) -> Data64? {
        senderAccountKey.withUnsafeCStructPointer { senderAccountKeyPtr in
            receipientPublicAddress.viewPublicKeyTyped.asMcBuffer { viewPublicKeyPtr in
                txOutPublicKey.asMcBuffer { txOutPublicKeyPtr in
                    switch Data64.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                        mc_memo_sender_with_payment_request_memo_create(
                            senderAccountKeyPtr,
                            viewPublicKeyPtr,
                            txOutPublicKeyPtr,
                            paymentRequestId,
                            bufferPtr,
                            &errorPtr)
                    }) {
                    case .success(let bytes):
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

    static func getPaymentRequestId(
        memoData: Data64
    ) -> UInt64? {
        memoData.asMcBuffer { memoDataPtr in
            var out_payment_request_id: UInt64 = 0
            let result = withMcError { errorPtr in
                mc_memo_sender_with_payment_request_memo_get_payment_request_id(
                    memoDataPtr,
                    &out_payment_request_id,
                    &errorPtr)
            }
            switch result {
            case .success:
                return out_payment_request_id
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to the above FFI are supplied incorrectly.
                    logger.warning("error: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_memo_sender_with_payment_request_memo_get_payment_request_id
                    // should not throw non-documented errors.
                    logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                    return nil
                }
            }
        }
    }

}
