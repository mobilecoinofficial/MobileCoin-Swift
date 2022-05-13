//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct Balances {
    public let balances: [TokenId: Balance]
    public var tokenIds: Set<TokenId> {
        Set(balances.keys)
    }
    
    let blockCount: UInt64
}
