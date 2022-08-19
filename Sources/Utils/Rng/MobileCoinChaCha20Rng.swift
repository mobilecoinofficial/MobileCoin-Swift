//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

public final class MobileCoinChaCha20Rng: MobileCoinRng {
    private var ptr: OpaquePointer
    public let seed: Data

    init(seed32: Data32) {
        var cc20ptr: OpaquePointer?
        seed32.asMcBuffer { bytesBufferPtr in
            cc20ptr = withMcInfallible {
                mc_chacha20_rng_create_with_bytes(bytesBufferPtr)
            }
        }
        ptr = withMcInfallible {
            cc20ptr
        }

        self.seed = seed32.data
        super.init()
    }

    convenience init(seed: Data = Data.secRngGenBytes(32)) {
        let seed32: Data32 = withMcInfallibleReturningOptional {
            Data32(seed)
        }

        self.init(seed32: seed32)
    }

    public var wordPos: Data {
        get {
            let wordPosData = Data16()

            wordPosData.asMcBuffer { buffer in
                mc_chacha20_get_word_pos(ptr, buffer)
            }

            return wordPosData.data
        }
        set(wordPos) {
            let wordPos16 = withMcInfallibleReturningOptional( {
                Data16(wordPos)
            })
            wordPos16.asMcBuffer { bytesBufferPtr in
                mc_chacha20_set_word_pos(ptr, bytesBufferPtr)
            }
        }
    }

    deinit {
        mc_chacha20_rng_free(ptr)
    }

    public override func next() -> UInt64 {
        mc_chacha20_rng_next_long(ptr)
    }
}
