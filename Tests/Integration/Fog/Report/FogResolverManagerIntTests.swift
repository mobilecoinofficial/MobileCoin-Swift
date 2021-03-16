//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogResolverManagerIntTests: XCTestCase {
    func testFogReport() throws {
        let fogResolverManager = try IntegrationTestFixtures.createFogResolverManager()
        let publicAddress = try IntegrationTestFixtures.createPublicAddress()

        let expect = expectation(description: "Retrieve fog reports")
        fogResolverManager.fogResolver(addresses: [publicAddress]) {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
