//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

class TxOutMemoBuilder {
    let ptr: OpaquePointer

    init(ptr: OpaquePointer) {
        self.ptr = ptr
    }
    
    static func createSenderAndDestinationMemoBuilder(accountKey: AccountKey) -> SenderAndDestinationMemoBuilder {
        SenderAndDestinationMemoBuilder(accountKey: accountKey)
    }
    
    static func createDefaultMemoBuilder() -> DefaultMemoBuilder {
        DefaultMemoBuilder()
    }
    
    static func createSenderPaymentRequestAndDestinationMemoBuilder(paymentRequestId: UInt64, accountKey: AccountKey) -> SenderPaymentRequestAndDestinationMemoBuilder {
        SenderPaymentRequestAndDestinationMemoBuilder(paymentRequestId: paymentRequestId, accountKey: accountKey)
    }
    
}


final class SenderAndDestinationMemoBuilder : TxOutMemoBuilder {
    init(
        accountKey: AccountKey
    ) {
        // Safety: mc_memo_builder_sender_and_destination_create should never return nil.
        let pointer = withMcInfallible {
            accountKey.withUnsafeCStructPointer { acctKeyPtr in
                mc_memo_builder_sender_and_destination_create(acctKeyPtr)
            }
        }
        super.init(ptr: pointer)
    }
}

final class DefaultMemoBuilder : TxOutMemoBuilder {
    init() {
        // Safety: mc_memo_builder_default_create should never return nil.
        let pointer = withMcInfallible {
            mc_memo_builder_default_create()
        }
        super.init(ptr: pointer)
    }
}

final class SenderPaymentRequestAndDestinationMemoBuilder : TxOutMemoBuilder {
    init(
        paymentRequestId requestId: UInt64,
        accountKey: AccountKey
    ) {
        // Safety: mc_memo_builder_sender_and_destination_create should never return nil.
        let pointer = withMcInfallible {
            accountKey.withUnsafeCStructPointer { acctKeyPtr in
                mc_memo_builder_sender_payment_request_and_destination_create(requestId, acctKeyPtr)
            }
        }
        super.init(ptr: pointer)
    }
}
