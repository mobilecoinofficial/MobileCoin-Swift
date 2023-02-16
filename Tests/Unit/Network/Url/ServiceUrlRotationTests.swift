//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
import LibMobileCoin
@testable import MobileCoin
import XCTest

class ServiceUrlRotationTests: XCTestCase {

    func testUrlRotation(fixture: ServiceFixture) throws {
        let serviceName = fixture.serviceName
        let loadBalancer = fixture.loadBalancer

        print("Test \(serviceName) url rotation occurs on request failure.")

        let expect = expectation(description: "HTTP request should have failed")
        try fixture.callService(expect: expect)
        waitForExpectations(timeout: 40)

        XCTAssertTrue(loadBalancer.didRotate, "URL load balancer should have rotated")
    }

    func testBlockchainUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.Blockchain()
        try testUrlRotation(fixture: fixture)
    }

    func testConsensusUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.Consensus()
        try testUrlRotation(fixture: fixture)
    }

    func testFogBlockUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.FogBlock()
        try testUrlRotation(fixture: fixture)
    }

    func testFogKeyImageUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.FogKeyImage()
        try testUrlRotation(fixture: fixture)
    }

    func testFogMerkleProofUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.FogMerkleProof()
        try testUrlRotation(fixture: fixture)
    }

    func testFogUntrustedTxOutUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.FogUntrustedTxOut()
        try testUrlRotation(fixture: fixture)
    }

    func testFogViewUrlRotatesOnError() throws {
        let fixture = try UrlLoadBalancerFixtures.FogView()
        try testUrlRotation(fixture: fixture)
    }
}
