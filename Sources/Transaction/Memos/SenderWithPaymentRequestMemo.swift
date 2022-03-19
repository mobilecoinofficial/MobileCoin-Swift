//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// TODO - Decide how to manage isValid for memo's where senderPublicAddress not nearby ?
struct SenderWithPaymentRequestMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let paymentRequestId: UInt64

    init?(_ memoData: Data64, addressHash: AddressHash, paymentRequestId: UInt64) {
        self.memoData = memoData
        self.addressHash = addressHash
        self.paymentRequestId = paymentRequestId
    }

    init?(_ memoData: Data64, senderPublicAddress: PublicAddress, accountKey: AccountKey, txOut: TxOutProtocol) {
        guard
            let addressHash = SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData),
            SenderWithPaymentRequestMemoUtils.isValid(memoData: memoData,
                                       senderPublicAddress: senderPublicAddress,
                                       receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
                                       txOutPublicKey: txOut.publicKey),
            let paymentRequestId = SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData)
        else {
            return nil
        }
        self.init(memoData, addressHash: addressHash, paymentRequestId: paymentRequestId)
    }
}
