//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension FogRngKey {
    enum Fixtures {}
}

extension FogRngKey.Fixtures {
    struct Default {
        let fogRngKey = FogRngKey(pubkey: Self.pubkey, version: Self.rngVersion)
    }
}

extension FogRngKey.Fixtures.Default {

    fileprivate static let pubkey = Data(repeating: 2, count: 32)
    fileprivate static let rngVersion: UInt32 = 0

}
