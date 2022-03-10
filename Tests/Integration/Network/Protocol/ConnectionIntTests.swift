//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class ConnectionIntTests: XCTestCase {
    func testCallTimeoutWithInvalidUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testCallTimeoutWithInvalidUrl(transportProtocol: transportProtocol)
        }
    }

    func testCallTimeoutWithInvalidUrl(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [1..<2]
        try createFogBlockConnectionWithInvalidUrls(transportProtocol: transportProtocol).getBlocks(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 35)
    }

    func testAttestedCallTimeoutWithInvalidUrl() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try testAttestedCallTimeoutWithInvalidUrl(transportProtocol: transportProtocol)
        }
    }

    func testAttestedCallTimeoutWithInvalidUrl(transportProtocol: TransportProtocol) throws {
        let fixture = try Transaction.Fixtures.Default()

        let expect = expectation(description: "Attested Call to invalid URL should timeout for protocol: \(transportProtocol.description)")
        try createConsensusConnectionWithInvalidUrls(transportProtocol: transportProtocol).proposeTx(fixture.tx, completion: {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        })
        waitForExpectations(timeout: 35)
    }
}

extension ConnectionIntTests {
    func createConsensusConnectionWithInvalidUrls(transportProtocol: TransportProtocol) throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidUrls(transportProtocol: transportProtocol)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnection(networkConfig: NetworkConfig) -> ConsensusConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return ConsensusConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }

    func createFogBlockConnectionWithInvalidUrls(transportProtocol: TransportProtocol) throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidUrls(transportProtocol: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnection(networkConfig: NetworkConfig) -> FogBlockConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogBlockConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }

}
