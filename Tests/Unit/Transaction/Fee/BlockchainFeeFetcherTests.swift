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

}
