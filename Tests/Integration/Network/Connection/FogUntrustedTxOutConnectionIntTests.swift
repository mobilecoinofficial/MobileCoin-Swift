//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogUntrustedTxOutConnectionIntTests: XCTestCase {
    func testGetTxOutsReturnsNoResultsWithoutPubkeysGRPC() throws {
        try getTxOutsReturnsNoResultsWithoutPubkeys(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetTxOutsReturnsNoResultsWithoutPubkeysHTTP() throws {
        try getTxOutsReturnsNoResultsWithoutPubkeys(transportProtocol: TransportProtocol.http)
    }
    
    func getTxOutsReturnsNoResultsWithoutPubkeys(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetTxOuts request")
        try createFogUntrustedTxOutConnection(transportProtocol:transportProtocol).getTxOuts(request: FogLedger_TxOutRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }
            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.results.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

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

        let expect = expectation(description: "Fog GetTxOuts request")
        let connection = try createFogUntrustedTxOutConnectionWithInvalidCredentials(transportProtocol:transportProtocol)
        connection.getTxOuts(request: FogLedger_TxOutRequest()) {
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

extension FogUntrustedTxOutConnectionIntTests {
    func createFogUntrustedTxOutConnection(transportProtocol: TransportProtocol) throws -> FogUntrustedTxOutConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createFogUntrustedTxOutConnection(networkConfig: networkConfig)
    }

    func createFogUntrustedTxOutConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws
        -> FogUntrustedTxOutConnection
    {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogUntrustedTxOutConnection(networkConfig: networkConfig)
    }

    func createFogUntrustedTxOutConnection(networkConfig: NetworkConfig)
        -> FogUntrustedTxOutConnection
    {
        FogUntrustedTxOutConnection(
            config: networkConfig.fogUntrustedTxOut,
            channelManager: GrpcChannelManager(),
            httpRequester: TestHttpRequester(),
            targetQueue: DispatchQueue.main)
    }
}
