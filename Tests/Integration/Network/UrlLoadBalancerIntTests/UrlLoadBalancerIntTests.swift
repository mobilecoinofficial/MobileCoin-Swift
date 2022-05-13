//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

// swiftlint:disable line_length

class UrlLoadBalancerIntTests: XCTestCase {

    func timeoutInSeconds(for transportProtocol: TransportProtocol) -> Double {
        // pad timeout of test by 2 seconds over the protocol timeout
        let padTime = 2.0

        switch transportProtocol.option {
        case .grpc:
            // forced unwrap of timeout here in test is ok b/c we want fast failure if not set
            return padTime + Double(GrpcChannelManager.Defaults.callOptionsTimeLimit.timeout!.nanoseconds) / 1.0e9
        case .http:
            return padTime + DefaultHttpRequester.defaultConfiguration.timeoutIntervalForRequest
        }
    }

    func testBlockchainRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testBlockchainRotatesAwayFromBadUrl(using: transportProtocol,
                                                    andWaitFor: timeoutInSeconds(for: transportProtocol) )
        }
    }

    func testBlockchainDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testBlockchainDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                           andWaitFor: timeoutInSeconds(for: transportProtocol) )
        }
    }

    func testConsensusRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testConsensusRotatesAwayFromBadUrl(using: transportProtocol,
                                                   andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testConsensusDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testConsensusDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                          andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogBlockRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogBlockRotatesAwayFromBadUrl(using: transportProtocol,
                                                  andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogBlockDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogBlockDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                         andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogKeyImageRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogKeyImageRotatesAwayFromBadUrl(using: transportProtocol,
                                                     andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogKeyImageDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogKeyImageDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                            andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogMerkleProofRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogMerkleProofRotatesAwayFromBadUrl(using: transportProtocol,
                                                        andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogMerkleProofDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogMerkleProofDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                               andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogUntrustedTxOutRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogUntrustedTxOutRotatesAwayFromBadUrl(using: transportProtocol,
                                                           andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                                  andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogViewRotatesAwayFromBadUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogViewRotatesAwayFromBadUrl(using: transportProtocol,
                                                 andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testFogViewDoesNotRotateAwayFromGoodUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogViewDoesNotRotateAwayFromGoodUrl(using: transportProtocol,
                                                        andWaitFor: timeoutInSeconds(for: transportProtocol))
        }
    }

    func testBlockchainRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting Blockchain url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()

        let consensusUrlLoadBalancerMock = try createTestConsensusUrlLoadBalancer()

        consensusUrlLoadBalancerMock.rotationEnabled = false
        let blockchain = try createConfiguredBlockchainConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancerMock, fogUrlLoadBalancer: fogUrlLoadBalancer)
        consensusUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, consensusUrlLoadBalancerMock.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(description: "Making Blockchain request against invalid URL")
        blockchain.getLastBlockInfo {
            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expectFailure.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        // verify that rotate has been called by checking curIdx of the loadBalancer
        XCTAssertEqual( 1, consensusUrlLoadBalancerMock.curIdx, "Consensus URL load balancer should have rotated from index 0 to 1")
    }

    func testBlockchainDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting Blockchain url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let blockchain = try createConfiguredBlockchainConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)

        XCTAssertEqual( 0, consensusUrlLoadBalancer.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making Blockchain request against valid URL that should succeed")
        blockchain.getLastBlockInfo {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        // verify that rotate has been called by checking curIdx of the loadBalancer
        XCTAssertEqual( 0, consensusUrlLoadBalancer.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")
    }

    func testConsensusRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting Consensus url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()

        let consensusUrlLoadBalancerMock = try createTestConsensusUrlLoadBalancer()
        consensusUrlLoadBalancerMock.rotationEnabled = false
        let consensus = try createConfiguredConsensusConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancerMock, fogUrlLoadBalancer: fogUrlLoadBalancer)
        consensusUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, consensusUrlLoadBalancerMock.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")

        let fixture = try Transaction.Fixtures.Default()

        let expectFailure = expectation(description: "Making Consensus request against invalid URL")
        consensus.proposeTx(fixture.tx) {
            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expectFailure.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        // verify that rotate has been called by checking curIdx of the loadBalancer
        XCTAssertEqual( 1, consensusUrlLoadBalancerMock.curIdx, "Consensus URL load balancer should have rotated from index 0 to 1")
    }

    func testConsensusDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting Consensus url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let consensus = try createConfiguredConsensusConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)

        XCTAssertEqual( 0, consensusUrlLoadBalancer.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")

        let fixture = try Transaction.Fixtures.Default()

        let expectSuccess = expectation(description: "Making Consensus request against valid URL that should succeed")
        consensus.proposeTx(fixture.tx) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        // verify that rotate has been called by checking curIdx of the loadBalancer
        XCTAssertEqual( 0, consensusUrlLoadBalancer.curIdx, "Consensus URL load balancer should not have rotated and should be at index 0")
    }

    func testFogBlockRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogBlock url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()

        let fogUrlLoadBalancerMock = try createTestFogUrlLoadBalancer()
        fogUrlLoadBalancerMock.rotationEnabled = false
        let fogBlock = try createConfiguredFogBlockConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancerMock)
        fogUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(description: "Making FogBlock request against invalid URL")
        fogBlock.getBlocks(
            request: FogLedger_BlockRequest()
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
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 1, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogBlockDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogBlock url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let fogBlock = try createConfiguredFogBlockConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making FogBlock request against valid URL should succeed")
        fogBlock.getBlocks(
            request: FogLedger_BlockRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogKeyImageRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogKeyImage url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        fogUrlLoadBalancer.rotationEnabled = false
        let fogKeyImage = try createConfiguredFogKeyImageConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)
        fogUrlLoadBalancer.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making FogKeyImage request against valid URL should succeed")
        fogKeyImage.checkKeyImages(
            request: FogLedger_CheckKeyImagesRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogKeyImageDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogKeyImage url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()

        let fogUrlLoadBalancerMock = try createTestFogUrlLoadBalancer()
        fogUrlLoadBalancerMock.rotationEnabled = false
        let fogKeyImage = try createConfiguredFogKeyImageConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancerMock)
        fogUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(description: "Making FogKeyImage request against invalid URL")
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
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 1, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogMerkleProofRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogMerkleProof url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()

        let fogUrlLoadBalancerMock = try createTestFogUrlLoadBalancer()
        fogUrlLoadBalancerMock.rotationEnabled = false
        let fogMerkleProof = try createConfiguredFogMerkleProofConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancerMock)
        fogUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(description: "Making FogMerkleProof request against invalid URL")
        fogMerkleProof.getOutputs(
            request: FogLedger_GetOutputsRequest()
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
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 1, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogMerkleProofDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogMerkleProof url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        fogUrlLoadBalancer.rotationEnabled = false
        let fogMerkleProof = try createConfiguredFogMerkleProofConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)
        fogUrlLoadBalancer.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making FogMerkleProof request against valid URL should succeed")
        fogMerkleProof.getOutputs(
            request: FogLedger_GetOutputsRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogUntrustedTxOutRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogUntrustedTxOut url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()

        let fogUrlLoadBalancerMock = try createTestFogUrlLoadBalancer()
        fogUrlLoadBalancerMock.rotationEnabled = false
        let fogUntrustedTxOut = try createConfiguredFogUntrustedTxOutConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancerMock)
        fogUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure1 = expectation(description: "Making FogUntrustedTxOut request against invalid URL")
        fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest() ) {
            guard let error = $0.failureOrFulfill(expectation: expectFailure1) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expectFailure1.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 1, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogUntrustedTxOutDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogUntrustedTxOut url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        fogUrlLoadBalancer.rotationEnabled = false
        let fogUntrustedTxOut = try createConfiguredFogUntrustedTxOutConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)
        fogUrlLoadBalancer.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making FogUntrustedTxOut request against valid URL should succeed")
        fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest()) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")
    }

    func testFogViewRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogView url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()

        let fogUrlLoadBalancerMock = try createTestFogUrlLoadBalancer()
        fogUrlLoadBalancerMock.rotationEnabled = false
        let fogView = try createConfiguredFogViewConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancerMock)
        fogUrlLoadBalancerMock.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectFailure = expectation(description: "Making FogView request against invalid URL")
        fogView.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
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
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 1, fogUrlLoadBalancerMock.curIdx, "Fog URL load balancer should have rotated from index 0 to 1")
    }

    func testFogViewDoesNotRotateAwayFromGoodUrl(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
        print("\n-----\nTesting FogView url rotation does not occur with good URL for protocol: \(transportProtocol.description)")

        let consensusUrlLoadBalancer = try createValidConsensusUrlLoadBalancer()
        let fogUrlLoadBalancer = try createValidFogUrlLoadBalancer()
        fogUrlLoadBalancer.rotationEnabled = false
        let fogView = try createConfiguredFogViewConnection(transportProtocol: transportProtocol, consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer)
        fogUrlLoadBalancer.rotationEnabled = true

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")

        let expectSuccess = expectation(description: "Making FogView request against valid URL should succeed")
        fogView.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: timeToWait)

        XCTAssertEqual( 0, fogUrlLoadBalancer.curIdx, "Fog URL load balancer should not have rotated and should be at index 0")
    }


}

