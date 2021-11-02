//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogResolverManagerIntTests: XCTestCase {
    func testFogReportGRPC() throws {
        try fogReport(transportProtocol: TransportProtocol.grpc)
    }
    
    func testFogReportHTTP() throws {
        try fogReport(transportProtocol: TransportProtocol.http)
    }
    
    func fogReport(transportProtocol: TransportProtocol) throws {
        let fogResolverManager = try IntegrationTestFixtures.createFogResolverManager(transportProtocol: transportProtocol)
        let publicAddress = try IntegrationTestFixtures.createPublicAddress()

        let expect = expectation(description: "Retrieve fog reports")
        fogResolverManager.fogResolver(addresses: [publicAddress]) {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}

