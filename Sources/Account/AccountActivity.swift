//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

import Foundation

/// Provides a snapshot of account activity at a particular point in the ledger, as indicated by
/// `blockCount`.
public struct AccountActivity {
    public let allTxOuts: Set<OwnedTxOut>
    @available(*, deprecated, message: "use new allTxOuts property")
    public let txOuts: Set<OwnedTxOut>
    public let blockCount: UInt64

    init(txOuts: [OwnedTxOut], blockCount: UInt64) {
        self.allTxOuts = Set(txOuts)
        self.txOuts = self.allTxOuts.filter { $0.tokenId == .MOB }
        self.blockCount = blockCount
    }
}
