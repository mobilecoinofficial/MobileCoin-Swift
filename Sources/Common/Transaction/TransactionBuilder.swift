//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end
// swiftlint:disable multiline_function_chains function_body_length

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

enum TransactionBuilderError: Error, Sendable {
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

    struct Context {
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
                        return .invalidInput("\(redacting: $0.description)")
                    default:
                        // Safety: mc_transaction_builder_create should not throw
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
        amount: Amount
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        build(
            context: context,
            inputs: inputs,
            outputs: [TransactionOutput(recipient, amount)]
        ).map { pendingTransaction in
            pendingTransaction.singlePayload
        }
    }

    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        sendingAllTo recipient: PublicAddress
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        guard let tokenId = inputs.first?.knownTxOut.amount.tokenId else {
            return .failure(.invalidInput("No inputs to send"))
        }
        return Math.remainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            outputValues: [],
            fee: context.fee
        ).map { outputAmount in
            let amountToSend = Amount(outputAmount, in: tokenId)
            let changeAmount = Amount(0, in: tokenId)
            return PossibleTransaction([TransactionOutput(recipient, amountToSend)], changeAmount)
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
        presignedInput: SignedContingentInput
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        outputsAddingChangeOutputForSCI(
            inputs: inputs,
            presignedInput: presignedInput
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
        outputs: [TransactionOutput]
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
                presignedInput: nil)
        }
    }

    static func build(
        context: TransactionBuilder.Context,
        inputs: [PreparedTxInput],
        possibleTransaction: PossibleTransaction,
        presignedInput: SignedContingentInput? = nil
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        guard Math.totalOutlayCheck(
                for: possibleTransaction,
                fee: context.fee,
                inputs: inputs,
                presignedInput: presignedInput
        ) else {
            return .failure(.invalidInput("Input values != output values + fee"))
        }

        let builder: TransactionBuilder
        switch makeBuilder(context: context) {
        case .failure(let error):
            return .failure(error)
        case .success(let made):
            builder = made
        }

        for input in inputs {
            if case .failure(let error) =
                builder.addInput(preparedTxInput: input, accountKey: context.accountKey) {
                return .failure(error)
            }
        }

        let seededRng = MobileCoinChaCha20Rng(rngSeed: context.rngSeed)

        let (payloadContexts, changeContext) = addOutputs(
            context: context,
            builder: builder,
            possibleTransaction: possibleTransaction,
            rng: seededRng)

        var presignedIncomeTxOutContexts = [TxOutContext]()
        if let presignedInput = presignedInput {
            // add SCI
            if case .failure(let error) =
                builder.addSignedContingentInput(signedContingentInput: presignedInput) {
                return .failure(error)
            }

            // net reward amount is reward amount minus fee
            _ = Math.positiveRemainingAmount(
                inputAmounts: [presignedInput.rewardAmount],
                fee: context.fee
            ).map { netRewardAmount in
                // add reward output from SCI
                builder.addOutput(
                    publicAddress: context.accountKey.publicAddress,
                    amount: netRewardAmount,
                    rng: seededRng
                ).map { incomeTxOutContext in
                    presignedIncomeTxOutContexts.append(incomeTxOutContext)
                }
            }
        }

        return payloadContexts.collectResult().flatMap { payloadContexts in
            changeContext.flatMap { changeContext in
                builder.build(rng: seededRng).map { transaction in
                    PendingTransaction(
                        transaction: transaction,
                        payloadTxOutContexts: payloadContexts,
                        changeTxOutContext: changeContext,
                        presignedInputIncomeTxOutContexts: presignedIncomeTxOutContexts)
                }
            }
        }
    }

    /// Builds the `TransactionBuilder` for `context`.
    ///
    /// Shared so that `build` and `txOutContexts` cannot construct it
    /// differently: the fog resolver decides whether each output draws a real
    /// fog hint or a fake one, and the block version decides where change is
    /// sent, so a builder made two ways could produce two sets of keys.
    static func makeBuilder(
        context: TransactionBuilder.Context
    ) -> Result<TransactionBuilder, TransactionBuilderError> {
        do {
            return .success(try TransactionBuilder(
                context: InnerContext(
                    blockVersion: context.blockVersion,
                    fogResolver: context.fogResolver,
                    memoBuilder: context.memoType.createMemoBuilder(accountKey: context.accountKey),
                    tombstoneBlockIndex: context.tombstoneBlockIndex,
                    fee: context.fee)))
        } catch {
            guard let error = error as? TransactionBuilderError else {
                return .failure(.invalidInput("Unknown Error"))
            }
            return .failure(error)
        }
    }

    /// Adds the payload and change outputs to `builder`, in this order.
    ///
    /// Every draw the transaction makes from `rng` before it is built happens
    /// here, so a given seed always produces the same outputs. `build` and
    /// `txOutContexts` both route through this rather than adding outputs
    /// themselves, so the keys one derives cannot drift from the keys the
    /// other builds.
    ///
    /// Amounts do not influence the keys — nothing between the draws consumes
    /// randomness — but the recipients do, because the fog hint drawn ahead of
    /// each output's private key differs for an address with a fog report and
    /// one without.
    static func addOutputs(
        context: TransactionBuilder.Context,
        builder: TransactionBuilder,
        possibleTransaction: PossibleTransaction,
        rng: MobileCoinRng
    ) -> ([Result<TxOutContext, TransactionBuilderError>],
          Result<TxOutContext, TransactionBuilderError>) {
        let payloadContexts = possibleTransaction.outputs.map { output in
            builder.addOutput(
                publicAddress: output.recipient,
                amount: output.amount,
                rng: rng
            )
        }

        let changeContext = changeContext(
            blockVersion: context.blockVersion,
            accountKey: context.accountKey,
            builder: builder,
            changeAmount: possibleTransaction.changeAmount,
            rng: rng)

        return (payloadContexts, changeContext)
    }

    static func changeContext(
        blockVersion: BlockVersion,
        accountKey: AccountKey,
        builder: TransactionBuilder,
        changeAmount: Amount,
        rng: MobileCoinRng
    ) -> Result<TxOutContext, TransactionBuilderError> {
        switch blockVersion {
        case .legacy:
            // Clients built for BlockVersion == 0 (.legacy) will have trouble finding txOuts
            // on the new change subaddress (max - 1), so we will emulate legacy behavior.
            return builder.addOutput(
                publicAddress: accountKey.publicAddress,
                amount: changeAmount,
                rng: rng)
        default:
            return builder.addChangeOutput(
                accountKey: accountKey,
                amount: changeAmount,
                rng: rng)
        }
    }

    static func output(
        publicAddress: PublicAddress,
        amount: Amount,
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
        amount: Amount,
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
        .map { changeValue in
            if let posChangeValue = PositiveUInt64(changeValue) {
                return PossibleTransaction(outputs, Amount(posChangeValue.value, in: fee.tokenId))
            } else {
                return PossibleTransaction(outputs, Amount(0, in: fee.tokenId))
            }
        }
    }

    private static func outputsAddingChangeOutputForSCI(
        inputs: [PreparedTxInput],
        presignedInput: SignedContingentInput
    ) -> Result<PossibleTransaction, TransactionBuilderError> {

        let reqdAmt = presignedInput.requiredAmount

        // fee covered by sci reward amount
        let zeroFee = Amount(0, in: presignedInput.requiredAmount.tokenId)

        return Math.remainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            outputValues: [reqdAmt.value],
            fee: zeroFee
        )
        .map { changeValue in
            if let posChangeValue = PositiveUInt64(changeValue) {
                return PossibleTransaction([], Amount(posChangeValue.value, in: reqdAmt.tokenId))
            } else {
                return PossibleTransaction([], Amount(0, in: reqdAmt.tokenId))
            }
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
        amount: Amount,
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
        amount: Amount,
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
