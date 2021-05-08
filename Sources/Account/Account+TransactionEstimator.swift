//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Account {
    struct TransactionEstimator {
        private let serialQueue: DispatchQueue
        private let account: ReadWriteDispatchLock<Account>
        private let feeFetcher: BlockchainFeeFetcher
        private let txOutSelector: TxOutSelector

        init(
            account: ReadWriteDispatchLock<Account>,
            feeFetcher: BlockchainFeeFetcher,
            txOutSelectionStrategy: TxOutSelectionStrategy,
            targetQueue: DispatchQueue?
        ) {
            self.serialQueue = DispatchQueue(
                label: "com.mobilecoin.\(Account.self).\(Self.self))",
                target: targetQueue)
            self.account = account
            self.feeFetcher = feeFetcher
            self.txOutSelector = TxOutSelector(txOutSelectionStrategy: txOutSelectionStrategy)
        }

        func amountTransferable(
            feeLevel: FeeLevel,
            completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
        ) {
            feeFetcher.feeStrategy(for: feeLevel) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync { $0.unspentTxOuts }
                        logger.info(
                            "Calculating amountTransferable. unspentTxOutValues: " +
                                "\(redacting: txOuts.map { $0.value })",
                            logFunction: false)
                        return self.txOutSelector
                            .amountTransferable(feeStrategy: feeStrategy, txOuts: txOuts)
                            .mapError {
                                switch $0 {
                                case .feeExceedsBalance(let reason):
                                    return .feeExceedsBalance(reason)
                                case .balanceOverflow(let reason):
                                    return .balanceOverflow(reason)
                                }
                            }
                            .map {
                                logger.info(
                                    "amountTransferable: \(redacting: $0)",
                                    logFunction: false)
                                return $0
                            }
                    })
            }
        }

        func estimateTotalFee(
            toSendAmount amount: UInt64,
            feeLevel: FeeLevel,
            completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
        ) {
            logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
            guard amount > 0 else {
                let errorMessage = "Cannot spend 0 MOB"
                logger.error(errorMessage)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            feeFetcher.feeStrategy(for: feeLevel) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync { $0.unspentTxOuts }
                        let totalFee = self.txOutSelector
                            .estimateTotalFee(
                                toSendAmount: amount,
                                feeStrategy: feeStrategy,
                                txOuts: txOuts)
                            .mapError { _ in
                                TransactionEstimationFetcherError.insufficientBalance()
                            }
                            .map { $0.totalFee }
                        logger.info("totalFee result: \(redacting: totalFee)")
                        return totalFee
                    })
            }
        }

        func requiresDefragmentation(
            toSendAmount amount: UInt64,
            feeLevel: FeeLevel,
            completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
        ) {
            logger.info("toSendAmount: \(redacting: amount), feeLevel: \(feeLevel)")
            guard amount > 0 else {
                let errorMessage = "Cannot spend 0 MOB"
                logger.error(errorMessage)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            feeFetcher.feeStrategy(for: feeLevel) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync { $0.unspentTxOuts }
                        let requiresDefragmentation = self.txOutSelector
                            .estimateTotalFee(
                                toSendAmount: amount,
                                feeStrategy: feeStrategy,
                                txOuts: txOuts)
                            .mapError { _ in
                                TransactionEstimationFetcherError.insufficientBalance()
                            }
                            .map { $0.requiresDefrag }
                        logger.info(
                            "requiresDefragmentation result: \(redacting: requiresDefragmentation)")
                        return requiresDefragmentation
                    })
            }
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
        let feeStrategy = feeLevel.defaultFeeStrategy
        return txOutSelector.amountTransferable(feeStrategy: feeStrategy, txOuts: txOuts)
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
        let feeStrategy = feeLevel.defaultFeeStrategy
        let totalFee = txOutSelector
            .estimateTotalFee(toSendAmount: amount, feeStrategy: feeStrategy, txOuts: txOuts)
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
        let feeStrategy = feeLevel.defaultFeeStrategy
        let requiresDefragmentation = txOutSelector
            .estimateTotalFee(toSendAmount: amount, feeStrategy: feeStrategy, txOuts: txOuts)
            .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
            .map { $0.requiresDefrag }
        logger.info("requiresDefragmentation result: \(redacting: requiresDefragmentation)")
        return requiresDefragmentation
    }
}
