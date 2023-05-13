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

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.initiateOfframp(
            request: Mistyswap_InitiateOfframpRequest()
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

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.getOfframpStatus(
            request: Mistyswap_GetOfframpStatusRequest()
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }
    
    func testForgetOfframpRequest() throws {
        // HTTP not supported
        try forgetOfframpRequest(transportProtocol: .grpc)
    }

    func forgetOfframpRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapUntrustedConnection(transportProtocol: transportProtocol)

        let expect = expectation(description: "Making Mistyswap untrusted request")
        mistyswapConnection.forgetOfframp(
            request: Mistyswap_ForgetOfframpRequest()
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

extension MistyswapTests {
    func createMistyswapUntrustedConnection(transportProtocol: TransportProtocol) throws -> MistyswapUntrustedConnection {
        let networkConfig = try NetworkConfigFixtures.create(using: transportProtocol)
        return createMistyswapUntrustedConnection(networkConfig: networkConfig)
    }

    func createMistyswapUntrustedConnectionWithInvalidCredentials(
        transportProtocol: TransportProtocol
    ) throws -> MistyswapUntrustedConnection {
        let networkConfig = try NetworkConfigFixtures.createWithInvalidCredentials(
                using: transportProtocol)
        return createMistyswapUntrustedConnection(networkConfig: networkConfig)
    }

    func createMistyswapUntrustedConnection(networkConfig: NetworkConfig) -> MistyswapUntrustedConnection {
        let httpFactory = HttpProtocolConnectionFactory(
                httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return MistyswapUntrustedConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
