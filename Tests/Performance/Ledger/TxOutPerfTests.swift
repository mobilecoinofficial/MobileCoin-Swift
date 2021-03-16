//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TxOutPerfTests: PerformanceTestCase {

    func testPerformanceKeyImage() throws {
        let fixture = try TxOut.Fixtures.Default()
        let txOut = fixture.txOut
        let recipientAccountKey = fixture.recipientAccountKey

        measure {
            XCTAssertNotNil(txOut.keyImage(accountKey: recipientAccountKey))
        }
    }

    func testPerformanceValue() throws {
        let fixture = try TxOut.Fixtures.Default()
        let txOut = fixture.txOut
        let recipientAccountKey = fixture.recipientAccountKey

        measure {
            XCTAssertNotNil(txOut.value(accountKey: recipientAccountKey))
        }
    }

}
