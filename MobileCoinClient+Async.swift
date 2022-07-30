//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains
// swiftlint:disable function_default_parameter_at_end

import Foundation

@available(iOS 13.0, *)
extension MobileCoinClient {

    @discardableResult
    public func updateBalances() async throws -> Balances {
        try await withCheckedThrowingContinuation { continuation in
            updateBalances { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @discardableResult
    public func blockVersion() async throws -> BlockVersion {
        try await withCheckedThrowingContinuation { continuation in
            blockVersion { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func  prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .recoverable,
        amount: Amount,
        fee: UInt64
    ) async throws -> PendingSinglePayloadTransaction {
        try await withCheckedThrowingContinuation { continuation in
            prepareTransaction(to: recipient,
                               memoType: memoType,
                               amount: amount,
                               fee: fee) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @discardableResult
    public func submitTransaction(
        transaction: Transaction
    ) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { continuation in
            submitTransaction(transaction: transaction) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func estimateTotalFee(
        toSendAmount amount: Amount,
        feeLevel: FeeLevel = .minimum
    ) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { continuation in
            estimateTotalFee(toSendAmount: amount,
                             feeLevel: feeLevel) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func status(
        of transaction: Transaction
    ) async throws -> TransactionStatus {
        try await withCheckedThrowingContinuation { continuation in
            status(of: transaction) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

}
