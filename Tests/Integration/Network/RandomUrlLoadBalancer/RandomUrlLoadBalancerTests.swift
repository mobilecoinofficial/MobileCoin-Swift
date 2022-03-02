//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class RandomUrlLoadBalancerIntTests: XCTestCase {

    func testUrlsRotatedWithHttpTransportProtocol() throws {
        // manual testing - as failures are required for validation
        try XCTSkipIf(true)
        try verifyUrlRotates(transportProtocol: .http)
    }

    func testUrlsRotatedWithGrpcTransportProtocol() throws {
        // manual testing - as failures are required for validation
        try XCTSkipIf(true)
        try verifyUrlRotates(transportProtocol: .grpc)
    }

    func verifyUrlRotates(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClientWithPartialValidFogUrls(transportProtocol:transportProtocol)

        // using 10 iterations to be sure to get past all the incremental
        // failures from each of the individual services that may be used
        // during the balance query
        for _ in 0...10 {
            let expect = expectation(description: description)
            try balance(client: client, expectation: expect)
            waitForExpectations(timeout: 100)
        }
    }

    func balance(client: MobileCoinClient, expectation expect: XCTestExpectation) throws {

        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }

            expect.fulfill()
        }
    }

}
