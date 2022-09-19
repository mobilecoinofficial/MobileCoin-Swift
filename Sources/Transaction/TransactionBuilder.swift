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

    private init(
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver = FogResolver(),
        memoBuilder: TxOutMemoBuilder = DefaultMemoBuilder(),
        blockVersion: BlockVersion
    ) throws {
        self.tombstoneBlockIndex = tombstoneBlockIndex
        self.memoBuilder = memoBuilder
        let result: Result<OpaquePointer, TransactionBuilderError>
        result = memoBuilder.withUnsafeOpaquePointer { memoBuilderPtr in
            fogResolver.withUnsafeOpaquePointer { fogResolverPtr in
                // Safety: mc_transaction_builder_create should never return nil.
                withMcError { errorPtr in
                    mc_transaction_builder_create(
                            fee.value,
                            fee.tokenId.value,
                            tombstoneBlockIndex,
                            fogResolverPtr,
                            memoBuilderPtr,
                            blockVersion,
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
        inputs: [PreparedTxInput],
        accountKey: AccountKey,
        to recipient: PublicAddress,
        memoType: MemoType,
        amount: PositiveUInt64,
        fee: Amount,
        tombstoneBlockIndex: UInt64,
        fogResolver: FogResolver,
        blockVersion: BlockVersion,
        rngSeed: RngSeed
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
            rngSeed: rngSeed
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
        rngSeed: RngSeed
    ) -> Result<PendingSinglePayloadTransaction, TransactionBuilderError> {
        Math.positiveRemainingAmount(
            inputValues: inputs.map { $0.knownTxOut.value },
            fee: fee
        ).map { outputAmount in
            PossibleTransaction([TransactionOutput(recipient, outputAmount)], nil)
        }.flatMap { possibleTransaction in
            build(
                inputs: inputs,
                accountKey: accountKey,
                possibleTransaction: possibleTransaction,
                memoType: memoType,
                fee: fee,
                tombstoneBlockIndex: tombstoneBlockIndex,
                fogResolver: fogResolver,
                blockVersion: blockVersion,
                rngSeed: rngSeed
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
        rngSeed: RngSeed
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        outputsAddingChangeOutput(
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
                rngSeed: rngSeed)
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
        rngSeed: RngSeed
    ) -> Result<PendingTransaction, TransactionBuilderError> {
        guard Math.totalOutlayCheck(for: possibleTransaction, fee: fee, inputs: inputs) else {
            return .failure(.invalidInput("Input values != output values + fee"))
        }

        let builder: TransactionBuilder
        do {
            builder = try TransactionBuilder(
                fee: fee,
                tombstoneBlockIndex: tombstoneBlockIndex,
                fogResolver: fogResolver,
                memoBuilder: memoType.createMemoBuilder(accountKey: accountKey),
                blockVersion: blockVersion)
        } catch {
            guard let error = error as? TransactionBuilderError else {
                return .failure(.invalidInput("Unknown Error"))
            }
            return .failure(error)
        }

        for input in inputs {
            if case .failure(let error) =
                builder.addInput(preparedTxInput: input, accountKey: accountKey)
            {
                return .failure(error)
            }
        }

        let seededRng = MobileCoinChaCha20Rng(rngSeed: rngSeed)

        let payloadContexts = possibleTransaction.outputs.map { output in
            builder.addOutput(
                publicAddress: output.recipient,
                amount: output.amount.value,
                rng: seededRng
            )
        }

        let changeContext = changeContext(
            blockVersion: blockVersion,
            accountKey: accountKey,
            builder: builder,
            changeAmount: possibleTransaction.changeAmount,
            rng: seededRng)

        return payloadContexts.collectResult().flatMap { payloadContexts in
            changeContext.flatMap { changeContext in
                builder.build(rng: seededRng).map { transaction in
                    PendingTransaction(
                        transaction: transaction,
                        payloadTxOutContexts: payloadContexts,
                        changeTxOutContext: changeContext)
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
                fee: Amount(value: 0, tokenId: .MOB),
                tombstoneBlockIndex: tombstoneBlockIndex,
                fogResolver: fogResolver,
                blockVersion: blockVersion)
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

    private func build(
        rng: MobileCoinRng
    ) -> Result<Transaction, TransactionBuilderError> {
        TransactionBuilderUtils.build(ptr: ptr, rng: rng)
    }
}
