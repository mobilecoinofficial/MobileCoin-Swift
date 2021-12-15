//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogMerkleProofConnectionIntTests: XCTestCase {
    func testGetOutputsRequestGRPC() throws {
        try getOutputsRequest(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetOutputsRequestHTTP() throws {
        try getOutputsRequest(transportProtocol: TransportProtocol.http)
    }
    
    func getOutputsRequest(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = [0]
        request.merkleRootBlock = 10
        try createFogMerkleProofConnection(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.results.count, request.indices.count)
            XCTAssertEqual(response.results.map { $0.index }, request.indices)
            XCTAssertEqual(response.results.map { $0.proof.index }, request.indices)
            for outputResult in response.results {
                XCTAssertEqual(outputResult.resultCodeEnum, .exists)
                XCTAssertEqual(outputResult.proof.highestIndex, response.globalTxoCount - 1)
            }
            XCTAssertGreaterThan(response.globalTxoCount, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetOutputsReturnsNoResultsWhenSearchingForZeroIndicesGRPC() throws {
        try getOutputsReturnsNoResultsWhenSearchingForZeroIndices(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetOutputsReturnsNoResultsWhenSearchingForZeroIndicesHTTP() throws {
        try getOutputsReturnsNoResultsWhenSearchingForZeroIndices(transportProtocol: TransportProtocol.http)
    }
    
    func getOutputsReturnsNoResultsWhenSearchingForZeroIndices(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = []
        request.merkleRootBlock = 10
        try createFogMerkleProofConnection(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.results.count, request.indices.count)
            XCTAssertGreaterThan(response.globalTxoCount, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetOutputsRequestAcceptsUIntMinMerkleRootBlockGRPC() throws {
        try getOutputsRequestAcceptsUIntMinMerkleRootBlock(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetOutputsRequestAcceptsUIntMinMerkleRootBlockHTTP() throws {
        try getOutputsRequestAcceptsUIntMinMerkleRootBlock(transportProtocol: TransportProtocol.http)
    }
    
    func getOutputsRequestAcceptsUIntMinMerkleRootBlock(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = [0]
        request.merkleRootBlock = 0
        try createFogMerkleProofConnection(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.results.count, request.indices.count)
            XCTAssertEqual(response.results.map { $0.index }, request.indices)
            XCTAssertEqual(response.results.map { $0.proof.index }, request.indices)
            for outputResult in response.results {
                XCTAssertEqual(outputResult.resultCodeEnum, .exists)
                XCTAssertEqual(outputResult.proof.highestIndex, response.globalTxoCount - 1)
            }
            XCTAssertGreaterThan(response.globalTxoCount, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetOutputsRequestAcceptsUIntMaxMerkleRootBlockGRPC() throws {
        try getOutputsRequestAcceptsUIntMaxMerkleRootBlock(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetOutputsRequestAcceptsUIntMaxMerkleRootBlockHTTP() throws {
        try getOutputsRequestAcceptsUIntMaxMerkleRootBlock(transportProtocol: TransportProtocol.http)
    }
    
    func getOutputsRequestAcceptsUIntMaxMerkleRootBlock(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = [0]
        request.merkleRootBlock = .max
        try createFogMerkleProofConnection(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.results.count, request.indices.count)
            XCTAssertEqual(response.results.map { $0.index }, request.indices)
            XCTAssertEqual(response.results.map { $0.proof.index }, request.indices)
            for outputResult in response.results {
                XCTAssertEqual(outputResult.resultCodeEnum, .exists)
                XCTAssertEqual(outputResult.proof.highestIndex, response.globalTxoCount - 1)
            }
            XCTAssertGreaterThan(response.globalTxoCount, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetOutputsRequestReturnsNotFoundForUIntMaxGRPC() throws {
        try getOutputsRequestReturnsNotFoundForUIntMax(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetOutputsRequestReturnsNotFoundForUIntMaxHTTP() throws {
        try getOutputsRequestReturnsNotFoundForUIntMax(transportProtocol: TransportProtocol.http)
    }
    
    func getOutputsRequestReturnsNotFoundForUIntMax(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = [.max]
        request.merkleRootBlock = .max
        try createFogMerkleProofConnection(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.results.count, request.indices.count)
            XCTAssertEqual(response.results.map { $0.index }, request.indices)
            for outputResult in response.results {
                XCTAssertEqual(outputResult.resultCodeEnum, .doesNotExist)
            }
            XCTAssertGreaterThan(response.globalTxoCount, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testInvalidCredentialsReturnsAuthorizationFailureGRPC() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.grpc)
    }
    
    func testInvalidCredentialsReturnsAuthorizationFailureHTTP() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.http)
    }
    
    func invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Making Fog MerkleProof GetOutputs request")

        var request = FogLedger_GetOutputsRequest()
        request.indices = [0]
        request.merkleRootBlock = 10
        try createFogMerkleProofConnectionWithInvalidCredentials(transportProtocol:transportProtocol).getOutputs(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }
}

extension FogMerkleProofConnectionIntTests {
    func createFogMerkleProofConnection(transportProtocol: TransportProtocol) throws -> FogMerkleProofConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createFogMerkleProofConnection(networkConfig: networkConfig)
    }

    func createFogMerkleProofConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> FogMerkleProofConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogMerkleProofConnection(networkConfig: networkConfig)
    }

    func createFogMerkleProofConnection(networkConfig: NetworkConfig) -> FogMerkleProofConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogMerkleProofConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig.fogMerkleProof,
            targetQueue: DispatchQueue.main)
    }
}
