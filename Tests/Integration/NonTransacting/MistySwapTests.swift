//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable superfluous_disable_command
// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable empty_xctest_method

import LibMobileCoin
@testable import MobileCoin
import XCTest

class MistyswapTests: XCTestCase {

    func testOfframpRequest() throws {
        // HTTP not supported
        try offrampRequest(transportProtocol: .grpc)
    }

    func offrampRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapConnection(transportProtocol: transportProtocol)
        let fixture = try Mistyswap.Fixtures.InitiateOfframp()

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.initiateOfframp(
            request: request
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }
    
    func testGetOfframpStatusRequest() throws {
        // HTTP not supported
        try getOfframpStatusRequest(transportProtocol: .grpc)
    }

    func getOfframpStatusRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapConnection(transportProtocol: transportProtocol)
        let fixture = try Mistyswap.Fixtures.GetOfframpStatus()

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.getOfframpStatus(
            request: fixture.request
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }
    
}

extension MistyswapTests {
    func createMistyswapConnection(transportProtocol: TransportProtocol) throws -> MistyswapConnection {
        let networkConfig = try NetworkConfigFixtures.create(using: transportProtocol)
        return createMistyswapConnection(networkConfig: networkConfig)
    }
    
    func createMistyswapConnectionWithInvalidCredentials(
        transportProtocol: TransportProtocol
    ) throws -> MistyswapConnection {
        let networkConfig = try NetworkConfigFixtures.createWithInvalidCredentials(
            using: transportProtocol)
        return createMistyswapConnection(networkConfig: networkConfig)
    }
    
    func createMistyswapConnection(networkConfig: NetworkConfig) -> MistyswapConnection {
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return MistyswapConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
