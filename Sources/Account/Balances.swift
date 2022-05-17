//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct Balances {
    public let balances: [TokenId: Balance]
    public var tokenIds: Set<TokenId> {
        Set(balances.keys)
    }
    
    var mobBalance: Balance {
        guard let balance = balances[.MOB] else {
            return Balance(
                amountLow: 0,
                amountHigh: 0,
                blockCount: blockCount,
                tokenId: .MOB)
        }
        return balance
    }
    
    let blockCount: UInt64
    
    init(balances: [Balance], blockCount: UInt64) {
        self.balances = balances.reduce(into: [TokenId:Balance](), { result, balance in
            result[balance.tokenId] = balance
        })
        self.blockCount = blockCount
    }
}
