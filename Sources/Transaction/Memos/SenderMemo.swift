//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct SenderMemo {
    public var memoData: Data { memoData64.data }
    let memoData64: Data64
    public var addressHashHex: String { addressHash.hex }
    let addressHash: AddressHash
}

extension SenderMemo: Equatable, Hashable { }

struct RecoverableSenderMemo {
    let memoData: Data64
    let addressHash: AddressHash
    private let accountKey: AccountKey
    let txOutPublicKey: RistrettoPublic

    init(_ memoData: Data64, accountKey: AccountKey, txOutPublicKey: RistrettoPublic) {
        self.memoData = memoData
        self.addressHash = SenderMemoUtils.getAddressHash(memoData: memoData)
        self.accountKey = accountKey
        self.txOutPublicKey = txOutPublicKey
    }

    func recover(senderPublicAddress: PublicAddress) -> SenderMemo? {
        guard SenderMemoUtils.isValid(
            memoData: memoData,
            senderPublicAddress: senderPublicAddress,
            receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
            txOutPublicKey: txOutPublicKey)
        else {
            return nil
        }
        return SenderMemo(memoData64: memoData, addressHash: addressHash)
    }
}

extension RecoverableSenderMemo: Hashable { }

extension RecoverableSenderMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.memoData == rhs.memoData
    }
}
