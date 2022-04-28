//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogBlockConnectionIntTests: XCTestCase {
    func testGetBlocks() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocks(transportProtocol: transportProtocol)
        }
    }

    func getBlocks(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        let range: Range<UInt64> = 1..<2
        request.rangeValues = [range]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.blocks.count, request.ranges.count)
            if let block = response.blocks.first {
                XCTAssertEqual(block.index, range.lowerBound)
                XCTAssertGreaterThan(block.globalTxoCount, 0)
                XCTAssertGreaterThan(block.outputs.count, 0)
            }
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetBlockZero() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlockZero(transportProtocol: transportProtocol)
        }
    }
    
    func getBlockZero(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<1]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, request.ranges.count)
            if let block = response.blocks.first {
                XCTAssertEqual(block.index, 0)
                // TODO: based on the proto comments, this should be 0, but it currently
                // returns txo count up to and including this block
                XCTAssertEqual(block.globalTxoCount, UInt64(0 + block.outputs.count))
                XCTAssertGreaterThan(block.outputs.count, 0)
            }
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 60)
    }

    func testGetBlocksReturnsNoBlocksWithoutRange() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocksReturnsNoBlocksWithoutRange(transportProtocol: transportProtocol)
        }
    }
    
    func getBlocksReturnsNoBlocksWithoutRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: FogLedger_BlockRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetBlocksReturnsNoBlocksForEmptyRange() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: transportProtocol)
        }
    }
    
    func getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<0]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testDoSGetBlocks() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try doSGetBlocks(transportProtocol: transportProtocol)
        }
    }
    
    func doSGetBlocks(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")
        let group = DispatchGroup()
        for _ in (0..<100) {
            var request = FogLedger_BlockRequest()
            request.rangeValues = [0..<UInt64.max]

            group.enter()
            try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
                guard let response = $0.successOrLeaveGroup(group) else { return }

                XCTAssertEqual(response.blocks.count, 0)
                XCTAssertGreaterThan(response.numBlocks, 0)
                XCTAssertGreaterThan(response.globalTxoCount, 0)

                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: transportProtocol)
        }
    }
    
    func invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [1..<2]
        try createFogBlockConnectionWithInvalidCredentials(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }
    
    /**
     
     @Test
     public void testFogSyncDetection() throws Exception {

         boolean exceptionThrown = false;

         final long testValueFog1 = 61L;
         final long testValueConsensus1 = testValueFog1;
         fogSyncTest_attemptRefresh(testValueFog1, testValueFog1, testValueConsensus1);// same index should succeed

         final long testValueFog2 = 321L;
         final long testValueConsensus2 = testValueFog2 - 2L;
         fogSyncTest_attemptRefresh(testValueFog2, testValueFog2, testValueConsensus2);// Fog ahead of Consensus should succeed (occurs when cached Consensus block info is used)

         final long testValueFog3 = 5234523462456L;
         final long testValueConsensus3 = testValueFog3 + TxOutStore.FOG_SYNC_THRESHOLD.longValue() - 2L;
         fogSyncTest_attemptRefresh(testValueFog3, testValueFog3, testValueConsensus3);// Fog behind but within threshold should succeed

         final long testValueFog4 = 60L;
         final long testValueConsensus4 = testValueFog4 + TxOutStore.FOG_SYNC_THRESHOLD.longValue() - 1L;
         try {
             fogSyncTest_attemptRefresh(testValueFog4, testValueFog4, testValueConsensus4);// Fog behind at threshold, should fail
         } catch(FogSyncException e) {
             exceptionThrown = true;
         }
         assertTrue(exceptionThrown);
         exceptionThrown = false;

         final long testValueFog5 = 410L;
         final long testValueConsensus5 = testValueFog5 + TxOutStore.FOG_SYNC_THRESHOLD.longValue();
         try {
             fogSyncTest_attemptRefresh(testValueFog5, testValueFog5, testValueConsensus5);// Fog behind over threshold, should fail
         } catch (FogSyncException e) {
             exceptionThrown = true;
         }
         assertTrue(exceptionThrown);
         exceptionThrown = false;

         final long testValueView6 = 234234235675L;
         final long testValueLedger6 = testValueView6 - TxOutStore.FOG_SYNC_THRESHOLD.longValue() + 2L;
         final long testValueConsensus6 = testValueView6;
         fogSyncTest_attemptRefresh(testValueView6, testValueLedger6, testValueConsensus6);// below threshold, should pass

         final long testValueView7 = 99L;
         final long testValueLedger7 = testValueView7 + TxOutStore.FOG_SYNC_THRESHOLD.longValue() + 1L;
         final long testValueConsensus7 = testValueView7 + TxOutStore.FOG_SYNC_THRESHOLD.longValue() / 2;
         try {
             fogSyncTest_attemptRefresh(testValueView7, testValueLedger7, testValueConsensus7);// at threshold, should fail
         } catch(FogSyncException e) {
             exceptionThrown = true;
         }
         assertTrue(exceptionThrown);
         exceptionThrown = false;

         final long testValueView8 = 170L;
         final long testValueLedger8 = testValueView8 - TxOutStore.FOG_SYNC_THRESHOLD.longValue() - 1L;
         final long testValueConsensus8 = testValueView8 - TxOutStore.FOG_SYNC_THRESHOLD.longValue() / 2;
         try {
             fogSyncTest_attemptRefresh(testValueView8, testValueLedger8, testValueConsensus8);// at threshold, should fail
         } catch(FogSyncException e) {
             exceptionThrown = true;
         }
         assertTrue(exceptionThrown);
         exceptionThrown = false;

         final long testValueView9 = 99L;
         final long testValueLedger9 = testValueView9 + TxOutStore.FOG_SYNC_THRESHOLD.longValue();
         final long testValueConsensus9 = testValueView9 + TxOutStore.FOG_SYNC_THRESHOLD.longValue() / 2;
         try {
             fogSyncTest_attemptRefresh(testValueView9, testValueLedger9, testValueConsensus9);// above threshold, should fail
         } catch(FogSyncException e) {
             exceptionThrown = true;
         }
         assertTrue(exceptionThrown);
         exceptionThrown = false;

     }

     private void fogSyncTest_attemptRefresh(long fogViewBlocks, long fogLedgerBlocks, long consensusBlocks) throws Exception {

         AccountKey accountKey = mock(AccountKey.class);

         AttestedViewClient viewClient = mock(AttestedViewClient.class);
         View.QueryResponse.Builder viewResponseBuilder = View.QueryResponse.newBuilder();
         viewResponseBuilder.setHighestProcessedBlockCount(fogViewBlocks);
         when(viewClient.request(any(), eq(Long.valueOf(0L)), eq(Long.valueOf(0L)))).thenReturn(viewResponseBuilder.build());

         AttestedLedgerClient ledgerClient = mock(AttestedLedgerClient.class);
         Ledger.CheckKeyImagesResponse.Builder ledgerResponseBuilder = Ledger.CheckKeyImagesResponse.newBuilder();
         ledgerResponseBuilder.setNumBlocks(fogLedgerBlocks);
         ledgerResponseBuilder.setGlobalTxoCount(18930623637638213L);
         when(ledgerClient.checkUtxoKeyImages(any())).thenReturn(ledgerResponseBuilder.build());

         FogBlockClient blockClient = mock(FogBlockClient.class);
         when(blockClient.scanForTxOutsInBlockRange(any(), any())).thenReturn(new ArrayList<OwnedTxOut>());

         BlockchainClient blockchainClient = mock(BlockchainClient.class);
         ConsensusCommon.LastBlockInfoResponse.Builder blockchainClientResponseBuilder = ConsensusCommon.LastBlockInfoResponse.newBuilder();
         blockchainClientResponseBuilder.setIndex(consensusBlocks);
         when(blockchainClient.getOrFetchLastBlockInfo()).thenReturn(blockchainClientResponseBuilder.build());

         TxOutStore txOutStore = new TxOutStore(accountKey);
         txOutStore.setConsensusBlockIndex(UnsignedLong.fromLongBits(consensusBlocks));
         txOutStore.refresh(
                 viewClient,
                 ledgerClient,
                 blockClient
         );

     }

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
     */
}

extension FogBlockConnectionIntTests {
    func createFogBlockConnection(transportProtocol: TransportProtocol) throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnection(networkConfig: NetworkConfig) -> FogBlockConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogBlockConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
