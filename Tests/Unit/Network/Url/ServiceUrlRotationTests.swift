//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

@testable import MobileCoin
import XCTest

class ServiceUrlRotationTests: XCTestCase {

    func testUrlRotation(fixture: ServiceFixture, loadBalancer: MockUrlLoadBalancer) throws {
        let serviceName = fixture.serviceName

        print("Test \(serviceName) url rotation occurs on request failure.")

        let expect = expectation(description: "HTTP request should have failed")
        try fixture.callService(expect: expect)
        waitForExpectations(timeout: 40)

        XCTAssertTrue(loadBalancer.didRotate, "URL load balancer should have rotated")
    }

    func testBlockchainUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidConsensusUrlBalancer
        let blockchain = try UnitTestFixtures.createBlockchainConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let blockchainFixture = try UrlLoadBalancerFixtures.Blockchain(blockchain)
        try testUrlRotation(fixture: blockchainFixture, loadBalancer: seqLoadBalancer)
    }

    func testConsensusUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidConsensusUrlBalancer
        let consensus = try UnitTestFixtures.createConsensusConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let consensusFixture = try UrlLoadBalancerFixtures.Consensus(consensus)
        try testUrlRotation(fixture: consensusFixture, loadBalancer: seqLoadBalancer)
    }

    func testFogBlockUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
        let fogBlock = try UnitTestFixtures.createFogBlockConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let fogBlockFixture = try UrlLoadBalancerFixtures.FogBlock(fogBlock)
        try testUrlRotation(fixture: fogBlockFixture, loadBalancer: seqLoadBalancer)
    }

    func testFogKeyImageUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
        let fogKeyImage = try UnitTestFixtures.createFogKeyImageConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let fogKeyImageFixture = try UrlLoadBalancerFixtures.FogKeyImage(fogKeyImage)
        try testUrlRotation(fixture: fogKeyImageFixture, loadBalancer: seqLoadBalancer)
    }

    func testFogMerkleProofUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
        let fogMerkleProof = try UnitTestFixtures.createFogMerkleProofConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let fogMerkleProofFixture = try UrlLoadBalancerFixtures.FogMerkleProof(fogMerkleProof)
        try testUrlRotation(fixture: fogMerkleProofFixture, loadBalancer: seqLoadBalancer)
    }

    func testFogUntrustedTxOutUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
        let fogUntrustedTxOut = try UnitTestFixtures.createFogUntrustedTxOutConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let fogUntrustedFixture = try UrlLoadBalancerFixtures.FogUntrustedTxOut(fogUntrustedTxOut)
        try testUrlRotation(fixture: fogUntrustedFixture, loadBalancer: seqLoadBalancer)
    }

    func testFogViewUrlRotatesOnError() throws {
        let seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
        let fogView = try UnitTestFixtures.createFogViewConnection(
            using: seqLoadBalancer,
            httpRequester: MockFailingHttpRequester())
        let fogViewFixture = try UrlLoadBalancerFixtures.FogView(fogView)
        try testUrlRotation(fixture: fogViewFixture, loadBalancer: seqLoadBalancer)
    }
}
