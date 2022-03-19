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

    init?(_ memoData: Data64) {
        guard let addressHash = SenderMemoUtils.getAddressHash(memoData: memoData) else {
            return nil
        }
        self.memoData = memoData
        self.addressHash = addressHash
    }

    func recover(senderPublicAddress: PublicAddress, accountKey: AccountKey, txOut: TxOutProtocol) -> SenderMemo? {
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
