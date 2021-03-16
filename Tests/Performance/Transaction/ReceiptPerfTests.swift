//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class ReceiptPerfTests: PerformanceTestCase {

    func testPerformanceValidateAndUnmaskValue() throws {
        let fixture = try Receipt.Fixtures.Default()
        measure {
            XCTAssertNotNil(fixture.receipt.validateAndUnmaskValue(accountKey: fixture.accountKey))
        }
    }

}
