//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class UrlLoadBalancerIntTests: XCTestCase {

    let expectationTimeout = 60.0
    
    func testBlockchainRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testBlockchainRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testConsensusRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testConsensusRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testFogBlockRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogBlockRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testFogKeyImageRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogKeyImageRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testFogMerkleProofRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogMerkleProofRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testFogUntrustedTxOutRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogUntrustedTxOutRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testFogViewRotatesAwayFromBadUrl() throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testFogViewRotatesAwayFromBadUrl(transportProtocol: transportProtocol)
        }
    }

    func testBlockchainRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting Blockchain url rotation away from invalid for protocol: \(transportProtocol.description)")

        let blockchain = try createBlockchainConnection(transportProtocol: transportProtocol)

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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making Blockchain request that should succeed via url rotation after prior failure")
        blockchain.getLastBlockInfo {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }

    func testConsensusRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting Consensus url rotation away from invalid for protocol: \(transportProtocol.description)")

        let consensus = try createConsensusConnection(transportProtocol: transportProtocol)
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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making Consensus request that should succeed via url rotation after prior failure")
        consensus.proposeTx(fixture.tx) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }
    
    func testFogBlockRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting FogBlock url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogBlock = try createFogBlockConnection(transportProtocol: transportProtocol)

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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making FogBlock request that should succeed via url rotation after prior failure")
        fogBlock.getBlocks(
            request: FogLedger_BlockRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }

    func testFogKeyImageRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting FogKeyImage url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogKeyImage = try createFogKeyImageConnection(transportProtocol: transportProtocol)

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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making FogKeyImage request that should succeed via url rotation after prior failure")
        fogKeyImage.checkKeyImages(
            request:FogLedger_CheckKeyImagesRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }

    func testFogMerkleProofRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting FogMerkleProof url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogMerkleProof = try createFogMerkleProofConnection(transportProtocol: transportProtocol)

        let expectFailure = expectation(description: "Making FogMerkleProof request against invalid URL")
        fogMerkleProof.getOutputs(
            request:FogLedger_GetOutputsRequest()
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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making FogMerkleProof request that should succeed via url rotation after prior failure")
        fogMerkleProof.getOutputs(
            request:FogLedger_GetOutputsRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }

    func testFogUntrustedTxOutRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting FogUntrustedTxOut url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogUntrustedTxOut = try createFogUntrustedTxOutConnection(transportProtocol: transportProtocol)

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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making FogUntrustedTxOut request that should succeed via url rotation after prior failure")
        fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest() ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }

    func testFogViewRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        print("\n-----\nTesting FogView url rotation away from invalid for protocol: \(transportProtocol.description)")

        let fogView = try createFogViewConnection(transportProtocol: transportProtocol)

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
        waitForExpectations(timeout: expectationTimeout)

        let expectSuccess = expectation(description: "Making FogView request that should succeed via url rotation after prior failure")
        fogView.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: expectationTimeout)
    }
}

extension UrlLoadBalancerIntTests {

    func createValidConsensusUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        let consensusUrls = try ConsensusUrl.make(strings: [IntegrationTestFixtures.network.consensusUrl]).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    func createValidFogUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<FogUrl> {
        let fogUrls = try FogUrl.make(strings: [IntegrationTestFixtures.network.fogUrl]).get()
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

    func createFogViewConnection(transportProtocol: TransportProtocol) throws -> FogViewConnection {
        let fogUrlLoadBalancer = try createTestFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        fogUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: try createValidConsensusUrlLoadBalancer(),
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let fogView = FogViewConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        fogUrlLoadBalancer.rotationEnabled = true

        return fogView
    }

    func createFogUntrustedTxOutConnection(transportProtocol: TransportProtocol)
    throws -> FogUntrustedTxOutConnection {
        let fogUrlLoadBalancer = try createTestFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        fogUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: try createTestConsensusUrlLoadBalancer(),
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let fogUntrustedTxOut = FogUntrustedTxOutConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        fogUrlLoadBalancer.rotationEnabled = true

        return fogUntrustedTxOut
    }

    func createFogMerkleProofConnection(transportProtocol: TransportProtocol)
    throws -> FogMerkleProofConnection {
        let fogUrlLoadBalancer = try createTestFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        fogUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: try createValidConsensusUrlLoadBalancer(),
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let fogMerkleProof = FogMerkleProofConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        fogUrlLoadBalancer.rotationEnabled = true

        return fogMerkleProof
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

    func createFogBlockConnection(transportProtocol: TransportProtocol)
    throws -> FogBlockConnection {
        let fogUrlLoadBalancer = try createTestFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        fogUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: try createValidConsensusUrlLoadBalancer(),
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let fogBlock = FogBlockConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        fogUrlLoadBalancer.rotationEnabled = true

        return fogBlock
    }

    func createBlockchainConnection(transportProtocol: TransportProtocol)
    throws -> BlockchainConnection {
        let consensusUrlLoadBalancer = try createTestConsensusUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        consensusUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: try createValidFogUrlLoadBalancer())
        let blockchain = BlockchainConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        consensusUrlLoadBalancer.rotationEnabled = true

        return blockchain
    }

    func createConsensusConnection(transportProtocol: TransportProtocol)
    throws -> ConsensusConnection {
        let consensusUrlLoadBalancer = try createTestConsensusUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        consensusUrlLoadBalancer.rotationEnabled = false

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: try createValidFogUrlLoadBalancer())
        let consensus = ConsensusConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        // enable URL rotation prior to actual server calls
        consensusUrlLoadBalancer.rotationEnabled = true

        return consensus
    }
}
