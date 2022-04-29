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
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: true
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
        
        // Fog ahead of Consensus should succeed (occurs when cached Consensus block info is used)
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: true
        )
    }
    
    func testFogBehindConsensusWithinThreshold() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusWithinThresholdAheadConsensus(
                    transportProtocol: $0,
                    expectation: $1)
        }
    }
    
    func fogBehindConsensusWithinThresholdAheadConsensus(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 5234523462456
        let consensusIndex = fogIndex + MockFogSyncChecker.threshold - 2
        
        // Fog behind but within threshold should succeed
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: true
        )
    }
    
    func testFogBehindConsensusAtThreshold() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusAtThreshold(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogBehindConsensusAtThreshold(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 60
        let consensusIndex = fogIndex + MockFogSyncChecker.threshold - 1
        
        // Fog behind at threshold, should fail
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func testFogBehindConsensusOverThreshold() throws {
        try testSupportedProtocols(description: description) {
            try fogBehindConsensusOverThreshold(transportProtocol: $0, expectation: $1)
        }
    }
    
    func fogBehindConsensusOverThreshold(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let fogIndex: UInt64 = 410
        let consensusIndex = fogIndex + MockFogSyncChecker.threshold
        
        // Fog behind over threshold, should fail
        try attemptRefresh(
            fogViewBlockIndex: fogIndex,
            fogLedgerBlockIndex: fogIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func testViewLedgerAndConsensusWithinThreshold() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusWithinThreshold(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusWithinThreshold(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 234234235675
        let ledgerIndex = viewIndex - MockFogSyncChecker.threshold + 2
        let consensusIndex = viewIndex
        
        // below threshold, should pass
        try attemptRefresh(
            fogViewBlockIndex: viewIndex,
            fogLedgerBlockIndex: ledgerIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: true
        )
    }
    
    func testViewLedgerAndConsensusAtThreshold() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusAtThreshold(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusAtThreshold(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 99
        let ledgerIndex = viewIndex + MockFogSyncChecker.threshold + 1
        let consensusIndex = viewIndex + MockFogSyncChecker.threshold / 2
        
        // at threshold, should fail
        try attemptRefresh(
            fogViewBlockIndex: viewIndex,
            fogLedgerBlockIndex: ledgerIndex,
            consensusBlockIndex: consensusIndex,
            transportProtocol: transportProtocol,
            expectation: expect,
            shouldSucceed: false
        )
    }
    
    func testViewLedgerAndConsensusOverThreshold() throws {
        try testSupportedProtocols(description: description) {
            try viewLedgerAndConsensusOverThreshold(transportProtocol: $0, expectation: $1)
        }
    }
    
    func viewLedgerAndConsensusOverThreshold(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let viewIndex: UInt64 = 170
        let ledgerIndex = viewIndex - MockFogSyncChecker.threshold - 1
        let consensusIndex = viewIndex - MockFogSyncChecker.threshold / 2
        
        // at threshold, should fail
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
            transportProtocol:transportProtocol)

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
/**

 public void testFogSyncDetection() throws Exception {
     @Test
     public void testGetCurrentBlockIndex() {

         AccountKey accountKey = mock(AccountKey.class);
         TxOutStore txOutStore = new TxOutStore(accountKey);

         txOutStore.setLedgerBlockIndex(UnsignedLong.ZERO);
         txOutStore.setViewBlockIndex(UnsignedLong.ZERO);
         assertEquals(txOutStore.getCurrentBlockIndex(), UnsignedLong.ZERO);

         txOutStore.setLedgerBlockIndex(UnsignedLong.TEN);
         assertEquals(txOutStore.getCurrentBlockIndex(), UnsignedLong.ZERO);

         txOutStore.setViewBlockIndex(UnsignedLong.TEN);
         assertEquals(txOutStore.getCurrentBlockIndex(), UnsignedLong.TEN);

         txOutStore.setViewBlockIndex(UnsignedLong.TEN.add(UnsignedLong.TEN));
         assertEquals(txOutStore.getCurrentBlockIndex(), UnsignedLong.TEN);

     }
 **/

class MockFogSyncChecker: FogSyncCheckable {
    var viewsHighestKnownBlock: UInt64
    var ledgersHighestKnownBlock: UInt64
    var consensusHighestKnownBlock: UInt64

    let fogSyncThreshold: UInt64
    
    static let threshold: UInt64 = 10
    
    init(viewIndex: UInt64, ledgerIndex: UInt64, consensusIndex: UInt64) {
        viewsHighestKnownBlock = viewIndex
        ledgersHighestKnownBlock = ledgerIndex
        consensusHighestKnownBlock = consensusIndex
        fogSyncThreshold = Self.threshold
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
