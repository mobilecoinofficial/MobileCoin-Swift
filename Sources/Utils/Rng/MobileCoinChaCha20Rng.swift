//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class MobileCoinChaCha20Rng: MobileCoinSeedableRng {
    private var ptr: OpaquePointer
    var seed: UInt64 = 0
    var seedBytes = Data32()
    var wordPos = [UInt64]()

    init(longSeed: UInt64) {
        seed = longSeed
        ptr = withMcInfallible {
            mc_chacha20_rng_create_with_long(longSeed)
        }
    }

    init(bytes: Data32) {
        seedBytes = bytes

        var cc20ptr: OpaquePointer?
        bytes.asMcBuffer { bytesBufferPtr in
            cc20ptr = withMcInfallible {
                mc_chacha20_rng_create_with_bytes(bytesBufferPtr)
            }
        }
        ptr = withMcInfallible {
            cc20ptr
        }
    }

    deinit {
        mc_chacha20_rng_free(ptr)
    }
}

extension MobileCoinChaCha20Rng: MobileCoinRng {
    func nextUInt64() -> UInt64 {
        mc_chacha20_rng_next_long(ptr)
    }

    func withUnsafeOpaquePointer<R>(_ body: (OpaquePointer) throws -> R) rethrows -> R {
        try body(ptr)
    }
}
