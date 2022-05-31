//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class ConnectionIntTests: XCTestCase {
    func testInvalidUrlTimeout() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            print("Testing \(transportProtocol.description) with timeout = " +
                  "\(transportProtocol.testTimeoutInSeconds)")
            try testInvalidUrlTimeout(using: transportProtocol)
        }
    }

    func testInvalidUrlTimeout(using transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [1..<2]
        try IntegrationTestFixtures.createFogBlockConnectionWithInvalidUrls(
            using: transportProtocol)
            .getBlocks(request: request)
            {
                guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                switch error {
                case .connectionFailure:
                    break
                default:
                    XCTFail("error of type \(type(of: error)), \(error)")
                }
                expect.fulfill()
            }

        waitForExpectations(timeout: transportProtocol.testTimeoutInSeconds)
    }

    func testInvalidUrlAttestationTimeout() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            print("Testing \(transportProtocol.description) with timeout = " +
                  "\(transportProtocol.testTimeoutInSeconds)")
            try testInvalidUrlAttestationTimeout(using: transportProtocol)
        }
    }

    func testInvalidUrlAttestationTimeout(using transportProtocol: TransportProtocol) throws {
        let fixture = try Transaction.Fixtures.Default()

        let expect = expectation(
            description: "Attested Call to invalid URL should timeout for protocol: " +
                "\(transportProtocol.description)")
        try IntegrationTestFixtures.createConsensusConnectionWithInvalidUrls(
            transportProtocol: transportProtocol)
            .proposeTx(fixture.tx, completion: {
                guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                switch error {
                case .connectionFailure:
                    break
                default:
                    XCTFail("error of type \(type(of: error)), \(error)")
                }
                expect.fulfill()
            })

        waitForExpectations(timeout: transportProtocol.testTimeoutInSeconds)
    }
}
