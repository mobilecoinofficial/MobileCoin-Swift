//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class BlockchainMetaFetcherTests: XCTestCase {

    func testFetchMinimumFeeReturnsDefaultWithLegacyService() throws {
        let blockchainService = TestBlockchainService.makeWithSuccess()
        let fetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)

        let expect = expectation(description: "fetching minimum fee")
        fetcher.fetchMeta {
            guard let metaCache = $0.successOrFulfill(expectation: expect)
            else { return }
            
            XCTAssertEqual(metaCache.minimumFee, 10_000_000_000)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchMinimumFeeWorksWithNewService() throws {
        let blockchainService = TestBlockchainService(successWithMinimumFee: 3_000_000_000)
        let fetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)

        let expect = expectation(description: "fetching minimum fee")
        fetcher.fetchMeta {
            guard let metaCache = $0.successOrFulfill(expectation: expect)
            else { return }
            
            XCTAssertEqual(metaCache.minimumFee, 3_000_000_000)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchBlockVersion() throws {
        let blockchainService = TestBlockchainService(successWithBlockVersion: 1)
        let fetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)

        let expect = expectation(description: "fetching block version")
        fetcher.fetchMeta {
            guard let metaCache = $0.successOrFulfill(expectation: expect)
            else { return }
            
            XCTAssertEqual(metaCache.blockVersion, 1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testMetaCacheInvalidation() throws {
        let blockchainService = TestBlockchainService(successWithBlockVersion: 1)
        let fetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)


        let expect = expectation(description: "testing block version cache")
        
        fetcher.getCachedBlockVersion {
            XCTAssertNil($0)
            
            fetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }
    
                XCTAssertEqual(metaCache.blockVersion, 1)
    
                fetcher.resetCache {
    
                    fetcher.getCachedBlockVersion {
                        XCTAssertNil($0)

                        fetcher.blockVersion {
                            guard let blockVersion = $0.successOrFulfill(expectation: expect)
                            else { return }

                            XCTAssertEqual(blockVersion, 1)
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testBlockVersionMismatchCacheInvalidation() throws {
        let blockchainService = TestBlockchainService.makeWithSuccess()
        let metaFetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)


        let mockSyncChecker = MockFogSyncChecker(
            viewIndex: 10,
            ledgerIndex: 10,
            consensusIndex: 10)
        
        let consensusService = TestConsensusService(successWithBlockVersion: 1)
        let transactionSubmitter = TransactionSubmitter(
            consensusService: consensusService,
            metaFetcher: metaFetcher,
            syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        
        let transaction = Transaction(
        let expect = expectation(description: "testing block version mismatch propose tx response")
        
        transactionSubmitter.submitTransaction(, completion: <#T##(Result<(), TransactionSubmissionError>) -> Void#>)
        fetcher.getCachedBlockVersion {
            XCTAssertNil($0)
            
            fetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }
    
                XCTAssertEqual(metaCache.blockVersion, 1)
    
                fetcher.resetCache {
    
                    fetcher.getCachedBlockVersion {
                        XCTAssertNil($0)

                        fetcher.blockVersion {
                            guard let blockVersion = $0.successOrFulfill(expectation: expect)
                            else { return }

                            XCTAssertEqual(blockVersion, 1)
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 5)
    }

}
