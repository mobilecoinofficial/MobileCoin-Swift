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
}
