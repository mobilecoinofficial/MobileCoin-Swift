//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class FogSyncErrorConnectionIntTests: XCTestCase {
    func testFogConsensusSame() throws {
        try testSupportedProtocols(description: description) {
            try fogConsensusSame(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogConsensusSame(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 61
        let consensusIndex = fogIndex
        let shouldSucceed = true
        
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: shouldSucceed
        )
    }
    
    func testFogAheadConsensus() throws {
        try testSupportedProtocols(description: description) {
            try fogAheadConsensus(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogAheadConsensus(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 321
        let consensusIndex = fogIndex - 2
        let shouldSucceed = true
        
        // Fog ahead of Consensus should succeed (occurs when cached Consensus block info is used)
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: shouldSucceed
        )
    }
    
    func testFogBehindConsensusWithinDelta() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusWithinDeltaAheadConsensus(
                    transportProtocol: $0,
                    expectation: $1)
        }
    }
    
    func fogBehindConsensusWithinDeltaAheadConsensus(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 5234523462456
        let consensusIndex = fogIndex + MockFogSyncChecker.delta - 2
        let shouldSucceed = true
        
        // Fog behind but within delta should succeed
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: shouldSucceed
        )
    }
    
    func testFogBehindConsensusAtDelta() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusAtDelta(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogBehindConsensusAtDelta(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 60
        let consensusIndex = fogIndex + MockFogSyncChecker.delta
        let shouldSucceed = true
        
        // Fog behind at , should fail
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: shouldSucceed
        )
    }
    
    func testFogBehindConsensusOverDelta() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusOverDelta(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogBehindConsensusOverDelta(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 410
        let consensusIndex = fogIndex + MockFogSyncChecker.delta + 1
        
        // Fog behind over delta, should fail
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func testViewLedgerAndConsensusWithinDelta() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusWithinDelta(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusWithinDelta(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 234234235675
        let ledgerIndex = viewIndex - MockFogSyncChecker.delta + 2
        let consensusIndex = viewIndex
        
        // below delta, should pass
        try attemptRefresh(
            fogViewBlockIndex: viewIndex,
            fogLedgerBlockIndex: ledgerIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: true
        )
    }
    
    func testViewLedgerAndConsensusAtDelta() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusAtDelta(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusAtDelta(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 99
        let ledgerIndex = viewIndex + MockFogSyncChecker.delta + 1
        let consensusIndex = viewIndex + MockFogSyncChecker.delta / 2
        
        // at delta, should fail
        try attemptRefresh(
            fogViewBlockIndex: viewIndex,
            fogLedgerBlockIndex: ledgerIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func testViewLedgerAndConsensusOverDelta() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusOverDelta(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusOverDelta(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 170
        let ledgerIndex = viewIndex - MockFogSyncChecker.delta - 1
        let consensusIndex = viewIndex - MockFogSyncChecker.delta / 2
        
        // at delta, should fail
        try attemptRefresh(
            fogViewBlockIndex: viewIndex,
            fogLedgerBlockIndex: ledgerIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func attemptRefresh(
        fogViewBlockIndex: UInt64,
        fogLedgerBlockIndex: UInt64,
        consensusBlockIndex: UInt64,
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation,
        shouldSucceed: Bool
    ) throws {
        let mockSyncChecker = MockFogSyncChecker(
            viewIndex: fogViewBlockIndex,
            ledgerIndex: fogLedgerBlockIndex,
            consensusIndex: consensusBlockIndex)

        let client = try IntegrationTestFixtures.createMobileCoinClient(
            fogSyncChecker: mockSyncChecker,
            transportProtocol: transportProtocol)

        client.updateBalance {
            if shouldSucceed {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }
            } else {
                guard $0.failureOrFulfill(expectation: expect) != nil else { return }
            }

            if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }

            expect.fulfill()
        }
    }
    
}

class MockFogSyncChecker: FogSyncCheckable {
    var viewsHighestKnownBlock: UInt64
    var ledgersHighestKnownBlock: UInt64
    var consensusHighestKnownBlock: UInt64

    let maxAllowedBlockDelta: PositiveUInt64
    
    static let delta: UInt64 = 10
    
    init(viewIndex: UInt64, ledgerIndex: UInt64, consensusIndex: UInt64) {
        viewsHighestKnownBlock = viewIndex
        ledgersHighestKnownBlock = ledgerIndex
        consensusHighestKnownBlock = consensusIndex
        
        guard let positiveDelta = PositiveUInt64(Self.delta) else {
            logger.fatalError("Should never be reached as 10 > 0")
        }
        maxAllowedBlockDelta = positiveDelta
    }
    
    func setViewsHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
    
    func setLedgersHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
    
    func setConsensusHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
}
