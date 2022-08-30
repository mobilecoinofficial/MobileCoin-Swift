//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

public final class MobileCoinChaCha20Rng: MobileCoinRng {
    // forcing early initialization so self can be captured in the
    // below init()...but I'm sure there's a better way to work around this
    private var ptr = withMcInfallibleReturningOptional {
        OpaquePointer(bitPattern: 1)
    }

    public var seed = Data()

    init(seed32: Data32) {
        super.init()

        seed32.asMcBuffer { bytesBufferPtr in
            switch withMcError({ errorPtr in
                mc_chacha20_rng_create_with_bytes(bytesBufferPtr, &errorPtr)
            }) {
            case .success(let cc20ptr):
                ptr = cc20ptr
            case .failure(let error):
                switch error.errorCode {
                case .panic:
                    logger.fatalError(
                        "LibMobileCoin panic error: \(redacting: error.description)")
                default:
                    // Safety: mc_chacha20_rng_create_with_bytes should not throw
                    // non-documented errors.
                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
                }
            }
        }

        self.seed = seed32.data
    }

    public convenience init(seed: Data = .secRngGenBytes(32)) {
        let seed32: Data32 = withMcInfallibleReturningOptional {
            Data32(seed)
        }

        self.init(seed32: seed32)
    }

    public func wordPos() -> Data {
        let wordPosData = Data16()
        wordPosData.asMcBuffer { buffer in
            switch withMcError({ errorPtr in
                mc_chacha20_rng_get_word_pos(ptr, buffer, &errorPtr)
            }) {
            case .success:
                break
            case .failure(let error):
                switch error.errorCode {
                case .panic:
                    logger.fatalError(
                        "LibMobileCoin panic error: \(redacting: error.description)")
                default:
                    // Safety: mc_chacha20_rng_get_word_pos should not throw
                    // non-documented errors.
                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
                }
            }
        }
        return wordPosData.data
    }

    public func setWordPos(_ wordPos: Data) {
        let wordPos16 = withMcInfallibleReturningOptional( {
            Data16(wordPos)
        })
        wordPos16.asMcBuffer { bytesBufferPtr in
            switch withMcError({ errorPtr in
                mc_chacha20_rng_set_word_pos(ptr, bytesBufferPtr, &errorPtr)
            }) {
            case .success:
                break
            case .failure(let error):
                switch error.errorCode {
                case .panic:
                    logger.fatalError(
                        "LibMobileCoin panic error: \(redacting: error.description)")
                default:
                    // Safety: mc_chacha20_set_word_pos should not throw
                    // non-documented errors.
                    logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
                }
            }
        }
    }

    public override func next() -> UInt64 {
        var next: UInt64

        switch withMcError({ errorPtr in
            mc_chacha20_rng_next_long(ptr, &errorPtr)
        }) {
        case .success(let nextVal):
            next = nextVal
        case .failure(let error):
            switch error.errorCode {
            case .panic:
                logger.fatalError(
                    "LibMobileCoin panic error: \(redacting: error.description)")
            default:
                // Safety: mc_chacha20_rng_free should not throw
                // non-documented errors.
                logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
            }
        }
        return next
    }

    deinit {
        mc_chacha20_rng_free(ptr)
    }
}
