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
    }
}

extension Account.TransactionEstimator {
    @available(*, deprecated, message: "Use amountTransferable(feeLevel:completion:) instead")
    func amountTransferable(feeLevel: FeeLevel)
        -> Result<UInt64, BalanceTransferEstimationError>
    {
        let txOuts = account.readSync { $0.unspentTxOuts }
        logger.info(
            "Calculating amountTransferable. unspentTxOutValues: " +
                "\(redacting: txOuts.map { $0.value })",
            logFunction: false)
        return txOutSelector.amountTransferable(feeLevel: feeLevel, txOuts: txOuts)
            .mapError {
                switch $0 {
                case .feeExceedsBalance(let reason):
                    return .feeExceedsBalance(reason)
                case .balanceOverflow(let reason):
                    return .balanceOverflow(reason)
                }
            }
            .map {
                logger.info("amountTransferable: \(redacting: $0)", logFunction: false)
                return $0
            }
    }

    @available(*, deprecated, message:
        "Use estimateTotalFee(toSendAmount:feeLevel:completion:) instead")
    func estimateTotalFee(toSendAmount amount: UInt64, feeLevel: FeeLevel)
        -> Result<UInt64, TransactionEstimationError>
    {
        logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
        guard amount > 0 else {
            let errorMessage = "Cannot spend 0 MOB"
            logger.error(errorMessage)
            return .failure(.invalidInput(errorMessage))
        }

        let txOuts = account.readSync { $0.unspentTxOuts }
        let totalFee = txOutSelector
            .estimateTotalFee(toSendAmount: amount, feeLevel: feeLevel, txOuts: txOuts)
            .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
            .map { $0.totalFee }
        logger.info("totalFee result: \(redacting: totalFee)")
        return totalFee
    }

    @available(*, deprecated, message:
        "Use requiresDefragmentation(toSendAmount:feeLevel:completion:) instead")
    func requiresDefragmentation(toSendAmount amount: UInt64, feeLevel: FeeLevel)
        -> Result<Bool, TransactionEstimationError>
    {
        logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
        guard amount > 0 else {
            let errorMessage = "Cannot spend 0 MOB"
            logger.error(errorMessage)
            return .failure(.invalidInput(errorMessage))
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
