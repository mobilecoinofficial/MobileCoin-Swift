//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogRngTests: XCTestCase {

    func testMake() throws {
        let fixture = try FogRng.Fixtures.Init()
        XCTAssertSuccess(FogRng.make(
            subaddressViewPrivateKey: fixture.subaddressViewPrivateKey,
            fogRngKey: fixture.fogRngKey))
    }

    func testOutputs() throws {
        let fixture = try FogRng.Fixtures.Default()
        let rng = fixture.fogRng
        for expectedOutput in fixture.outputs {
            XCTAssertEqual(rng.advance(), expectedOutput)
        }
    }

}
