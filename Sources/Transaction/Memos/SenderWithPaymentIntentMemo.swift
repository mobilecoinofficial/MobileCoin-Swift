//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct SenderWithPaymentIntentMemo {
    public var memoData: Data { memoData64.data }
    public var addressHashHex: String { addressHash.hex }

    let memoData64: Data64
    let addressHash: AddressHash
    public let paymentIntentId: UInt64
}

extension SenderWithPaymentIntentMemo: Equatable, Hashable { }

struct RecoverableSenderWithPaymentIntentMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let txOutPublicKey: RistrettoPublic
    private let accountKey: AccountKey

    init(_ memoData: Data64, accountKey: AccountKey, txOutPublicKey: RistrettoPublic) {
        self.memoData = memoData
        self.addressHash = SenderWithPaymentIntentMemoUtils.getAddressHash(memoData: memoData)
        self.accountKey = accountKey
        self.txOutPublicKey = txOutPublicKey
    }

    func recover(senderPublicAddress: PublicAddress) -> SenderWithPaymentIntentMemo? {
        guard SenderWithPaymentIntentMemoUtils.isValid(
            memoData: memoData,
            senderPublicAddress: senderPublicAddress,
            receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
            txOutPublicKey: txOutPublicKey)
        else {
            logger.debug("Memo did not validate")
            return nil
        }

        let paymentIntId = SenderWithPaymentIntentMemoUtils.getPaymentIntentId(memoData: memoData)
        guard let paymentIntentId = paymentIntId else {
            logger.debug("Unable to get payment intent id")
            return nil
        }

        let addressHash = SenderWithPaymentIntentMemoUtils.getAddressHash(memoData: memoData)
        return SenderWithPaymentIntentMemo(
            memoData64: memoData,
            addressHash: addressHash,
            paymentIntentId: paymentIntentId)
    }

    func unauthenticatedMemo() -> SenderWithPaymentIntentMemo? {
        let paymentIntId = SenderWithPaymentIntentMemoUtils.getPaymentIntentId(memoData: memoData)
        guard let paymentIntentId = paymentIntId else {
            logger.debug("Unable to get payment intent id")
            return nil
        }

        let addressHash = SenderWithPaymentIntentMemoUtils.getAddressHash(memoData: memoData)
        return SenderWithPaymentIntentMemo(
            memoData64: memoData,
            addressHash: addressHash,
            paymentIntentId: paymentIntentId)
    }
}

extension RecoverableSenderWithPaymentIntentMemo: Hashable { }

extension RecoverableSenderWithPaymentIntentMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.memoData == rhs.memoData
    }
}
