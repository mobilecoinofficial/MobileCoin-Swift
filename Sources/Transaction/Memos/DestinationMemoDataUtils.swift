//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

enum DestinationMemoUtils {
    
    static func isValid(
        txOutPublicKey: RistrettoPublic,
        txOutTargetKey: RistrettoPublic,
        accountKey: AccountKey
    ) -> Bool {
        TxOutUtils.matchesSubaddress(
            targetKey: txOutTargetKey,
            publicKey: txOutPublicKey,
            viewPrivateKey: accountKey.viewPrivateKey,
            subaddressSpendPrivateKey: accountKey.subaddressSpendPrivateKey)
    }
    
    static func getAddressHash(
        memoData: Data64
    ) -> AddressHash? {
        let bytes: Data16? = memoData.asMcBuffer { memoDataPtr in
            switch Data16.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                mc_memo_destination_memo_get_address_hash(
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
        destinationPublicAddress: PublicAddress,
        numberOfRecipients: UInt8,
        fee: UInt64,
        totalOutlay: UInt64
    ) -> Data64? {
        destinationPublicAddress.withUnsafeCStructPointer { destinationPublicAddressPtr in
            switch Data64.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                mc_memo_destination_memo_create(
                    destinationPublicAddressPtr,
                    numberOfRecipients,
                    fee,
                    totalOutlay,
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
    
    static func getFee(
        memoData: Data64
    ) -> UInt64? {
        memoData.asMcBuffer { memoDataPtr in
            var out_fee: UInt64 = 0
            let result = withMcError { errorPtr in
                mc_memo_destination_memo_get_fee(
                    memoDataPtr,
                    &out_fee,
                    &errorPtr)
            }
            switch (result, out_fee > 0) {
            case (.success(), true):
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return out_fee
            case (.failure(let error), _):
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
            case (_, false):
                logger.warning("fee must be greater than zero")
                return nil
            }
        }
    }
    
    static func getTotalOutlay(
        memoData: Data64
    ) -> UInt64? {
        memoData.asMcBuffer { memoDataPtr in
            var out_total_outlay: UInt64 = 0
            let result = withMcError { errorPtr in
                mc_memo_destination_memo_get_total_outlay(
                    memoDataPtr,
                    &out_total_outlay,
                    &errorPtr)
            }
            switch (result, out_total_outlay > 0) {
            case (.success(), true):
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return out_total_outlay
            case (.failure(let error), _):
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
            case (_, false):
                logger.warning("total_outlay must be greater than zero")
                return nil
            }
        }
    }
    
    
    static func getNumberOfRecipients(
        memoData: Data64
    ) -> UInt8? {
        memoData.asMcBuffer { memoDataPtr in
            var out_number_of_recipients: UInt8 = 0
            let result = withMcError { errorPtr in
                mc_memo_destination_memo_get_number_of_recipients(
                    memoDataPtr,
                    &out_number_of_recipients,
                    &errorPtr)
            }
            switch (result, out_number_of_recipients > 0) {
            case (.success(), true):
                // Safety: It's safe to skip validation because
                // mc_tx_out_reconstruct_commitment should always return a valid
                // RistrettoPublic on success.
                return out_number_of_recipients
            case (.failure(let error), _):
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
            case (_, false):
                logger.warning("number_of_recipients must be greater than zero")
                return nil
            }
        }
    }

}
