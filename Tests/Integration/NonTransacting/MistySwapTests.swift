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

    func testInitiateOfframpRequest() throws {
        // HTTP not supported
        try initiateOfframpRequest(transportProtocol: .grpc)
    }

    func initiateOfframpRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapConnection(transportProtocol: transportProtocol)
        let fixture = try Mistyswap.Fixtures.InitiateOfframp()

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.initiateOfframp(
            request: fixture.request
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("Mistyswap Initiate Offramp Response \(response)")
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

            print("Mistyswap Get Offramp Status Response \(response)")
            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }
    
    func testForgetOfframpRequest() throws {
        // HTTP not supported
        try forgetOfframpRequest(transportProtocol: .grpc)
    }

    func forgetOfframpRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapConnection(transportProtocol: transportProtocol)
        let fixture = try Mistyswap.Fixtures.ForgetOfframp()

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.forgetOfframp(
            request: fixture.request
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("Mistyswap Get Offramp Status Response \(response)")
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
