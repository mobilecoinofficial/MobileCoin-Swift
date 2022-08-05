//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public protocol MobileCoinRng {
    func nextUInt64() -> UInt64
}

public enum MobileCoinRngOption {
    case defaultRng(MobileCoinDefaultRng)
    case seedable(MobileCoinSeedableRng)
}
