//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation


struct SenderMemo {
    let memoData: Data64
    let addressHash: AddressHash
}

struct RecoverableSenderMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let accountKey: AccountKey
    let txOut: TxOutProtocol

    init?(_ memoData: Data64, accountKey: AccountKey, txOut: TxOutProtocol) {
        guard let addressHash = SenderMemoUtils.getAddressHash(memoData: memoData) else {
            return nil
        }
        self.memoData = memoData
        self.addressHash = addressHash
        self.accountKey = accountKey
        self.txOut = txOut
    }

    func recover(senderPublicAddress: PublicAddress) -> SenderMemo? {
        guard SenderMemoUtils.isValid(memoData: memoData,
                                   senderPublicAddress: senderPublicAddress,
                                   receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
                                   txOutPublicKey: txOut.publicKey)
        else {
            return nil
        }
        return SenderMemo(memoData: memoData, addressHash: addressHash)
    }
}

extension RecoverableSenderMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.memoData.hexEncodedString() == rhs.memoData.hexEncodedString()
    }
}
