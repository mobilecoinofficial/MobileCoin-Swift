//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct MobileCoinDefaultRng: MobileCoinRng {
    public func nextUInt64() -> UInt64 {
        securityRNG()
    }
}
