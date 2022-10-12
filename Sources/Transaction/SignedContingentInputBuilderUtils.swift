//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
// swiftlint:disable multiline_function_chains

import Foundation
import LibMobileCoin

enum SignedContingentInputBuilderUtils {
    
    static func addRequiredOutput(
        ptr: OpaquePointer,
        publicAddress: PublicAddress,
        amount: Amount,
        rng: MobileCoinRng
    ) -> Result<TxOut, TransactionBuilderError> {
        var confirmationNumberData = Data32()

        func ffiInner(
            publicAddressPtr: UnsafePointer<McPublicAddress>,
            rngCallbackPtr: UnsafeMutablePointer<McRngCallback>?
        ) -> Result<Data, TransactionBuilderError> {
            confirmationNumberData.asMcMutableBuffer { confirmationNumberPtr in
                Data.make(withMcDataBytes: { errorPtr in
                    mc_signed_contingent_input_builder_add_required_output(
                        ptr,
                        amount.value,
                        amount.tokenId.value,
                        publicAddressPtr,
                        rngCallbackPtr,
                        confirmationNumberPtr,
                        &errorPtr)
                }).mapError {
                    switch $0.errorCode {
                    case .invalidInput:
                        return .invalidInput("\(redacting: $0.description)")
                    case .attestationVerificationFailed:
                        return .attestationVerificationFailed("\(redacting: $0.description)")
                    default:
                        // Safety: mc_signed_contingent_input_builder_add_required_output should not throw
                        // non-documented errors.
                        logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                    }
                }
            }
        }

        return publicAddress.withUnsafeCStructPointer { publicAddressPtr in
            withMcRngObjCallback(rng: rng) { rngCallbackPtr in
                // Using an in-line func for the FFI Inner to keep closure size low.
                ffiInner(publicAddressPtr: publicAddressPtr, rngCallbackPtr: rngCallbackPtr)
            }
        }.map { txOutData in
            guard let txOut = TxOut(serializedData: txOutData) else {
                // Safety: mc_signed_contingent_input_builder_add_required_output should always return valid data on
                // success.
                logger.fatalError("mc_signed_contingent_input_builder_add_required_output returned invalid data: " +
                    "\(redacting: txOutData.base64EncodedString())")
            }

            return txOut
        }
    }

    // swiftlint:disable closure_body_length
    static func addRequiredChangeOutput(
        ptr: OpaquePointer,
        accountKey: AccountKey,
        amount: Amount,
        rng: MobileCoinRng
    ) -> Result<TxOut, TransactionBuilderError> {
        var confirmationNumberData = Data32()

        let result: Result<Data, TransactionBuilderError> = McAccountKey.withUnsafePointer(
            viewPrivateKey: accountKey.viewPrivateKey,
            spendPrivateKey: accountKey.spendPrivateKey,
            fogInfo: accountKey.fogInfo
        ) { accountKeyPtr in
            withMcRngObjCallback(rng: rng) { rngCallbackPtr in
                confirmationNumberData.asMcMutableBuffer { confirmationNumberPtr in

                    Data.make(withMcDataBytes: { errorPtr in
                        mc_signed_contingent_input_builder_add_required_change_output(
                            accountKeyPtr,
                            ptr,
                            amount.value,
                            amount.tokenId.value,
                            rngCallbackPtr,
                            confirmationNumberPtr,
                            &errorPtr)
                    }).mapError {
                        switch $0.errorCode {
                        case .invalidInput:
                            return .invalidInput("\(redacting: $0.description)")
                        case .attestationVerificationFailed:
                            return .attestationVerificationFailed(
                                "\(redacting: $0.description)")
                        default:
                            // Safety: mc_signed_contingent_input_builder_add_required_change_output should not throw
                            // non-documented errors.
                            logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                        }
                    }
                }
            }
        }

        return result.map { txOutData in
            guard let txOut = TxOut(serializedData: txOutData) else {
                // Safety: mc_signed_contingent_input_builder_add_required_change_output should always return valid data on
                // success.
                logger.fatalError("mc_signed_contingent_input_builder_add_required_change_output returned invalid data: " +
                    "\(redacting: txOutData.base64EncodedString())")
            }

            return txOut
        }
    }
    // swiftlint:enable closure_body_length

    private static func renderTxOutContext(
        confirmationNumberData: Data32,
        sharedSecretData: Data32,
        tombstoneBlockIndex: UInt64,
        result: Result<Data, TransactionBuilderError>
    ) -> Result<TxOutContext, TransactionBuilderError> {
        result.map { txOutData in
            guard let txOut = TxOut(serializedData: txOutData) else {
                // Safety: mc_transaction_builder_add_output should always return valid data on
                // success.
                logger.fatalError("mc_transaction_builder_add_output returned invalid data: " +
                    "\(redacting: txOutData.base64EncodedString())")
            }

            let confirmationNumber = TxOutConfirmationNumber(confirmationNumberData)
            let sharedSecret = RistrettoPublic(skippingValidation: sharedSecretData)
            let receipt = Receipt(
                txOut: txOut,
                confirmationNumber: confirmationNumber,
                tombstoneBlockIndex: tombstoneBlockIndex)
            return TxOutContext(txOut, receipt, sharedSecret)
        }
    }

    static func build(
        ptr: OpaquePointer,
        rng: MobileCoinRng
    ) -> Result<SignedContingentInput, TransactionBuilderError> {

        withMcRngObjCallback(rng: rng) { rngCallbackPtr in
            Data.make(withMcDataBytes: { errorPtr in
                mc_signed_contingent_input_builder_build(ptr, rngCallbackPtr, &errorPtr)
            }).mapError {
                switch $0.errorCode {
                case .invalidInput:
                    return .invalidInput("\(redacting: $0.description)")
                default:
                    // Safety: mc_signed_contingent_input_builder_build should not throw non-documented errors.
                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                }
            }
        }.map { sciBytes in
            guard let sci = SignedContingentInput(serializedData: sciBytes) else {
                // Safety: mc_signed_contingent_input_builder_build should always return valid data on success.
                logger.fatalError("mc_signed_contingent_input_builder_build returned invalid data: " +
                    "\(redacting: sciBytes.base64EncodedString())")
            }
            return sci
        }
    }
}
