//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

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

    func testViewLedgerArithmeticOverflowMaxMinusMaxMinusOne() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(UInt64.max)
        syncChecker.setViewsHighestKnownBlock(UInt64.max - 1)
        XCTAssertEqual(syncChecker.currentBlockIndex, (UInt64.max - 1))
        XCTAssertSuccess(syncChecker.inSync())

        syncChecker.setLedgersHighestKnownBlock(UInt64.max - 1)
        syncChecker.setViewsHighestKnownBlock(UInt64.max)
        XCTAssertEqual(syncChecker.currentBlockIndex, (UInt64.max - 1))
        XCTAssertSuccess(syncChecker.inSync())
    }

    func testViewLedgerArithmeticOverflowMaxMinusOne() throws {
        let syncChecker = FogSyncChecker()
        syncChecker.setLedgersHighestKnownBlock(UInt64.max)
        syncChecker.setViewsHighestKnownBlock(1)
        XCTAssertEqual(syncChecker.currentBlockIndex, 1)
        XCTAssertFailure(syncChecker.inSync())

        syncChecker.setLedgersHighestKnownBlock(1)
        syncChecker.setViewsHighestKnownBlock(UInt64.max)
        XCTAssertEqual(syncChecker.currentBlockIndex, 1)
        XCTAssertFailure(syncChecker.inSync())
    }

    func testConsensusArithmeticOverflowMaxMinusMaxMinusThreshold() throws {
        let syncChecker = FogSyncChecker()
        let delta = syncChecker.maxAllowedBlockDelta
        syncChecker.setLedgersHighestKnownBlock(UInt64.max - delta.value - 1)
        syncChecker.setViewsHighestKnownBlock(UInt64.max - delta.value - 1)
        syncChecker.setConsensusHighestKnownBlock(UInt64.max)
        XCTAssertFailure(syncChecker.inSync())

        syncChecker.setLedgersHighestKnownBlock(UInt64.max)
        syncChecker.setViewsHighestKnownBlock(UInt64.max)
        syncChecker.setConsensusHighestKnownBlock(UInt64.max - delta.value - 1)
        XCTAssertSuccess(syncChecker.inSync())
    }

    func testConsensusArithmeticOverflowMaxMinusOne() throws {
        let syncChecker = FogSyncChecker()

        syncChecker.setLedgersHighestKnownBlock(UInt64.max)
        syncChecker.setViewsHighestKnownBlock(UInt64.max)
        syncChecker.setConsensusHighestKnownBlock(1)
        XCTAssertSuccess(syncChecker.inSync())

        syncChecker.setLedgersHighestKnownBlock(1)
        syncChecker.setViewsHighestKnownBlock(1)
        syncChecker.setConsensusHighestKnownBlock(UInt64.max)
        XCTAssertFailure(syncChecker.inSync())
    }
}
