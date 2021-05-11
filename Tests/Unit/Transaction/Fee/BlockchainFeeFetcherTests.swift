//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class BlockchainFeeFetcherTests: XCTestCase {

    func testFetchMinimumFeeReturnsDefaultWithLegacyService() throws {
        let blockchainService = TestBlockchainService.makeWithSuccess()
        let fetcher = BlockchainFeeFetcher(blockchainService: blockchainService)

        let expect = expectation(description: "fetching minimum fee")
        fetcher.fetchMinimumFee {
            XCTAssertSuccessEqual($0, 10_000_000_000)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchMinimumFeeWorksWithNewService() throws {
        let blockchainService = TestBlockchainService(successWithMinimumFee: 3_000_000_000)
        let fetcher = BlockchainFeeFetcher(blockchainService: blockchainService)

        let expect = expectation(description: "fetching minimum fee")
        fetcher.fetchMinimumFee {
            XCTAssertSuccessEqual($0, 3_000_000_000)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

}
