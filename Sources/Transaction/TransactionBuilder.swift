//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_parameter_count function_default_parameter_at_end
// swiftlint:disable multiline_function_chains

import Foundation
import LibMobileCoin

enum TransactionBuilderError: Error {
    case invalidInput(String)
    case invalidBlockVersion(String)
    case attestationVerificationFailed(String)
}

extension TransactionBuilderError: CustomStringConvertible {
    var description: String {
        "Transaction builder error: " + {
            switch self {
            case .invalidInput(let reason):
                return "Invalid input: \(reason)"
            case .invalidBlockVersion(let reason):
                return "Invalid Block Version: \(reason)"
            case .attestationVerificationFailed(let reason):
                return "Attestation verification failed: \(reason)"
            }
        }()
    }
}

final class TransactionBuilder {

    private let tombstoneBlockIndex: UInt64

    private let ptr: OpaquePointer

    private let memoBuilder: TxOutMemoBuilder

    internal struct Context {
        let accountKey: AccountKey
        let blockVersion: BlockVersion
        let fogResolver: FogResolver
        let memoType: MemoType
        let tombstoneBlockIndex: UInt64
        let fee: Amount
        let rngSeed: RngSeed
    }

    private struct InnerContext {
        let blockVersion: BlockVersion
        var fogResolver = FogResolver()
        var memoBuilder: TxOutMemoBuilder = DefaultMemoBuilder()
        let tombstoneBlockIndex: UInt64
        let fee: Amount
    }

    private init(
        context: InnerContext
    ) throws {
        self.tombstoneBlockIndex = context.tombstoneBlockIndex
        self.memoBuilder = context.memoBuilder
        let result: Result<OpaquePointer, TransactionBuilderError>
        result = memoBuilder.withUnsafeOpaquePointer { memoBuilderPtr in
            context.fogResolver.withUnsafeOpaquePointer { fogResolverPtr in
                // Safety: mc_transaction_builder_create should never return nil.
                withMcError { errorPtr in
                    mc_transaction_builder_create(
                        context.fee.value,
                        context.fee.tokenId.value,
                        context.tombstoneBlockIndex,
                        fogResolverPtr,
                        memoBuilderPtr,
                        context.blockVersion,
                        &errorPtr)
                }.mapError {
                    switch $0.errorCode {
                    case .invalidInput:
                        return .invalidBlockVersion("\(redacting: $0.description)")
                    default:
                        // Safety: mc_transaction_builder_add_input should not throw
                        // non-documented errors.
                        logger.fatalError("Unhandled LibMobileCoin error: \(redacting: $0)")
                    }
                }
            }
        }
        self.ptr = try result.get()
    }

    deinit {
        mc_transaction_builder_free(ptr)
    }
}

