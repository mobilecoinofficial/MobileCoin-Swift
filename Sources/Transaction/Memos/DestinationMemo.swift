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
    
    init?(_ memoData: Data64, addressHash: AddressHash, numberOfRecipients: UInt8, fee: UInt64, totalOutlay: UInt64) {
        self.memoData = memoData
        self.addressHash = addressHash
        self.numberOfRecipients = numberOfRecipients
        self.fee = fee
        self.totalOutlay = totalOutlay
    }
    
    init?(_ memoData: Data64, txOut: TxOutProtocol, accountKey: AccountKey) {
        guard
            DestinationMemoUtils.isValid(txOut: txOut, accountKey: accountKey),
            let addressHash = DestinationMemoUtils.getAddressHash(memoData: memoData),
            let numberOfRecipients = DestinationMemoUtils.getNumberOfRecipients(memoData: memoData),
            let fee = DestinationMemoUtils.getFee(memoData: memoData),
            let totalOutlay = DestinationMemoUtils.getTotalOutlay(memoData: memoData)
        else {
            return nil
        }

        self.init(memoData, addressHash: addressHash, numberOfRecipients: numberOfRecipients, fee: fee, totalOutlay: totalOutlay)
    }
}
