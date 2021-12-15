//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class ConsensusConnectionIntTests: XCTestCase {
    func testAttestationWorks() throws {
       try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try attestationWorks(transportProtocol: transportProtocol)
        }
    }
    
    func attestationWorks(transportProtocol: TransportProtocol) throws {
        // Run test multiple times to minimize the chance that the server assigned by the load
        // balancer for the attest call is the same server that is assigned for the proposeTx call.
        for _ in (0..<3) {
            let fixture = try Transaction.Fixtures.Default()

            let expect = expectation(description: "Consensus connection")
            try createConsensusConnection(transportProtocol: transportProtocol).proposeTx(fixture.tx, completion: {
                guard let response = $0.successOrFulfill(expectation: expect) else { return }
                print("response: \(response)")

                XCTAssertNotEqual(response.result, .ok)
                XCTAssertGreaterThan(response.blockCount, 0)

                expect.fulfill()
            })
            waitForExpectations(timeout: 20)
        }
    }

    func testMultipleCallsGRPC() throws {
        try multipleCalls(transportProtocol: TransportProtocol.grpc)
    }
    
    func testMultipleCallsHTTP() throws {
        try multipleCalls(transportProtocol: TransportProtocol.http)
    }
    
    func multipleCalls(transportProtocol: TransportProtocol) throws {
        let fixture = try Transaction.Fixtures.Default()
        let connection = try createConsensusConnection(transportProtocol: transportProtocol)

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

    func testInvalidCredentialsReturnsAuthorizationFailureGRPC() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.grpc)
    }
    
    func testInvalidCredentialsReturnsAuthorizationFailureHTTP() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.http)
    }
    
    func invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.consensusRequiresCredentials)

        let fixture = try Transaction.Fixtures.Default()
        let connection = try createConsensusConnectionWithInvalidCredentials(transportProtocol: TransportProtocol.grpc)

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
        waitForExpectations(timeout: 20)
    }

    func testTrustRootWorksGRPC() throws {
        try trustRootWorks(transportProtocol: TransportProtocol.grpc)
    }
    
    func testTrustRootWorksHTTP() throws {
        try trustRootWorks(transportProtocol: TransportProtocol.http)
    }
    
    func trustRootWorks(transportProtocol: TransportProtocol) throws {
        let fixture = try Transaction.Fixtures.Default()
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection = try createConsensusConnection(transportProtocol: transportProtocol, trustRoots: trustRootsFixture.trustRootsBytes)

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

    func testExtraTrustRootWorksGRPC() throws {
        try extraTrustRootWorks(transportProtocol: TransportProtocol.grpc)
    }
    
    func testExtraTrustRootWorksHTTP() throws {
        try extraTrustRootWorks(transportProtocol: TransportProtocol.http)
    }
    
    func extraTrustRootWorks(transportProtocol: TransportProtocol) throws {
        let fixture = try Transaction.Fixtures.Default()
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection = try createConsensusConnection(
            transportProtocol: transportProtocol,
            trustRoots: trustRootsFixture.trustRootsBytes + [trustRootsFixture.wrongTrustRootBytes])
        
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

    func testWrongTrustRootFailsGRPC() throws {
        try wrongTrustRootFails(transportProtocol: TransportProtocol.grpc)
    }
    
    func testWrongTrustRootFailsHTTP() throws {
        try wrongTrustRootFails(transportProtocol: TransportProtocol.http)
    }
    
    func wrongTrustRootFails(transportProtocol: TransportProtocol) throws {
        // Skipped because gRPC currently keeps retrying connection errors indefinitely.
        try XCTSkipIf(true)
        let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
        let connection =
            try createConsensusConnection(transportProtocol: transportProtocol, trustRoots: [trustRootsFixture.wrongTrustRootBytes])

        let fixture = try Transaction.Fixtures.Default()

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
    func createConsensusConnection(transportProtocol: TransportProtocol = TransportProtocol.grpc) throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnection(transportProtocol: TransportProtocol, trustRoots: [Data]) throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol, trustRoots: trustRoots)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    func createConsensusConnection(networkConfig: NetworkConfig) -> ConsensusConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return ConsensusConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig.consensus,
            targetQueue: DispatchQueue.main)
    }
}
