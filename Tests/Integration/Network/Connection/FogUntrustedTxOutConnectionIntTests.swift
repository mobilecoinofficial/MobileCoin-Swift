//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogUntrustedTxOutConnectionIntTests: XCTestCase {
    func testGetTxOutsReturnsNoResultsWithoutPubkeys() throws {
        let expect = expectation(description: "Fog GetTxOuts request")
        try createFogUntrustedTxOutConnection().getTxOuts(request: FogLedger_TxOutRequest()) {
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

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Fog GetTxOuts request")
        let connection = try createFogUntrustedTxOutConnectionWithInvalidCredentials()
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
    func createFogUntrustedTxOutConnection() throws -> FogUntrustedTxOutConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig()
        return createFogUntrustedTxOutConnection(networkConfig: networkConfig)
    }

    func createFogUntrustedTxOutConnectionWithInvalidCredentials() throws
        -> FogUntrustedTxOutConnection
    {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials()
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
