//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class MobileCoinChaCha20Rng: MobileCoinSeedableRng {
    private var ptr: OpaquePointer

    override init(seed: Data32) {
        var cc20ptr: OpaquePointer?
        seed.asMcBuffer { bytesBufferPtr in
            cc20ptr = withMcInfallible {
                mc_chacha20_rng_create_with_bytes(bytesBufferPtr)
            }
        }
        ptr = withMcInfallible {
            cc20ptr
        }
        super.init(seed: seed)
    }

    override var wordPos: Data16 {
        get {
            let wordPosData = Data16()

            wordPosData.asMcBuffer { buffer in
                mc_chacha20_get_word_pos(ptr, buffer)
            }

            return wordPosData
        }
        set(wordpos) {
            wordpos.asMcBuffer { bytesBufferPtr in
                mc_chacha20_set_word_pos(ptr, bytesBufferPtr)
            }
        }
    }

    deinit {
        mc_chacha20_rng_free(ptr)
    }

    override func nextUInt64() -> UInt64 {
        mc_chacha20_rng_next_long(ptr)
    }
}
