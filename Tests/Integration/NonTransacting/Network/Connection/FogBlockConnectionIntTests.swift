//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogBlockConnectionIntTests: XCTestCase {
    func testGetBlocks() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocks(transportProtocol: transportProtocol)
        }
    }

    func getBlocks(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")
        let fixtures = FogBlockConnection.Fixtures.Default()
        let request = fixtures.request
        try createFogBlockConnection(
            transportProtocol: transportProtocol
        ).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.blocks.count, request.ranges.count)
            if let block = response.blocks.first {
                XCTAssertEqual(block.index, fixtures.range.lowerBound)
                XCTAssertGreaterThan(block.globalTxoCount, 0)
                XCTAssertGreaterThan(block.outputs.count, 0)
            }
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testGetBlockZero() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlockZero(transportProtocol: transportProtocol)
        }
    }

    func getBlockZero(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<1]
        try createFogBlockConnection(
            transportProtocol: transportProtocol
        ).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, request.ranges.count)
            if let block = response.blocks.first {
                XCTAssertEqual(block.index, 0)
                // TODO: based on the proto comments, this should be 0, but it currently
                // returns txo count up to and including this block
                XCTAssertEqual(block.globalTxoCount, UInt64(0 + block.outputs.count))
                XCTAssertGreaterThan(block.outputs.count, 0)
            }
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 60)
    }

    func testGetBlocksReturnsNoBlocksWithoutRange() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocksReturnsNoBlocksWithoutRange(transportProtocol: transportProtocol)
        }
    }

    func getBlocksReturnsNoBlocksWithoutRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        try createFogBlockConnection(
            transportProtocol: transportProtocol
        ).getBlocks(request: FogLedger_BlockRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testGetBlocksReturnsNoBlocksForEmptyRange() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: transportProtocol)
        }
    }

    func getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<0]
        try createFogBlockConnection(
            transportProtocol: transportProtocol
        ).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testDoSGetBlocks() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try doSGetBlocks(transportProtocol: transportProtocol)
        }
    }

    func doSGetBlocks(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")
        let group = DispatchGroup()
        for _ in (0..<100) {
            var request = FogLedger_BlockRequest()
            request.rangeValues = [0..<UInt64.max]

            group.enter()
            try createFogBlockConnection(
                transportProtocol: transportProtocol
            ).getBlocks(request: request) {
                guard let response = $0.successOrLeaveGroup(group) else { return }

                XCTAssertEqual(response.blocks.count, 0)
                XCTAssertGreaterThan(response.numBlocks, 0)
                XCTAssertGreaterThan(response.globalTxoCount, 0)

                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: transportProtocol)
        }
    }

    func invalidCredentialsReturnsAuthorizationFailure(
        transportProtocol: TransportProtocol
    ) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [1..<2]
        try createFogBlockConnectionWithInvalidCredentials(
            transportProtocol: transportProtocol
        ).getBlocks(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

}

extension FogBlockConnectionIntTests {
    func createFogBlockConnection(
        transportProtocol: TransportProtocol
    ) throws -> FogBlockConnection {
        let networkConfig = try NetworkConfigFixtures.create(
                using: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnectionWithInvalidCredentials(
        transportProtocol: TransportProtocol
    ) throws -> FogBlockConnection {
        let networkConfig = try NetworkConfigFixtures.createWithInvalidCredentials(
                using: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnection(networkConfig: NetworkConfig) -> FogBlockConnection {
        let httpFactory = HttpProtocolConnectionFactory(
                httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogBlockConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}

// TODO find way to put in its own file
extension FogBlockConnection {
    enum Fixtures {}
}

extension FogBlockConnection.Fixtures {
    struct Default {
        let request: FogLedger_BlockRequest
        let range: Range<UInt64>

        init() {
            var request = FogLedger_BlockRequest()
            request.rangeValues = [Self.getNetworkRange()]
            self.request = request
            self.range = Self.getNetworkRange()
        }

        static func getNetworkRange() -> Range<UInt64> {
            switch IntegrationTestFixtures.network {
            case .mobiledev:
                return 10..<11
            case .testNet:
                return 1..<2
            default:
                return 1..<2
            }
        }
    }
}
