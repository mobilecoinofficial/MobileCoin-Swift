//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Account {
    struct TransactionEstimator {
        private let account: ReadWriteDispatchLock<Account>
        private let txOutSelector: TxOutSelector

        init(
            account: ReadWriteDispatchLock<Account>,
            txOutSelectionStrategy: TxOutSelectionStrategy
        ) {
            self.account = account
            self.txOutSelector = TxOutSelector(txOutSelectionStrategy: txOutSelectionStrategy)
        }

        func amountTransferable(feeLevel: FeeLevel)
            -> Result<UInt64, BalanceTransferEstimationError>
        {
            logger.info("feeLevel: \(feeLevel)")
            let txOuts = account.readSync { $0.unspentTxOuts }
            let amountTransferable =
                txOutSelector.amountTransferable(feeLevel: feeLevel, txOuts: txOuts)
            logger.info("amountTransferable result: \(redacting: amountTransferable)")
            return amountTransferable
        }

        func estimateTotalFee(toSendAmount amount: UInt64, feeLevel: FeeLevel)
            -> Result<UInt64, TransactionEstimationError>
        {
            logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
            guard amount > 0 else {
                logger.info("failure - Cannot spend 0 MOB")
                return .failure(.invalidInput("Cannot spend 0 MOB"))
            }

            let txOuts = account.readSync { $0.unspentTxOuts }
            let totalFee = txOutSelector
                .estimateTotalFee(toSendAmount: amount, feeLevel: feeLevel, txOuts: txOuts)
                .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
                .map { $0.totalFee }
            logger.info("totalFee result: \(redacting: totalFee)")
            return totalFee
        }

        func requiresDefragmentation(toSendAmount amount: UInt64, feeLevel: FeeLevel)
            -> Result<Bool, TransactionEstimationError>
        {
            logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
            guard amount > 0 else {
                logger.info("failure - Cannot spend 0 MOB")
                return .failure(.invalidInput("Cannot spend 0 MOB"))
            }

            let txOuts = account.readSync { $0.unspentTxOuts }
            let requiresDefragmentation = txOutSelector
                .estimateTotalFee(toSendAmount: amount, feeLevel: feeLevel, txOuts: txOuts)
                .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
                .map { $0.requiresDefrag }
            logger.info("requiresDefragmentation result: \(redacting: requiresDefragmentation)")
            return requiresDefragmentation
        }
    }
}
