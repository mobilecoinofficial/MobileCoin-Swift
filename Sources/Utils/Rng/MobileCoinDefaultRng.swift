//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public class MobileCoinDefaultRng: MobileCoinRng {
    public override func nextUInt64() -> UInt64 {
        securityRNG()
    }
}
