//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_parameter_count function_default_parameter_at_end
// swiftlint:disable multiline_function_chains

import Foundation
import LibMobileCoin

enum TransactionBuilderError: Error {
    case invalidInput(String)
    case attestationVerificationFailed(String)
}

extension TransactionBuilderError: CustomStringConvertible {
    var description: String {
        "Transaction builder error: " + {
            switch self {
            case .invalidInput(let reason):
                return "Invalid input: \(reason)"
            case .attestationVerificationFailed(let reason):
                return "Attestation verification failed: \(reason)"
            }
        }()
    }
}

final class TransactionBuilder {
    static func build(
        inputs: [PreparedTxInput],
        accountKey: AccountKey,
        to recipient: PublicAddress,
        memoType: MemoType,
        amount: PositiveUInt64,
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver,
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        build(
            inputs: inputs,
            accountKey: accountKey,
            outputs: [TransactionOutput(recipient, amount)],
            memoType: memoType,
            fee: fee,
            tombstoneBlockIndex: tombstoneBlockIndex,
            fogResolver: fogResolver,
            blockVersion: blockVersion,
            rng: rng,
            rngContext: rngContext
        ).map { pendingTransaction in
            pendingTransaction.singlePayload
        }
    }

    static func build(
        inputs: [PreparedTxInput],
        accountKey: AccountKey,
        sendingAllTo recipient: PublicAddress,
        memoType: MemoType,
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver,
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        positiveRemainingAmount(inputValues: inputs.map { $0.knownTxOut.value }, fee: fee)
            .map { outputAmount in
                PossibleTransaction([TransactionOutput(recipient, outputAmount)], nil)
            }
            .flatMap { possibleTransaction in
                build(
                    inputs: inputs,
                    accountKey: accountKey,
                    possibleTransaction: possibleTransaction,
                    memoType: memoType,
                    fee: fee,
                    tombstoneBlockIndex: tombstoneBlockIndex,
                    fogResolver: fogResolver,
                    blockVersion: blockVersion,
                    rng: rng,
                    rngContext: rngContext
                ).map { pendingTransaction in
                    pendingTransaction.singlePayload
                }
            }
    }

    static func build(
        inputs: [PreparedTxInput],
        accountKey: AccountKey,
        outputs: [TransactionOutput],
        memoType: MemoType,
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver,
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        outputsAddingChangeOutputIfNeeded(
            inputs: inputs,
            outputs: outputs,
            fee: fee
        ).flatMap { buildingTransaction in
            build(
                inputs: inputs,
                accountKey: accountKey,
                possibleTransaction: buildingTransaction,
                memoType: memoType,
                fee: fee,
                tombstoneBlockIndex: tombstoneBlockIndex,
                fogResolver: fogResolver,
                blockVersion: blockVersion,
                rng: rng,
                rngContext: rngContext)
        }
    }

    static func build(
        inputs: [PreparedTxInput],
        accountKey: AccountKey,
        possibleTransaction: PossibleTransaction,
        memoType: MemoType,
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver,
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        let outputs = possibleTransaction.outputs
        let changeAmount = possibleTransaction.changeAmount
        let allValues = (outputs.map { $0.amount.value } + [fee.value, changeAmount?.value ?? 0])
        guard UInt64.safeCompare(
                sumOfValues: inputs.map { $0.knownTxOut.value },
                isEqualToSumOfValues: allValues)
        else {
            return .failure(.invalidInput("Input values != output values + fee"))
        }

        let builder = TransactionBuilder(
            fee: fee,
            tokenId: fee.tokenId,
            tombstoneBlockIndex: tombstoneBlockIndex,
            fogResolver: fogResolver,
            memoBuilder: memoType.createMemoBuilder(accountKey: accountKey),
            blockVersion: blockVersion)

        for input in inputs {
            if case .failure(let error) =
                builder.addInput(preparedTxInput: input, accountKey: accountKey)
            {
                return .failure(error)
            }
        }

        let payloadContexts = outputs.map { output in
            builder.addOutput(
                publicAddress: output.recipient,
                amount: output.amount.value,
                rng: rng,
                rngContext: rngContext
            )
        }
        
        let changeContext: Result<TxOutContext, TransactionBuilderError>
        switch blockVersion {
        case .legacy:
            // Clients built for BlockVersion == 0 (.legacy) will have trouble finding txOuts
            // on the new change subaddress (max - 1), so we will emulate legacy behavior.
            changeContext = builder.addOutput(
                publicAddress: accountKey.publicAddress,
                amount: changeAmount?.value ?? 0,
                rng: rng,
                rngContext: rngContext)
        default:
            changeContext = builder.addChangeOutput(
                accountKey: accountKey,
                amount: changeAmount?.value ?? 0,
                rng: rng,
                rngContext: rngContext)
        }

        return payloadContexts.collectResult().flatMap { payloadContexts in
            changeContext.flatMap { changeContext in
                builder.build(rng: rng, rngContext: rngContext).map { transaction in
                    PendingTransaction(
                        transaction: transaction,
                        payloadTxOutContexts: payloadContexts,
                        changeTxOutContext: changeContext)
                }
            }
        }
    }

