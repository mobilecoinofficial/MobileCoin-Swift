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
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
        try offrampRequest(transportProtocol: .grpc)
//        }
    }

    func offrampRequest(transportProtocol: TransportProtocol) throws {
        let mistyswapConnection = try createMistyswapConnection(transportProtocol: transportProtocol)

        let expect = expectation(description: "Making Mistyswap enclave request")
        mistyswapConnection.initiateOfframp(
            request: Mistyswap_InitiateOfframpRequest()
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

//            print("highestProcessedBlockCount: \(response.highestProcessedBlockCount)")
//            print("lastKnownBlockCount: \(response.lastKnownBlockCount)")
//            print("lastKnownBlockCumulativeTxoCount: \(response.lastKnownBlockCumulativeTxoCount)")
//
//            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
//            XCTAssertGreaterThan(response.rngs.count, 0)
//            XCTAssertEqual(response.txOutSearchResults.count, 0)
//            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
//            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

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
