//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol MemoData {
    var addressHash: AddressHash { get }
}

public struct DestinationMemoData: MemoData {
    let addressHash: AddressHash
    let numberOfRecipients: Int
    let fee: UInt64
    let totalOutlay: UInt64
}

public struct SenderMemoData: MemoData {
    let addressHash: AddressHash
}

public struct SenderWithPaymentRequestMemoData: MemoData {
    let addressHash: AddressHash
}
