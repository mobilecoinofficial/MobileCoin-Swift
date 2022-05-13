//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

// swiftlint:disable line_length

class ConnectionIntTests: XCTestCase {

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

    func testInvalidUrlTimeout() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            let timeToWait = timeoutInSeconds(for: transportProtocol)
            print("Testing \(transportProtocol.description) with timeout = \(timeToWait)")
            try testInvalidUrlTimeout(using: transportProtocol, andWaitFor: timeToWait)
        }
    }

    func testInvalidUrlTimeout(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
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
        
        waitForExpectations(timeout: timeToWait)
    }

    func testInvalidUrlAttestationTimeout() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            let timeToWait = timeoutInSeconds(for: transportProtocol)
            print("Testing \(transportProtocol.description) with timeout = \(timeToWait)")
            try testInvalidUrlAttestationTimeout(using: transportProtocol, andWaitFor: timeToWait)
        }
    }

    func testInvalidUrlAttestationTimeout(using transportProtocol: TransportProtocol, andWaitFor timeToWait: Double) throws {
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

        waitForExpectations(timeout: timeToWait)
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
