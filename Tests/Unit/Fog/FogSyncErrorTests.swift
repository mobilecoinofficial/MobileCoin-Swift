//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class FogSyncErrorTests: XCTestCase {

    func testZero() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(0)
        syncChecker.setViewsHighestKnownBlock(0)
        XCTAssertEqual(syncChecker.currentBlockIndex, 0)
    }

    func testLedgerHigher() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(10)
        syncChecker.setViewsHighestKnownBlock(0)
        XCTAssertEqual(syncChecker.currentBlockIndex, 0)
    }

    func testViewLedgerTen() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(10)
        syncChecker.setViewsHighestKnownBlock(10)
        XCTAssertEqual(syncChecker.currentBlockIndex, 10)
    }

    func testViewHigher() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(10)
        syncChecker.setViewsHighestKnownBlock(20)
        XCTAssertEqual(syncChecker.currentBlockIndex, 10)
    }

}
