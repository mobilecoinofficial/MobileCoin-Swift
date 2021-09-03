//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import NIOSSL
import XCTest

class ConsensusConnectionIntTests: XCTestCase {
    func testAttestationWorks() throws {
        // Run test multiple times to minimize the chance that the server assigned by the load
        // balancer for the attest call is the same server that is assigned for the proposeTx call.
        for _ in (0..<3) {
            let fixture = try Transaction.Fixtures.Default()

            let expect = expectation(description: "Consensus connection")
            try createConsensusConnection().proposeTx(fixture.tx, completion: {
                guard let response = $0.successOrFulfill(expectation: expect) else { return }
                print("response: \(response)")

                XCTAssertNotEqual(response.result, .ok)
                XCTAssertGreaterThan(response.blockCount, 0)

                expect.fulfill()
            })
            waitForExpectations(timeout: 20)
        }
    }

    func testMultipleCalls() throws {
        let fixture = try Transaction.Fixtures.Default()
        let connection = try createConsensusConnection()

        let expect = expectation(description: "Consensus connection")
        connection.proposeTx(fixture.tx) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("result: \(response.result)")
            print("blockCount: \(response.blockCount)")

            XCTAssertNotEqual(response.result, .ok)
            XCTAssertGreaterThan(response.blockCount, 0)

            connection.proposeTx(fixture.tx) {
                guard let response = $0.successOrFulfill(expectation: expect) else { return }

                print("result: \(response.result)")
                print("blockCount: \(response.blockCount)")

                XCTAssertNotEqual(response.result, .ok)
                XCTAssertGreaterThan(response.blockCount, 0)

                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
    }

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.consensusRequiresCredentials)

        let fixture = try Transaction.Fixtures.Default()

        let expect = expectation(description: "Consensus connection")
        try createConsensusConnectionWithInvalidCredentials().proposeTx(fixture.tx, completion: {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        })
        waitForExpectations(timeout: 20)
    }

    func testTrustRootWorks() throws {
        let fixture = try Transaction.Fixtures.Default()
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection = try createConsensusConnection(trustRoots: trustRootsFixture.trustRoots)

        let expect = expectation(description: "Consensus connection")
        connection.proposeTx(fixture.tx, completion: {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("result: \(response.result)")
            print("blockCount: \(response.blockCount)")

            XCTAssertNotEqual(response.result, .ok)
            XCTAssertGreaterThan(response.blockCount, 0)

            expect.fulfill()
        })
        waitForExpectations(timeout: 20)
    }

    func testExtraTrustRootWorks() throws {
        let fixture = try Transaction.Fixtures.Default()
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection = try createConsensusConnection(
            trustRoots: trustRootsFixture.trustRoots + [trustRootsFixture.wrongTrustRoot])

        let expect = expectation(description: "Consensus connection")
        connection.proposeTx(fixture.tx, completion: {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("result: \(response.result)")
            print("blockCount: \(response.blockCount)")

            XCTAssertNotEqual(response.result, .ok)
            XCTAssertGreaterThan(response.blockCount, 0)

            expect.fulfill()
        })
        waitForExpectations(timeout: 20)
    }

    func testWrongTrustRootFails() throws {
        // Skipped because gRPC currently keeps retrying connection errors indefinitely.
        try XCTSkipIf(true)

        let fixture = try Transaction.Fixtures.Default()
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection =
            try createConsensusConnection(trustRoots: [trustRootsFixture.wrongTrustRoot])

        let expect = expectation(description: "Consensus connection")
        connection.proposeTx(fixture.tx, completion: {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        })
        waitForExpectations(timeout: .infinity)
    }

}

extension ConsensusConnectionIntTests {
    func createConsensusConnection() throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig()
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnection(trustRoots: [NIOSSLCertificate]) throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(trustRoots: trustRoots)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnectionWithInvalidCredentials() throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials()
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnection(networkConfig: NetworkConfig) -> ConsensusConnection {
        ConsensusConnection(
            config: networkConfig.consensus,
            channelManager: GrpcChannelManager(),
            httpRequester: networkConfig.httpRequester,
            targetQueue: DispatchQueue.main)
    }
}
