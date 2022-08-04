//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class MobileCoinChaCha20Rng: MobileCoinSeedableRng {
    private let ptr: OpaquePointer
    var seed: UInt64
    var wordPos: [UInt64]

    init(longSeed: UInt64) {
        seed = longSeed
        wordPos = []
        ptr = withMcInfallible {
            mc_chacha20_rng_create_with_long(longSeed)
        }
    }

    deinit {
        mc_chacha20_rng_free(ptr)
    }
}

extension MobileCoinChaCha20Rng: MobileCoinRng {
    func nextUInt64() -> UInt64 {
        print("********** ChaCha20Rng seed \(seed))")
        print("********** ChaCha20Rng = \(ptr))")
        return mc_chacha20_rng_next_long(ptr)
    }

    func withUnsafeOpaquePointer<R>(_ body: (OpaquePointer) throws -> R) rethrows -> R {
        try body(ptr)
    }
}
