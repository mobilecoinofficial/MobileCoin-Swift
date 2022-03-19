//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// TODO - Decide how to manage isValid for memo's where senderPublicAddress not nearby ?
struct SenderWithPaymentRequestMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let paymentRequestId: UInt64
}

struct RecoverableSenderWithPaymentRequestMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let accountKey: AccountKey
    let txOut: TxOutProtocol

    init?(_ memoData: Data64, accountKey: AccountKey, txOut: TxOutProtocol) {
        guard let addressHash = SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData) else {
            return nil
        }
        self.memoData = memoData
        self.addressHash = addressHash
        self.accountKey = accountKey
        self.txOut = txOut
    }

    func recover(senderPublicAddress: PublicAddress) -> SenderWithPaymentRequestMemo? {
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
        return SenderWithPaymentRequestMemo(memoData: memoData, addressHash: addressHash, paymentRequestId: paymentRequestId)
    }
}
