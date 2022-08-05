//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public protocol MobileCoinSeedableRng: MobileCoinRng {
    var seed: UInt64 { get set }
    var wordPos: [UInt64] { get set }
}
