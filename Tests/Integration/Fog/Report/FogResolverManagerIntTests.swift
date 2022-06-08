//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogResolverManagerIntTests: XCTestCase {
    func testFogReport() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try fogReport(transportProtocol: transportProtocol)
        }
    }

    func fogReport(transportProtocol: TransportProtocol) throws {
        let fogResolverManager = try IntegrationTestFixtures.createFogResolverManager(
                transportProtocol: transportProtocol)
        let publicAddress = try IntegrationTestFixtures.createPublicAddress()

        let expect = expectation(description: "Retrieve fog reports")
        fogResolverManager.fogResolver(addresses: [publicAddress]) {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