extension UrlLoadBalancerIntTests {

    func createValidConsensusUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        // same url purposefully doubled-up, as we use the current index to detect rotation
        let consensusUrls = try ConsensusUrl.make(strings: [IntegrationTestFixtures.network.consensusUrl, IntegrationTestFixtures.network.consensusUrl]).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    func createValidFogUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<FogUrl> {
        // same url purposefully doubled-up, as we use the current index to detect rotation
        let fogUrls = try FogUrl.make(strings: [IntegrationTestFixtures.network.fogUrl, IntegrationTestFixtures.network.fogUrl]).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }

    func createTestConsensusUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        let urlStrings = [IntegrationTestFixtures.invalidConsensusUrl, IntegrationTestFixtures.network.consensusUrl]
        let consensusUrls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    func createTestFogUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<FogUrl> {
        let urlStrings = [IntegrationTestFixtures.invalidFogUrl, IntegrationTestFixtures.network.fogUrl]
        let fogUrls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }

    func createConfiguredFogViewConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogView = FogViewConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return fogView
    }
    
    func createConfiguredFogUntrustedTxOutConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> FogUntrustedTxOutConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogUntrustedTxOut = FogUntrustedTxOutConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return fogUntrustedTxOut
    }

    func createConfiguredFogMerkleProofConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> FogMerkleProofConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogMerkleProof = FogMerkleProofConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return fogMerkleProof
    }

    func createConfiguredFogKeyImageConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> FogKeyImageConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogKeyImage = FogKeyImageConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return fogKeyImage
    }

    func createFogKeyImageConnection(transportProtocol: TransportProtocol)
    throws -> FogKeyImageConnection {
        let fogUrlLoadBalancer = try createTestFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        fogUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: try createValidConsensusUrlLoadBalancer(),
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let fogKeyImage = FogKeyImageConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        fogUrlLoadBalancer.rotationEnabled = true

        return fogKeyImage
    }

    func createConfiguredFogBlockConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogBlock = FogBlockConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return fogBlock
    }

    func createConfiguredBlockchainConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> BlockchainConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let blockchain = BlockchainConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return blockchain
    }

    func createConfiguredConsensusConnection
    (
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    )
    throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let consensus = ConsensusConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        return consensus
    }

}
