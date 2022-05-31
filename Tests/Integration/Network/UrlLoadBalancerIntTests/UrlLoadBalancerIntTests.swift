//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class UrlLoadBalancerIntTests: XCTestCase {

    func testBlockchainDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.Blockchain(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testConsensusDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.Consensus(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogBlockDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogBlock(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogKeyImageDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogKeyImage(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogMerkleProofDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogMerkleProof(
                with: transProtocol,
                useValidUrls: true)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogUntrustedTxOutDoesNotRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogUntrustedTxOut(
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

    func testBlockchainDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            if transProtocol == .http {
                let fixture = try UrlLoadBalancerFixtures.Blockchain(
                    with: transProtocol,
                    useValidUrls: false)
                try testUrlRotation(fixture: fixture, with: transProtocol)
            }
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

    func testFogBlockDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogBlock(
                with: transProtocol,
                useValidUrls: false)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogKeyImageDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogKeyImage(
                with: transProtocol,
                useValidUrls: false)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogMerkleProofDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogMerkleProof(
                with: transProtocol,
                useValidUrls: false)
            try testUrlRotation(fixture: fixture, with: transProtocol)
        }
    }

    func testFogUntrustedTxOutDoesRotate() throws {
        try TransportProtocol.supportedProtocols.forEach { transProtocol in
            let fixture = try UrlLoadBalancerFixtures.FogUntrustedTxOut(
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
        let urlType       = "Consensus"
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
