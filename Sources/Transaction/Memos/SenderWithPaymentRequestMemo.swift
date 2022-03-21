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
        guard SenderWithPaymentRequestMemoUtils.isValid(memoData: memoData,
                                       senderPublicAddress: senderPublicAddress,
                                       receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
                                       txOutPublicKey: txOut.publicKey) else {
            logger.debug("Memo did not validate")
            return nil
        }
        
        guard let paymentRequestId = SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData) else {
            logger.debug("Unable to get payment request id")
            return nil
        }
        
        guard let addressHash = SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData) else {
            logger.debug("Unable to get address hash")
            return nil
        }
        
        return SenderWithPaymentRequestMemo(memoData: memoData, addressHash: addressHash, paymentRequestId: paymentRequestId)
    }
}

extension RecoverableSenderWithPaymentRequestMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.memoData.hexEncodedString() == rhs.memoData.hexEncodedString()
    }
}
