//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class RandomUrlLoadBalancerIntTests: XCTestCase {

    func testUrlRotates() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try verifyUrlRotates(transportProtocol: transportProtocol)
//        }
        try verifyUrlRotates(transportProtocol: .http)
    }

    func verifyUrlRotates(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClientWithPartialValidFogUrls(transportProtocol:TransportProtocol.http)

        for _ in 0...3 {
            let expect = expectation(description: description)
            try balance(client: client, transportProtocol: TransportProtocol.http, expectation: expect)
            waitForExpectations(timeout: 100)
        }
    }

    func balance(client: MobileCoinClient, transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {

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

