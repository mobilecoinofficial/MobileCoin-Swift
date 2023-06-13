//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin
import XCTest

class UrlLoadBalancerIntTests: XCTestCase {

    func testConsensusDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.Consensus(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogViewDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogView(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testConsensusDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.Consensus(
                with: transProtocol,
                useValidUrls: false)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogViewDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogView(
                with: transProtocol,
                useValidUrls: false)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testUrlRotation(fixture: ServiceFixture, with transProto: TransportProtocol) throws {
        let serviceName = fixture.serviceName
        let urlType = fixture.urlTypeName
        let loadBalancer = fixture.loadBalancer

        let notMessage = fixture.useValidUrls ? " not" : ""
        let validMessage = fixture.useValidUrls ? "valid" : "invalid"
        let testMessage   = "Test \(serviceName) url rotation does\(notMessage) occur using: "
        let expectMessage = "\(serviceName) call with \(validMessage) URL should \(notMessage) fail"
        let assertMessage = "\(urlType) URL load balancer should\(notMessage) have rotated"

        print("\(testMessage) \(transProto.description)")

        let expect = expectation(description: expectMessage)
        try fixture.callService(expect: expect)
        waitForExpectations(timeout: transProto.testTimeoutInSeconds)

        let shouldRotate  = !fixture.useValidUrls
        XCTAssertEqual(shouldRotate, loadBalancer.didRotate, assertMessage)
    }
}
