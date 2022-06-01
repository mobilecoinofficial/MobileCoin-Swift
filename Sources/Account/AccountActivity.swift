//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

/// Provides a snapshot of account activity at a particular point in the ledger, as indicated by
/// `blockCount`.
public struct AccountActivity {
    public let txOuts: Set<OwnedTxOut>
    public let blockCount: UInt64
    public let tokenId: TokenId

    init(txOuts: [OwnedTxOut], blockCount: UInt64, tokenId: TokenId) {
        self.txOuts = Set(txOuts)
        self.blockCount = blockCount
        self.tokenId = tokenId
    }
}
