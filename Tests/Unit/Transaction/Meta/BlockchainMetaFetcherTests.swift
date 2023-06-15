//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
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

            XCTAssertEqual(metaCache.minimumFees[.MOB], 400_000_000)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchMinimumFeeWorksWithNewService() throws {
        let blockchainService = TestBlockchainService(successWithMinimumFee: 300_000_000)
        let fetcher = BlockchainMetaFetcher(
            blockchainService: blockchainService,
            metaCacheTTL: 60,
            targetQueue: DispatchQueue.main)

        let expect = expectation(description: "fetching minimum fee")
        fetcher.fetchMeta {
            guard let metaCache = $0.successOrFulfill(expectation: expect)
            else { return }

            XCTAssertEqual(metaCache.minimumFees[.MOB], 300_000_000)
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
        let initialBlockVersion: BlockVersion = 1
        let expectedBlockVersion = initialBlockVersion
        let blockchainService = TestBlockchainService(successWithBlockVersion: initialBlockVersion)
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

                XCTAssertEqual(metaCache.blockVersion, expectedBlockVersion)

                fetcher.resetCache {

                    fetcher.getCachedBlockVersion {
                        XCTAssertNil($0)

                        fetcher.blockVersion {
                            guard let blockVersion = $0.successOrFulfill(expectation: expect)
                            else { return }

                            XCTAssertEqual(blockVersion, expectedBlockVersion)
                            expect.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testBlockVersionMismatchCacheInvalidation() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.SuccessMismatchedBlockVersions()
        let metaFetcher = fixtures.metaFetcher
        let transactionSubmitter = fixtures.transactionSubmitter
        let transaction = try Transaction.Fixtures.Default().transaction

        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedBlockVersion {
            XCTAssertNil($0)

            metaFetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }

                XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                transactionSubmitter.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
                    print("Transaction submission successful")

                    metaFetcher.getCachedBlockVersion {
                        // BlockVersion was mismatched, cache should be reset to nil
                        XCTAssertNil($0)

                        expect.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testBlockVersionMismatchCacheInvalidationAndFailure() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.FailureMismatchedBlockVersions()
        let metaFetcher = fixtures.metaFetcher
        let transactionSubmitter = fixtures.transactionSubmitter
        let transaction = try Transaction.Fixtures.Default().transaction

        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedBlockVersion {
            XCTAssertNil($0)

            metaFetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }

                XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                transactionSubmitter.submitTransaction(transaction) {
                    guard $0.failureOrFulfill(expectation: expect) != nil else { return }
                    print("Transaction submission failed, as expected")

                    metaFetcher.getCachedBlockVersion {
                        // BlockVersion was mismatched, cache should be reset to nil
                        XCTAssertNil($0)

                        expect.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testBlockVersionEqualCacheValidWithFailure() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.FailureEqualBlockVersions()
        let metaFetcher = fixtures.metaFetcher
        let transactionSubmitter = fixtures.transactionSubmitter

        let transaction = try Transaction.Fixtures.Default().transaction
        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedBlockVersion {
            XCTAssertNil($0)

            metaFetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }

                XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                transactionSubmitter.submitTransaction(transaction) {
                    guard $0.failureOrFulfill(expectation: expect) != nil else { return }
                    print("Transaction submission failed, as expected")

                    metaFetcher.getCachedBlockVersion {
                        // BlockVersion was equal, cache should be valid
                        XCTAssertEqual(fixtures.initialBlockVersion, $0)

                        expect.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testBlockVersionEqualCacheValidWithSuccess() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.SuccessEqualBlockVersions()
        let metaFetcher = fixtures.metaFetcher
        let transactionSubmitter = fixtures.transactionSubmitter

        let transaction = try Transaction.Fixtures.Default().transaction
        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedBlockVersion {
            XCTAssertNil($0)

            metaFetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }

                XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                transactionSubmitter.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
                    print("Transaction submission succeeded")

                    metaFetcher.getCachedBlockVersion {
                        // BlockVersion was equal, cache should be valid
                        XCTAssertEqual(fixtures.initialBlockVersion, $0)

                        expect.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testTxFeeErrorCacheInvalidation() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.FailureTxFeeError()
        let metaFetcher = fixtures.metaFetcher
        let transactionSubmitter = fixtures.transactionSubmitter
        let transaction = try Transaction.Fixtures.Default().transaction
        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedMinimumFee(tokenId: .MOB) {
            XCTAssertNil($0)

            metaFetcher.fetchMeta {
                guard let metaCache = $0.successOrFulfill(expectation: expect)
                else { return }

                XCTAssertEqual(metaCache.minimumFees[.MOB], fixtures.minimumFee)
                XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                transactionSubmitter.submitTransaction(transaction) {
                    guard $0.failureOrFulfill(expectation: expect) != nil else { return }
                    print("Transaction submission failed, as expected")

                    metaFetcher.getCachedMinimumFee(tokenId: .MOB) {
                        // Failure was .txFeeError, cache should be reset
                        XCTAssertNil($0)

                        expect.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testCompleteSuccessCacheValid() throws {
        let fixtures = BlockchainMetaFetcher.Fixtures.SuccessCacheValid()
        let transactionSubmitter = fixtures.transactionSubmitter
        let metaFetcher = fixtures.metaFetcher
        let transaction = try Transaction.Fixtures.Default().transaction

        let expect = expectation(
            description: "testing block version mismatch propose tx response")

        metaFetcher.getCachedMinimumFee(tokenId: .MOB) { nilFee in
            metaFetcher.getCachedBlockVersion { nilBlockVersion in
                XCTAssertNil(nilFee)
                XCTAssertNil(nilBlockVersion)

                metaFetcher.fetchMeta {
                    guard let metaCache = $0.successOrFulfill(expectation: expect)
                    else { return }

                    XCTAssertEqual(metaCache.minimumFees[.MOB], fixtures.minimumFee)
                    XCTAssertEqual(metaCache.blockVersion, fixtures.initialBlockVersion)

                    transactionSubmitter.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }
                        print("Transaction submission success")

                        metaFetcher.getCachedMinimumFee(tokenId: .MOB) { fee in
                            metaFetcher.getCachedBlockVersion { blockVersion in
                                XCTAssertEqual(fee, fixtures.minimumFee)
                                XCTAssertEqual(blockVersion, fixtures.initialBlockVersion)

                                expect.fulfill()
                            }
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

}