extension TransactionBuilder {
    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        to recipient: PublicAddress,
        amount: PositiveUInt64,
        presignedInput: SignedContingentInput? = nil
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        build(
            context: context,
            inputs: inputs,
            outputs: [TransactionOutput(recipient, amount)],
            presignedInput: presignedInput
        ).map { pendingTransaction in
            pendingTransaction.singlePayload
        }
    }

    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        sendingAllTo recipient: PublicAddress
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        Math.positiveRemainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            fee: context.fee
        ).map { outputAmount in
            PossibleTransaction([TransactionOutput(recipient, outputAmount)], nil)
        }.flatMap { possibleTransaction in
            build(
                context: context,
                inputs: inputs,
                possibleTransaction: possibleTransaction,
                presignedInput: nil
            ).map { pendingTransaction in
                pendingTransaction.singlePayload
            }
        }
    }

    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        outputs: [TransactionOutput],
        presignedInput: SignedContingentInput? = nil
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        outputsAddingChangeOutput(
            inputs: inputs,
            outputs: outputs,
            fee: context.fee
        ).flatMap { buildingTransaction in
            build(
                context: context,
                inputs: inputs,
                possibleTransaction: buildingTransaction,
                presignedInput: presignedInput)
        }
    }

    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        possibleTransaction: PossibleTransaction,
        presignedInput: SignedContingentInput? = nil
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        guard Math.totalOutlayCheck(for: possibleTransaction, fee: context.fee, inputs: inputs) else {
            return .failure(.invalidInput("Input values != output values + fee"))
        }

        let builder: TransactionBuilder
        do {
            builder = try TransactionBuilder(
                context: InnerContext(
                    blockVersion: context.blockVersion,
                    fogResolver: context.fogResolver,
                    memoBuilder: context.memoType.createMemoBuilder(accountKey: context.accountKey),
                    tombstoneBlockIndex: context.tombstoneBlockIndex,
                    fee: context.fee))
        } catch {
            guard let error = error as? TransactionBuilderError else {
                return .failure(.invalidInput("Unknown Error"))
            }
            return .failure(error)
        }

        for input in inputs {
            if case .failure(let error) =
                builder.addInput(preparedTxInput: input, accountKey: context.accountKey)
            {
                return .failure(error)
            }
        }

        let seededRng = MobileCoinChaCha20Rng(rngSeed: context.rngSeed)

        let payloadContexts = possibleTransaction.outputs.map { output in
            builder.addOutput(
                publicAddress: output.recipient,
                amount: output.amount.value,
                rng: seededRng
            )
        }

        let changeContext = changeContext(
            blockVersion: context.blockVersion,
            accountKey: context.accountKey,
            builder: builder,
            changeAmount: possibleTransaction.changeAmount,
            rng: seededRng)

        // if presignedInput...
        //
        // 1.) add presignedInput to transaction (easy)
        //
        // 2.) add output for payment to self as income from presignedInput
        //     (reference payloadContexts and builder.addOutput code block at line 217-223)

        // TODO: add ability to specify token ID for the reward amount, which is expected
        // to be different than the token ID for the required amount.
        var presignedIncomeTxOutputs = [TransactionOutput]()
        if let presignedInput = presignedInput {
            if let rewardAmount = PositiveUInt64(presignedInput.rewardAmount.value) {
                let incomeTxOut = TransactionOutput(context.accountKey.publicAddress, rewardAmount)
                presignedIncomeTxOutputs.append(incomeTxOut)
            }
            if case .failure(let error) =
                builder.addSignedContingentInput(signedContingentInput: presignedInput)
            {
                return .failure(error)
            }
        }

        return payloadContexts.collectResult().flatMap { payloadContexts in
            changeContext.flatMap { changeContext in
                builder.build(rng: seededRng).map { transaction in
                    PendingTransaction(
                        transaction: transaction,
                        payloadTxOutContexts: payloadContexts,
                        changeTxOutContext: changeContext,
                        presignedInputIncomeTxOutputs: presignedIncomeTxOutputs)
                }
            }
        }
    }

    private static func changeContext(
        blockVersion: BlockVersion,
        accountKey: AccountKey,
        builder: TransactionBuilder,
        changeAmount: PositiveUInt64?,
        rng: MobileCoinRng
    ) -> Result<TxOutContext, TransactionBuilderError> {
        switch blockVersion {
        case .legacy:
            // Clients built for BlockVersion == 0 (.legacy) will have trouble finding txOuts
            // on the new change subaddress (max - 1), so we will emulate legacy behavior.
            return builder.addOutput(
                publicAddress: accountKey.publicAddress,
                amount: changeAmount?.value ?? 0,
                rng: rng)
        default:
            return builder.addChangeOutput(
                accountKey: accountKey,
                amount: changeAmount?.value ?? 0,
                rng: rng)
        }
    }

    static func output(
        publicAddress: PublicAddress,
        amount: UInt64,
        fogResolver: FogResolver = FogResolver(),
        blockVersion: BlockVersion,
        rng: MobileCoinRng
    ) -> Result<TxOut, TransactionBuilderError> {
        outputWithReceipt(
            publicAddress: publicAddress,
            amount: amount,
            tombstoneBlockIndex: 0,
            fogResolver: fogResolver,
            blockVersion: blockVersion,
            rng: rng
        ).map { $0.txOut }
    }

    static func outputWithReceipt(
        publicAddress: PublicAddress,
        amount: UInt64,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver = FogResolver(),
        blockVersion: BlockVersion,
        rng: MobileCoinRng
    ) -> Result<TxOutContext, TransactionBuilderError> {
        let transactionBuilder: TransactionBuilder
        do {
            transactionBuilder = try TransactionBuilder(
                context: InnerContext(blockVersion: blockVersion,
                                      fogResolver: fogResolver,
                                      tombstoneBlockIndex: tombstoneBlockIndex,
                                      fee: Amount(0, in: .MOB))
                )
        } catch {
            guard let error = error as? TransactionBuilderError else {
                return .failure(.invalidInput("Unknown Error"))
            }
            return .failure(error)
        }
        return transactionBuilder.addOutput(
            publicAddress: publicAddress,
            amount: amount,
            rng: rng)
    }

    private static func outputsAddingChangeOutput(
        inputs: [PreparedTxInput],
        outputs: [TransactionOutput],
        fee: Amount
    ) -> Result<PossibleTransaction, TransactionBuilderError> {
        Math.remainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            outputValues: outputs.map { $0.amount.value },
            fee: fee
        )
        .map { remainingAmount in
            PossibleTransaction(outputs, PositiveUInt64(remainingAmount))
        }
    }
}

extension TransactionBuilder {
    private func addInput(preparedTxInput: PreparedTxInput, accountKey: AccountKey)
        -> Result<(), TransactionBuilderError>
    {
        let subaddressIndex = preparedTxInput.subaddressIndex
        guard let spendPrivateKey = accountKey.privateKeys(for: subaddressIndex)?.spendKey else {
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
        TransactionBuilderUtils.addInput(
            ptr: ptr,
            preparedTxInput: preparedTxInput,
            viewPrivateKey: viewPrivateKey,
            subaddressSpendPrivateKey: subaddressSpendPrivateKey)
    }

    private func addOutput(
        publicAddress: PublicAddress,
        amount: UInt64,
        rng: MobileCoinRng
    ) -> Result<TxOutContext, TransactionBuilderError> {
        TransactionBuilderUtils.addOutput(
            ptr: ptr,
            tombstoneBlockIndex: tombstoneBlockIndex,
            publicAddress: publicAddress,
            amount: amount,
            rng: rng)
    }

    private func addChangeOutput(
        accountKey: AccountKey,
        amount: UInt64,
        rng: MobileCoinRng
    ) -> Result<TxOutContext, TransactionBuilderError> {
        TransactionBuilderUtils.addChangeOutput(
            ptr: ptr,
            tombstoneBlockIndex: tombstoneBlockIndex,
            accountKey: accountKey,
            amount: amount,
            rng: rng)
    }

    private func addSignedContingentInput(
        signedContingentInput: SignedContingentInput
    ) -> Result<(), TransactionBuilderError> {
        TransactionBuilderUtils.addSignedContingentInput(
            ptr: ptr,
            signedContingentInput: signedContingentInput)
    }

    private func build(
        rng: MobileCoinRng
    ) -> Result<Transaction, TransactionBuilderError> {
        TransactionBuilderUtils.build(ptr: ptr, rng: rng)
    }
}
