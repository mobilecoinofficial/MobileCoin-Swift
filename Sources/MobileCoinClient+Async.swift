//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

#if swift(>=5.5)

@available(iOS 13.0, *)
extension MobileCoinClient {

    @discardableResult
    public func updateBalances() async throws -> Balances {
        try await withCheckedThrowingContinuation { continuation in
            updateBalances {
                continuation.resume(with: $0)
            }
        }
    }

    @discardableResult
    public func blockVersion() async throws -> BlockVersion {
        try await withCheckedThrowingContinuation { continuation in
            blockVersion {
                continuation.resume(with: $0)
            }
        }
    }

    public func prepareTransaction(
        to recipient: PublicAddress,
        amount: Amount,
        fee: UInt64,
        memoType: MemoType = .recoverable
    ) async throws -> PendingSinglePayloadTransaction {
        try await withCheckedThrowingContinuation { continuation in
            prepareTransaction(to: recipient,
                               memoType: memoType,
                               amount: amount,
                               fee: fee) {
                continuation.resume(with: $0)
            }
        }
    }

    public func prepareTransaction(
        to recipient: PublicAddress,
        amount: Amount,
        fee: UInt64,
        rng: MobileCoinRng,
        memoType: MemoType = .recoverable
    ) async throws -> PendingSinglePayloadTransaction {
        try await withCheckedThrowingContinuation { continuation in
            prepareTransaction(to: recipient,
                               memoType: memoType,
                               amount: amount,
                               fee: fee,
                               rng: rng) {
                continuation.resume(with: $0)
            }
        }
    }

    @discardableResult
    public func submitTransaction(
        transaction: Transaction
    ) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { continuation in
            submitTransaction(transaction: transaction) {
                continuation.resume(with: $0)
            }
        }
    }

    public func estimateTotalFee(
        toSendAmount amount: Amount,
        feeLevel: FeeLevel = .minimum
    ) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { continuation in
            estimateTotalFee(toSendAmount: amount,
                             feeLevel: feeLevel) {
                continuation.resume(with: $0)
            }
        }
    }

    public func status(
        of transaction: Transaction
    ) async throws -> TransactionStatus {
        try await withCheckedThrowingContinuation { continuation in
            status(of: transaction) {
                continuation.resume(with: $0)
            }
        }
    }

}

#endif
