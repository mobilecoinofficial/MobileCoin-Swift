//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct DestinationMemo {
    let memoData: Data64
    let addressHash: AddressHash
    let numberOfRecipients: UInt8
    let fee: UInt64
    let totalOutlay: UInt64
}

struct RecoverableDestinationMemo {
    let memoData: Data64
    let addressHash: AddressHash
    
    init?(_ memoData: Data64) {
        guard let addressHash = DestinationMemoUtils.getAddressHash(memoData: memoData) else {
            return nil
        }
        self.memoData = memoData
        self.addressHash = addressHash
    }

    func recover(txOut: TxOutProtocol, accountKey: AccountKey) -> DestinationMemo? {
        guard
            DestinationMemoUtils.isValid(txOut: txOut, accountKey: accountKey),
            let addressHash = DestinationMemoUtils.getAddressHash(memoData: memoData),
            let numberOfRecipients = DestinationMemoUtils.getNumberOfRecipients(memoData: memoData),
            let fee = DestinationMemoUtils.getFee(memoData: memoData),
            let totalOutlay = DestinationMemoUtils.getTotalOutlay(memoData: memoData)
        else {
            return nil
        }
        return DestinationMemo(memoData: memoData, addressHash: addressHash, numberOfRecipients: numberOfRecipients, fee: fee, totalOutlay: totalOutlay)
    }
    
    init?(_ memoData: Data64, txOut: TxOutProtocol, accountKey: AccountKey) {

    }
}
