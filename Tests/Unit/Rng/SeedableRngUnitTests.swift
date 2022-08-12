//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class SeedableRngUnitTests: XCTestCase {

    func testSeedableFromSeedBytes() throws {
        let seed1 = Data32(repeating: 5)
        let rng1 = MobileCoinChaCha20Rng(seed32: seed1)

        let seed2 = Data32(repeating: 10)
        let rng2 = MobileCoinChaCha20Rng(seed32: seed2)
        let rng3 = MobileCoinChaCha20Rng(seed32: seed2)

        XCTAssertNotNil(rng1)
        XCTAssertNotNil(rng2)
        XCTAssertNotNil(rng3)

        let val1 = rng1.nextUInt64()
        let val2 = rng2.nextUInt64()
        let val3 = rng3.nextUInt64()

        print("********** SEEDABLE RNG UNIT TESTS")
        print("********** val1 = \(val1)")
        print("********** val2 = \(val2)")
        print("********** val3 = \(val3)")

        XCTAssertNotEqual(val1, val2)
        XCTAssertEqual(val2, val3)
    }
}