    static func output(
        publicAddress: PublicAddress,
        amount: UInt64,
        fogResolver: FogResolver = FogResolver(),
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<TxOut, TransactionBuilderError> {
        outputWithReceipt(
            publicAddress: publicAddress,
            amount: amount,
            tombstoneBlockIndex: 0,
            fogResolver: fogResolver,
            blockVersion: blockVersion,
            rng: rng,
            rngContext: rngContext
        ).map { $0.txOut }
    }

    static func outputWithReceipt(
        publicAddress: PublicAddress,
        amount: UInt64,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver = FogResolver(),
        blockVersion: BlockVersion,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<TxOutContext, TransactionBuilderError> {
        let transactionBuilder = TransactionBuilder(
            fee: Amount(value: 0, tokenId: .MOB),
            tokenId: .MOB,
            tombstoneBlockIndex: tombstoneBlockIndex,
            fogResolver: fogResolver,
            blockVersion: blockVersion)
        return transactionBuilder.addOutput(
            publicAddress: publicAddress,
            amount: amount,
            rng: rng,
            rngContext: rngContext)
    }

    private static func outputsAddingChangeOutputIfNeeded(
        inputs: [PreparedTxInput],
        outputs: [TransactionOutput],
        fee: Amount
    ) -> Result<PossibleTransaction, TransactionBuilderError> {
        remainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            outputValues: outputs.map { $0.amount.value },
            fee: fee
        ).map { remainingAmount in
            PossibleTransaction(outputs, PositiveUInt64(remainingAmount))
        }
    }

    private static func remainingAmount(inputValues: [UInt64], outputValues: [UInt64], fee: Amount)
        -> Result<UInt64, TransactionBuilderError>
    {
        guard UInt64.safeCompare(
                sumOfValues: inputValues,
                isGreaterThanOrEqualToSumOfValues: outputValues + [fee.value])
        else {
            return .failure(.invalidInput("Total input amount < total output amount + fee"))
        }

        guard let remainingAmount = UInt64.safeSubtract(
                sumOfValues: inputValues,
                minusSumOfValues: outputValues + [fee.value])
        else {
            return .failure(.invalidInput("Change amount overflows UInt64"))
        }

        return .success(remainingAmount)
    }

    private static func positiveRemainingAmount(inputValues: [UInt64], fee: Amount)
        -> Result<PositiveUInt64, TransactionBuilderError>
    {
        guard UInt64.safeCompare(sumOfValues: inputValues, isGreaterThanValue: fee.value) else {
            return .failure(.invalidInput("Total input amount <= fee"))
        }

        guard let remainingAmount = UInt64.safeSubtract(
                sumOfValues: inputValues,
                minusValue: fee.value)
        else {
            return .failure(.invalidInput("Change amount overflows UInt64"))
        }

        guard let positiveRemainingAmount = PositiveUInt64(remainingAmount) else {
            // This condition should be redundant with the first check, but we throw an error
            // anyway, rather than calling fatalError.
            return .failure(.invalidInput("Total input amount == fee"))
        }

        return .success(positiveRemainingAmount)
    }
    
    private let tombstoneBlockIndex: UInt64

    private let ptr: OpaquePointer
    
    private let memoBuilder: TxOutMemoBuilder

    private init(
        fee: Amount,
        tokenId: TokenId,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver = FogResolver(),
        memoBuilder: TxOutMemoBuilder = DefaultMemoBuilder(),
        blockVersion: BlockVersion
    ) {
        self.tombstoneBlockIndex = tombstoneBlockIndex
        self.memoBuilder = memoBuilder
        self.ptr = memoBuilder.withUnsafeOpaquePointer { memoBuilderPtr in
            fogResolver.withUnsafeOpaquePointer { fogResolverPtr in
                // Safety: mc_transaction_builder_create should never return nil.
                withMcInfallible {
                    mc_transaction_builder_create(
                            fee.value, 
                            tokenId.value, 
                            tombstoneBlockIndex, 
                            fogResolverPtr, 
                            memoBuilderPtr, 
                            blockVersion)
                }
            }
        }
    }

    deinit {
        mc_transaction_builder_free(ptr)
    }

    private func addInput(preparedTxInput: PreparedTxInput, accountKey: AccountKey)
        -> Result<(), TransactionBuilderError>
    {
        let subaddressIndex = preparedTxInput.subaddressIndex
        guard let spendPrivateKey = accountKey.subaddressSpendPrivateKey(subaddressIndex) else {
            return .failure(.invalidInput("Tx subaddress index out of bounds"))
        }
        return addInput(
                preparedTxInput: preparedTxInput,
                viewPrivateKey: accountKey.viewPrivateKey,
                subaddressSpendPrivateKey: spendPrivateKey)
    }

    private func addInput(
        preparedTxInput: PreparedTxInput,
        viewPrivateKey: RistrettoPrivate,
        subaddressSpendPrivateKey: RistrettoPrivate
    ) -> Result<(), TransactionBuilderError> {
        let ring = McTransactionBuilderRing(ring: preparedTxInput.ring)
        return viewPrivateKey.asMcBuffer { viewPrivateKeyPtr in
            subaddressSpendPrivateKey.asMcBuffer { subaddressSpendPrivateKeyPtr in
                ring.withUnsafeOpaquePointer { ringPtr in
                    withMcError { errorPtr in
                        mc_transaction_builder_add_input(
                            ptr,
                            viewPrivateKeyPtr,
                            subaddressSpendPrivateKeyPtr,
                            preparedTxInput.realInputIndex,
                            ringPtr,
                            &errorPtr)
                    }.mapError {
                        switch $0.errorCode {
                        case .invalidInput:
                            return .invalidInput("\(redacting: $0.description)")
                        default:
                            // Safety: mc_transaction_builder_add_input should not throw
                            // non-documented errors.
                            logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                        }
                    }
                }
            }
        }
    }

    private func addOutput(
        publicAddress: PublicAddress,
        amount: UInt64,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<TxOutContext, TransactionBuilderError> {
        var confirmationNumberData = Data32()
        var sharedSecretData = Data32()
        return publicAddress.withUnsafeCStructPointer { publicAddressPtr in
            withMcRngCallback(rng: rng, rngContext: rngContext) { rngCallbackPtr in
                confirmationNumberData.asMcMutableBuffer { confirmationNumberPtr in
                    sharedSecretData.asMcMutableBuffer { sharedSecretPtr in
                        Data.make(withMcDataBytes: { errorPtr in
                            mc_transaction_builder_add_output(
                                ptr,
                                amount,
                                publicAddressPtr,
                                rngCallbackPtr,
                                confirmationNumberPtr,
                                sharedSecretPtr,
                                &errorPtr)
                        }).mapError {
                            switch $0.errorCode {
                            case .invalidInput:
                                return .invalidInput("\(redacting: $0.description)")
                            case .attestationVerificationFailed:
                                return .attestationVerificationFailed("\(redacting: $0.description)")
                            default:
                                // Safety: mc_transaction_builder_add_output should not throw
                                // non-documented errors.
                                logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                            }
                        }
                    }
                }
            }
        }.map { txOutData in
            guard let txOut = TxOut(serializedData: txOutData) else {
                // Safety: mc_transaction_builder_add_output should always return valid data on
                // success.
                logger.fatalError("mc_transaction_builder_add_output returned invalid data: " +
                    "\(redacting: txOutData.base64EncodedString())")
            }

            let confirmationNumber = TxOutConfirmationNumber(confirmationNumberData)
            let sharedSecret = RistrettoPublic(skippingValidation: sharedSecretData) // TODO - safe to skip validation ?
            let receipt = Receipt(
                txOut: txOut,
                confirmationNumber: confirmationNumber,
                tombstoneBlockIndex: tombstoneBlockIndex)
            return TxOutContext(txOut, receipt, sharedSecret)
        }
    }

    private func addChangeOutput(
        accountKey: AccountKey,
        amount: UInt64,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<TxOutContext, TransactionBuilderError> {
        
        var confirmationNumberData = Data32()
        var sharedSecretData = Data32()
        
        return McAccountKey.withUnsafePointer(
            viewPrivateKey: accountKey.viewPrivateKey,
            spendPrivateKey: accountKey.spendPrivateKey,
            fogInfo: accountKey.fogInfo
        ) { accountKeyPtr in
                withMcRngCallback(rng: rng, rngContext: rngContext) { rngCallbackPtr in
                    confirmationNumberData.asMcMutableBuffer { confirmationNumberPtr in
                        sharedSecretData.asMcMutableBuffer { sharedSecretPtr in
                            Data.make(withMcDataBytes: { errorPtr in
                                mc_transaction_builder_add_change_output(
                                    accountKeyPtr,
                                    ptr,
                                    amount,
                                    rngCallbackPtr,
                                    confirmationNumberPtr,
                                    sharedSecretPtr,
                                    &errorPtr)
                            }).mapError {
                                switch $0.errorCode {
                                case .invalidInput:
                                    return .invalidInput("\(redacting: $0.description)")
                                case .attestationVerificationFailed:
                                    return .attestationVerificationFailed("\(redacting: $0.description)")
                                default:
                                    // Safety: mc_transaction_builder_add_output should not throw
                                    // non-documented errors.
                                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                                }
                            }
                        }
                    }
                 }
        }.map { txOutData in
            guard let txOut = TxOut(serializedData: txOutData) else {
                // Safety: mc_transaction_builder_add_output should always return valid data on
                // success.
                logger.fatalError("mc_transaction_builder_add_output returned invalid data: " +
                    "\(redacting: txOutData.base64EncodedString())")
            }

            let confirmationNumber = TxOutConfirmationNumber(confirmationNumberData)
            let sharedSecret = RistrettoPublic(skippingValidation: sharedSecretData) // TODO - safe to skip validation ?
            let receipt = Receipt(
                txOut: txOut,
                confirmationNumber: confirmationNumber,
                tombstoneBlockIndex: tombstoneBlockIndex)
            return TxOutContext(txOut, receipt, sharedSecret)
        }
    }

    private func build(
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<Transaction, TransactionBuilderError> {
        withMcRngCallback(rng: rng, rngContext: rngContext) { rngCallbackPtr in
            Data.make(withMcDataBytes: { errorPtr in
                mc_transaction_builder_build(ptr, rngCallbackPtr, &errorPtr)
            }).mapError {
                switch $0.errorCode {
                case .invalidInput:
                    return .invalidInput("\(redacting: $0.description)")
                default:
                    // Safety: mc_transaction_builder_build should not throw non-documented errors.
                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                }
            }
        }.map { txBytes in
            guard let transaction = Transaction(serializedData: txBytes) else {
                // Safety: mc_transaction_builder_build should always return valid data on success.
                logger.fatalError("mc_transaction_builder_build returned invalid data: " +
                    "\(redacting: txBytes.base64EncodedString())")
            }
            return transaction
        }
    }
}

private final class McTransactionBuilderRing {
    private let ptr: OpaquePointer

    init(ring: [(TxOut, TxOutMembershipProof)]) {
        // Safety: mc_transaction_builder_ring_create should never return nil.
        self.ptr = withMcInfallible(mc_transaction_builder_ring_create)

        for (txOut, membershipProof) in ring {
            addElement(txOut: txOut, membershipProof: membershipProof)
        }
    }

    deinit {
        mc_transaction_builder_ring_free(ptr)
    }

    func addElement(txOut: TxOut, membershipProof: TxOutMembershipProof) {
        txOut.serializedData.asMcBuffer { txOutBytesPtr in
            membershipProof.serializedData.asMcBuffer { membershipProofDataPtr in
                // Safety: mc_transaction_builder_ring_add_element should never return nil.
                withMcInfallible {
                    mc_transaction_builder_ring_add_element(
                        ptr,
                        txOutBytesPtr,
                        membershipProofDataPtr)
                }
            }
        }
    }

    func withUnsafeOpaquePointer<R>(_ body: (OpaquePointer) throws -> R) rethrows -> R {
        try body(ptr)
    }
}
