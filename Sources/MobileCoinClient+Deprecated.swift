//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable function_default_parameter_at_end multiline_function_chains let_var_whitespace

import Foundation

extension MobileCoinClient {

    @available(*, deprecated, message:
        """
        Deprecated in favor of `balance(for:TokenId)` which accepts a TokenId.
        `balance` will assume the default TokenId == .MOB // UInt64(0)

        Get a set of all tokenIds that are in TxOuts owned by this account with:

        `MobileCoinClient(...).accountTokenIds // Set<TokenId>`
        """)
    public var balance: Balance { balance(for: .MOB) }

    @available(*, deprecated, message:
        """
        Use the new `updateBalances(...)` that passes `Balances` into the completion closure.
        `Balances` is a new structure that holds multiple `Balance` structs for each known tokenId.

        ```
        public func updateBalances(
            completion: @escaping (Result<Balances, BalanceUpdateError>) -> Void
        )
        ```

        this function will return the `Balance` struct for the default TokenId == .MOB
        """)
    public func updateBalance(completion: @escaping (Result<Balance, ConnectionError>) -> Void) {
        updateBalances {
            completion($0.map({
                $0.mobBalance
            }).mapError({
                switch $0 {
                case .connectionError(let error):
                    return error
                case .fogSyncError(let error):
                    return ConnectionError.invalidServerResponse(error.description)
                }
            }))
        }
    }

    @available(*, deprecated, message:
        """
        Use the new `amountTransferable(...)` that accepts a `TokenId` as an input parameter.

        ```
        public func amountTransferable(
            tokenId: TokenId = .MOB
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
        )
        ```

        this function will return the amount transferable for the default TokenId == .MOB
        """)
    public func amountTransferable(
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
    ) {
        amountTransferable(tokenId: .MOB, feeLevel: feeLevel, completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `estimateTotalFee(...)` that accepts an `Amount` as an input parameter.

        ```
        public func estimateTotalFee(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
        )
        ```

        this function will estimate the total fee assuming the default TokenId == .MOB
        """)
    public func estimateTotalFee(
        toSendAmount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
    ) {
        estimateTotalFee(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel,
            completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `requiresDefragmentation(...)` that accepts an `Amount` as an input parameter.

        ```
        public func requiresDefragmentation(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
        )
        ```

        this function returns a Bool to the completion() assuming the default TokenId == .MOB
        """)
    public func requiresDefragmentation(
        toSendAmount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
    ) {
        requiresDefragmentation(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel,
            completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `prepareTransaction(...)` that accepts an `Amount` as an input parameter.

        ```
        public func prepareTransaction(
            to recipient: PublicAddress,
            memoType: MemoType = .unused,
            amount: Amount,
            fee: UInt64,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        )
        ```

        this function prepares a transaction assuming assuming the default TokenId == .MOB
        """)
    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .unused,
        amount value: UInt64,
        fee: UInt64,
        completion: @escaping (
            Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
        ) -> Void
    ) {
        prepareTransaction(
            to: recipient,
            memoType: memoType,
            amount: Amount(value: value, tokenId: .MOB),
            fee: fee) {
                completion($0.map({ ($0.transaction, $0.receipt) }))
        }

    }

    @available(*, deprecated, message:
        """
        Use the new `prepareTransaction(...)` that accepts an `Amount` as an input parameter.

        ```
        public func prepareTransaction(
            to recipient: PublicAddress,
            memoType: MemoType = .unused,
            amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        )
        ```

        this function prepares a transaction assuming assuming the default TokenId == .MOB
        """)
    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .unused,
        amount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (
            Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
        ) -> Void
    ) {
        prepareTransaction(
            to: recipient,
            memoType: memoType,
            amount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel) {
                completion($0.map { pending in
                    (pending.transaction, pending.receipt)
                })
        }
    }

    @available(*, deprecated, message:
        """
        Use the new `prepareDefragmentationStepTransactions(...)` that accepts an `Amount` as an
        input parameter.

        ```
        public func prepareDefragmentationStepTransactions(
            toSendAmount amount: Amount,
            recoverableMemo: Bool = false,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
        )
        ```

        this function prepares transactions assuming assuming the default TokenId == .MOB
        """)
    public func prepareDefragmentationStepTransactions(
        toSendAmount value: UInt64,
        recoverableMemo: Bool = false,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
    ) {
        prepareDefragmentationStepTransactions(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            recoverableMemo: false,
            feeLevel: feeLevel,
            completion: completion)
    }

}
