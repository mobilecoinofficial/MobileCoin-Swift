//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class SeedableRngUnitTests: XCTestCase {

    func testSeedableFromSeedBytes() throws {
        // matching seed RNGs
        let rng1 = MobileCoinChaCha20Rng()
        let rng2 = MobileCoinChaCha20Rng(seed: rng1.seed)

        // differing seed RNG
        let rngX = MobileCoinChaCha20Rng()

        // verify seed randomization
        XCTAssertNotEqual(rng1.seed, rngX.seed, "RNG seeds should be differ and be random")
        XCTAssertEqual(rng1.seed, rng2.seed, "RNG seeds should match")
        XCTAssertNotEqual(rng1.next(), rngX.next(), "RNG values should differ w/differing seeds")

        // bump rng2 to catch up w/rng1
        _ = rng2.next()

        for _ in 1...10000 {
            XCTAssertEqual(rng1.next(), rng2.next(), "Same-seed RNGs should gen matching values")
        }
    }

    /// The seed a `TransactionBuilder` runs on is derived from the caller's
    /// RNG, and the two platforms derive it differently: this takes four
    /// `next()` UInt64s reduced into `Data`, where android-sdk takes
    /// `nextBytes(32)`. Both should yield the same 32 bytes off the same
    /// stream, because `next_u64` combines two u32 words as `w[i+1] << 32 |
    /// w[i]` and its little-endian bytes are exactly what `fill_bytes` writes
    /// for those words.
    ///
    /// Nothing else in the derivation is platform-specific — the builder's own
    /// stream and `add_output` are the same Rust through FFI — so this hop is
    /// the only place iOS and Android can disagree about a TxOut public key.
    /// `TxOutContextsTest#testBuilderSeedIsPlatformIndependent` in android-sdk
    /// asserts the same seed against the same expected bytes.
    func testBuilderSeedIsPlatformIndependent() throws {
        // "goto https://buy.mobilecoin.com\0", the seed android-sdk's
        // TxOutContextsTest uses, so both assert against one stream.
        let seed = try XCTUnwrap(RngSeed(Data("goto https://buy.mobilecoin.com\0".utf8)))

        let builderSeed = try XCTUnwrap(MobileCoinChaCha20Rng(rngSeed: seed).generateRngSeed())

        XCTAssertEqual(
            builderSeed.data.hexEncodedString(),
            "7606151ea291727acfbea41cc1e71d57b1e219e3aeb8accfa3a9bcbc190bc3f5")
    }
}
