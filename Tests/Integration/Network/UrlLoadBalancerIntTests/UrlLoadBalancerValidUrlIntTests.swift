//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class UrlLoadBalancerValidUrlIntTests: XCTestCase {

    func testBlockchainDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testBlockchainDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testConsensusDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testConsensusDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testFogBlockDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogBlockDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testFogKeyImageDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogKeyImageDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testFogMerkleProofDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogMerkleProofDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testFogViewDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogViewDoesNotRotateAwayFromGoodUrl(using: transportProtocol)
        }
    }

    func testBlockchainDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting Blockchain url rotation does not occur with good URL using: " +
              "\(transportProtocol.description)")

        let consensusUrlLoadBalancer =
            try IntegrationTestFixtures.createValidConsensusUrlLoadBalancer()
        let blockchain = try IntegrationTestFixtures.createBlockchainConnection(
            for: transportProtocol,
            using: consensusUrlLoadBalancer)

        XCTAssertEqual(
            0,
            consensusUrlLoadBalancer.curIdx,
            "Consensus URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(
            description: "Making Blockchain request against valid URL should succeed")
        blockchain.getLastBlockInfo {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            0,
            consensusUrlLoadBalancer.curIdx,
            "Consensus URL load balancer should not have rotated and should be at index 0")
    }

    func testConsensusDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting Consensus url rotation does not occur for good URL for protocol: " +
              "\(transportProtocol.description)")

        let consensusUrlLoadBalancer =
            try IntegrationTestFixtures.createValidConsensusUrlLoadBalancer()
        let consensus = try IntegrationTestFixtures.createConsensusConnection(
            for: transportProtocol,
            using: consensusUrlLoadBalancer)

        XCTAssertEqual(
            0,
            consensusUrlLoadBalancer.curIdx,
            "Consensus URL load balancer should not have rotated and should be at index 0")

        let fixture = try Transaction.Fixtures.Default()

        let expectSuccess = expectation(
            description: "Making Consensus request against valid URL that should succeed")
        consensus.proposeTx(fixture.tx) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        // verify that rotate has been called by checking curIdx of the loadBalancer
        XCTAssertEqual(
            0,
            consensusUrlLoadBalancer.curIdx,
            "Consensus URL load balancer should not have rotated and should be at index 0")
    }

    func testFogBlockDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting FogBlock url rotation does not occur with good URL for protocol: " +
              "\(transportProtocol.description)")

        let fogUrlLoadBalancer = try IntegrationTestFixtures.createValidFogUrlLoadBalancer()
        let fogBlock = try IntegrationTestFixtures.createFogBlockConnection(
            for: transportProtocol,
            using: fogUrlLoadBalancer)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(
            description: "Making FogBlock request against valid URL should succeed")
        fogBlock.getBlocks(
            request: FogLedger_BlockRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogKeyImageDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting FogKeyImage url does not rotate with good URL for protocol: " +
              "\(transportProtocol.description)")

        let fogUrlLoadBalancer =
            try IntegrationTestFixtures.createFogUrlLoadBalancerWithInitialInvalidUrl()

        let fogKeyImage = try IntegrationTestFixtures.createFogKeyImageConnection(
            for: transportProtocol,
            using: fogUrlLoadBalancer)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(
            description: "Making FogKeyImage request against invalid URL")
        fogKeyImage.checkKeyImages(
            request: FogLedger_CheckKeyImagesRequest()
        ) {
            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expectFailure.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            1,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogMerkleProofDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting FogMerkleProof url rotation does not occur with good URL using: " +
              "\(transportProtocol.description)")

        let fogUrlLoadBalancer = try IntegrationTestFixtures.createValidFogUrlLoadBalancer()
        let fogMerkleProof = try IntegrationTestFixtures.createFogMerkleProofConnection(
            for: transportProtocol,
            using: fogUrlLoadBalancer)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(
            description: "Making FogMerkleProof request against valid URL should succeed")
        fogMerkleProof.getOutputs(
            request: FogLedger_GetOutputsRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl(
        using transportProtocol: TransportProtocol
    ) throws {

        print("\n-----\nTesting FogUntrustedTxOut url does not rotate with good URL using: " +
              "\(transportProtocol.description)")

        let fogUrlLoadBalancer = try IntegrationTestFixtures.createValidFogUrlLoadBalancer()
        let fogUntrustedTxOut =
            try IntegrationTestFixtures.createFogUntrustedTxOutConnection(
                for: transportProtocol,
                using: fogUrlLoadBalancer)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(
            description: "Making FogUntrustedTxOut request against valid URL should succeed")
        fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest()) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogViewDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol)
    throws {
        print("\n-----\nTesting FogView url rotation does not occur with good URL using: " +
              "\(transportProtocol.description)")

        let fogUrlLoadBalancer = try IntegrationTestFixtures.createValidFogUrlLoadBalancer()
        let fogView = try IntegrationTestFixtures.createFogViewConnection(
            for: transportProtocol,
            using: fogUrlLoadBalancer)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(
            description: "Making FogView request against valid URL should succeed")
        fogView.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)

        XCTAssertEqual(
            0,
            fogUrlLoadBalancer.curIdx,
            "Fog URL load balancer should not have rotated and should be at index 0")
    }

}
