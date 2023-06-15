//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension AccountActivity {
    public func describeUnspentTxOuts() -> String {
        [
            self.txOuts.filter { $0.spentBlock == nil }.map {
                "Unspent TxOut \($0.value) \($0.tokenId.name)"
            },
        ]
        .flatMap({ $0 })
        .joined(separator: ", \n")
    }
}
