//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct SenderMemo {
    let memoData: Data64
    let addressHash: AddressHash

    init?(_ memoData: Data64, addressHash: AddressHash) {
        self.memoData = memoData
        self.addressHash = addressHash
    }

    init?(_ memoData: Data64, senderPublicAddress: PublicAddress, accountKey: AccountKey, txOut: TxOutProtocol) {
        guard
            let addressHash = SenderMemoUtils.getAddressHash(memoData: memoData),
            SenderMemoUtils.isValid(memoData: memoData,
                                   senderPublicAddress: senderPublicAddress,
                                   receipientViewPrivateKey: accountKey.subaddressViewPrivateKey,
                                   txOutPublicKey: txOut.publicKey)
        else {
            return nil
        }
        self.init(memoData, addressHash: addressHash)
    }
}
