//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments

import Foundation

extension Account {
    struct TransactionOperations {
        private let serialQueue: DispatchQueue
        private let account: ReadWriteDispatchLock<Account>
        private let txOutSelector: TxOutSelector
        private let transactionPreparer: TransactionPreparer

        init(
            account: ReadWriteDispatchLock<Account>,
            fogMerkleProofService: FogMerkleProofService,
            fogResolverManager: FogResolverManager,
            txOutSelectionStrategy: TxOutSelectionStrategy,
            mixinSelectionStrategy: MixinSelectionStrategy,
            targetQueue: DispatchQueue?
        ) {
            self.serialQueue = DispatchQueue(
                label: "com.mobilecoin.\(Account.self).\(Self.self))",
                target: targetQueue)
            self.account = account
            self.txOutSelector = TxOutSelector(txOutSelectionStrategy: txOutSelectionStrategy)
            self.transactionPreparer = TransactionPreparer(
                accountKey: account.accessWithoutLocking.accountKey,
                fogMerkleProofService: fogMerkleProofService,
                fogResolverManager: fogResolverManager,
                mixinSelectionStrategy: mixinSelectionStrategy,
                targetQueue: targetQueue)
        }

        func prepareTransaction(
            to recipient: PublicAddress,
            amount: UInt64,
            fee: UInt64,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        ) {
            logger.info(
                "recipient: \(redacting: recipient), amount: \(redacting: amount), fee: \(fee)")
            guard amount > 0 else {
                logger.info("failure - Cannot spend 0 MOB")
                serialQueue.async {
                    completion(.failure(.invalidInput("Cannot spend 0 MOB")))
                }
                return
            }

            let (unspentTxOuts, ledgerBlockCount) =
                 account.readSync { ($0.unspentTxOuts, $0.knowableBlockCount) }
            let tombstoneBlockIndex = ledgerBlockCount + 50

            switch txOutSelector
                .selectTransactionInputs(amount: amount, fee: fee, fromTxOuts: unspentTxOuts)
                .mapError({ error -> TransactionPreparationError in
                    switch error {
                    case .insufficientTxOuts:
                        return .insufficientBalance()
                    case .defragmentationRequired:
                        return .defragmentationRequired()
                    }
                })
            {
            case .success(let txOutsToSpend):
                logger.info(
                    "success - txOutsToSpend: \(redacting: txOutsToSpend.map { $0.publicKey })")
                transactionPreparer.prepareTransaction(
                    inputs: txOutsToSpend,
                    recipient: recipient,
                    amount: amount,
                    fee: fee,
                    tombstoneBlockIndex: tombstoneBlockIndex,
                    completion: completion)
            case .failure(let error):
                logger.info("failure - error: \(error)")
                serialQueue.async {
                    completion(.failure(error))
                }
            }
        }

        func prepareTransaction(
            to recipient: PublicAddress,
            amount: UInt64,
            feeLevel: FeeLevel,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        ) {
            logger.info("recipient: \(redacting: recipient), amount: \(redacting: amount), " +
                "feeLevel: \(feeLevel)")
            guard amount > 0 else {
                logger.info("failure - Cannot spend 0 MOB")
                serialQueue.async {
                    completion(.failure(.invalidInput("Cannot spend 0 MOB")))
                }
                return
            }

            let (unspentTxOuts, ledgerBlockCount) =
                 account.readSync { ($0.unspentTxOuts, $0.knowableBlockCount) }
            let tombstoneBlockIndex = ledgerBlockCount + 50

            switch txOutSelector
                .selectTransactionInputs(
                    amount: amount,
                    feeLevel: feeLevel,
                    fromTxOuts: unspentTxOuts)
                .mapError({ error -> TransactionPreparationError in
                    switch error {
                    case .insufficientTxOuts:
                        return .insufficientBalance()
                    case .defragmentationRequired:
                        return .defragmentationRequired()
                    }
                })
            {
            case .success(let (inputs: inputs, fee: fee)):
                logger.info("success - fee: \(fee)")
                transactionPreparer.prepareTransaction(
                    inputs: inputs,
                    recipient: recipient,
                    amount: amount,
                    fee: fee,
                    tombstoneBlockIndex: tombstoneBlockIndex,
                    completion: completion)
            case .failure(let error):
                logger.info("failure - error: \(error)")
                serialQueue.async {
                    completion(.failure(error))
                }
            }
        }

        func prepareDefragmentationStepTransactions(
            toSendAmount amount: UInt64,
            feeLevel: FeeLevel,
            completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
        ) {
            logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
            guard amount > 0 else {
                logger.info("failure - Cannot spend 0 MOB")
                serialQueue.async {
                    completion(.failure(.invalidInput("Cannot spend 0 MOB")))
                }
                return
            }

            let (unspentTxOuts, ledgerBlockCount) =
                 account.readSync { ($0.unspentTxOuts, $0.knowableBlockCount) }
            let tombstoneBlockIndex = ledgerBlockCount + 50

            switch txOutSelector.selectInputsForDefragTransactions(
                toSendAmount: amount,
                feeLevel: feeLevel,
                fromTxOuts: unspentTxOuts)
            {
            case .success(let defragTxInputs):
                logger.info("success")
                defragTxInputs.mapAsync({ defragInputs, callback in
                    transactionPreparer.prepareSelfAddressedTransaction(
                        inputs: defragInputs.inputs,
                        fee: defragInputs.fee,
                        tombstoneBlockIndex: tombstoneBlockIndex,
                        completion: callback)
                }, serialQueue: serialQueue, completion: completion)
            case .failure:
                logger.info("failure")
                serialQueue.async {
                    completion(.failure(.insufficientBalance()))
                }
            }
        }
    }
}
