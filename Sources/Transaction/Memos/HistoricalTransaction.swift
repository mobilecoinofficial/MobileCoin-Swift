//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct HistoricalTransaction {
    public let memo: RecoveredMemo?
    public let txOut: OwnedTxOut
    public let contact: PublicAddressProvider?
}
