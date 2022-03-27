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
    let txOutPublicKey: RistrettoPublic

    init(_ memoData: Data64, accountKey: AccountKey, txOutPublicKey: RistrettoPublic) {
        self.memoData = memoData
        self.addressHash = SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData)
        self.accountKey = accountKey
        self.txOutPublicKey = txOutPublicKey
    }

    func recover(senderPublicAddress: PublicAddress) -> SenderWithPaymentRequestMemo? {
        guard SenderWithPaymentRequestMemoUtils.isValid(memoData: memoData,
                                       senderPublicAddress: senderPublicAddress,
                                       receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
                                       txOutPublicKey: txOutPublicKey) else {
            logger.debug("Memo did not validate")
            return nil
        }
        
        guard let paymentRequestId = SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData) else {
            logger.debug("Unable to get payment request id")
            return nil
        }
        
        let addressHash = SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData)
        return SenderWithPaymentRequestMemo(memoData: memoData, addressHash: addressHash, paymentRequestId: paymentRequestId)
    }
}

extension RecoverableSenderWithPaymentRequestMemo: Hashable { }

extension RecoverableSenderWithPaymentRequestMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.memoData.hexEncodedString() == rhs.memoData.hexEncodedString()
    }
}
