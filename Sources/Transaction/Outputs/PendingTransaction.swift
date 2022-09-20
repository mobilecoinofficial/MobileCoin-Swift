//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct PendingTransaction {
    public let transaction: Transaction
    public let payloadTxOutContexts: [TxOutContext]
    public var changeTxOutContext: TxOutContext

    public var receipts: [Receipt] {
        (payloadTxOutContexts + [changeTxOutContext]).map({
            $0.receipt
        })
    }

    var singlePayload: PendingSinglePayloadTransaction {
        PendingSinglePayloadTransaction(
            transaction: transaction,
            payloadTxOutContext: payloadTxOutContexts[0],
            changeTxOutContext: changeTxOutContext)
    }
}

public struct PendingSinglePayloadTransaction {
    public let transaction: Transaction
    public let payloadTxOutContext: TxOutContext
    public var changeTxOutContext: TxOutContext

    public var receipt: Receipt {
        payloadTxOutContext.receipt
    }
}

extension PendingTransaction: Equatable, Hashable {}
extension PendingSinglePayloadTransaction: Equatable {}

extension PendingSinglePayloadTransaction {
    func isIdempotent(_ lhs: PendingSinglePayloadTransaction) -> Bool {
        Self.areIdempotent(self, lhs)
    }

    static func areIdempotent(
        _ rhs: PendingSinglePayloadTransaction,
        _ lhs: PendingSinglePayloadTransaction
    ) -> Bool {
        rhs.payloadTxOutContext.txOutPublicKey == lhs.payloadTxOutContext.txOutPublicKey
    }
}

extension PendingTransaction {
    func isIdempotent(_ lhs: PendingTransaction) -> Bool {
        Self.areIdempotent(self, lhs)
    }

    static func areIdempotent(
        _ rhs: PendingTransaction,
        _ lhs: PendingTransaction
    ) -> Bool {
        rhs.payloadTxOutContexts.map {
            $0.txOutPublicKey
        } == lhs.payloadTxOutContexts.map {
            $0.txOutPublicKey
        }
    }
}
