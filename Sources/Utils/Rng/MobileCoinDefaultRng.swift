//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct MobileCoinDefaultRng: MobileCoinRng {
    func nextUInt64() -> UInt64 {
        securityRNG()
    }
}
