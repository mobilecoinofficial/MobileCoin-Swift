//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

class MobileCoinChaCha20Rng: MobileCoinSeedableRng {
    var seed: UInt64
    var wordPos: [UInt64]

    private let rngPtr: OpaquePointer?

    init(longSeed: UInt64) {
        seed = longSeed
        wordPos = []

        rngPtr = mc_chacha20_rng_create_with_long(123)
    }
}

extension MobileCoinChaCha20Rng: MobileCoinRng {
    func nextUInt64() -> UInt64 {
        mc_chacha20_rng_next_long(rngPtr)
    }
}
