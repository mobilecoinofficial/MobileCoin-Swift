//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogRngPerfTests: PerformanceTestCase {

    override class var defaultInvocationOptions: XCTMeasureOptions.InvocationOptions {
        Self.manualStartStopOptions
    }

    func testPerformanceAdvance() {
        measure {
            let fixture = try? XCTUnwrap(try FogRng.Fixtures.Default())
            let rng = fixture?.fogRng

            startMeasuring()
            let output = try? XCTUnwrap(rng?.advance())
            stopMeasuring()

            XCTAssertEqual(
                output?.base64EncodedString(),
                fixture?.firstOutput.base64EncodedString())
        }
    }

}
