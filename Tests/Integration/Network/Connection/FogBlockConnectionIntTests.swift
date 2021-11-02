//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogBlockConnectionIntTests: XCTestCase {
    func testGetBlocksGRPC() throws {
        try getBlocks(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetBlocksHTTP() throws {
        try getBlocks(transportProtocol: TransportProtocol.http)
    }
    
    func getBlocks(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        let range: Range<UInt64> = 1..<2
        request.rangeValues = [range]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.blocks.count, request.ranges.count)
            if let block = response.blocks.first {
                XCTAssertEqual(block.index, range.lowerBound)
                XCTAssertGreaterThan(block.globalTxoCount, 0)
                XCTAssertGreaterThan(block.outputs.count, 0)
            }
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetBlockZeroGRPC() throws {
        try getBlockZero(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetBlockZeroHTTP() throws {
        try getBlockZero(transportProtocol: TransportProtocol.http)
    }
    
    func getBlockZero(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<1]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
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

    func testGetBlocksReturnsNoBlocksWithoutRangeGRPC() throws {
        try getBlocksReturnsNoBlocksWithoutRange(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetBlocksReturnsNoBlocksWithoutRangeHTTP() throws {
        try getBlocksReturnsNoBlocksWithoutRange(transportProtocol: TransportProtocol.http)
    }
    
    func getBlocksReturnsNoBlocksWithoutRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: FogLedger_BlockRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testGetBlocksReturnsNoBlocksForEmptyRangeGRPC() throws {
        try getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetBlocksReturnsNoBlocksForEmptyRangeHTTP() throws {
        try getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: TransportProtocol.http)
    }
    
    func getBlocksReturnsNoBlocksForEmptyRange(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [0..<0]
        try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.blocks.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testDoSGetBlocksGRPC() throws {
        try doSGetBlocks(transportProtocol: TransportProtocol.grpc)
    }
    
    func testDoSGetBlocksHTTP() throws {
        try doSGetBlocks(transportProtocol: TransportProtocol.http)
    }
    
    func doSGetBlocks(transportProtocol: TransportProtocol) throws {
        try XCTSkipIf(true)

        let expect = expectation(description: "Fog GetBlocks request")
        let group = DispatchGroup()
        for _ in (0..<100) {
            var request = FogLedger_BlockRequest()
            request.rangeValues = [0..<UInt64.max]

            group.enter()
            try createFogBlockConnection(transportProtocol:transportProtocol).getBlocks(request: request) {
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
        waitForExpectations(timeout: 20)
    }

    func testInvalidCredentialsReturnsAuthorizationFailureGRPC() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.grpc)
    }
    
    func testInvalidCredentialsReturnsAuthorizationFailureHTTP() throws {
        try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol.http)
    }
    
    func invalidCredentialsReturnsAuthorizationFailure(transportProtocol: TransportProtocol) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Fog GetBlocks request")

        var request = FogLedger_BlockRequest()
        request.rangeValues = [1..<2]
        try createFogBlockConnectionWithInvalidCredentials(transportProtocol:transportProtocol).getBlocks(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }
}

extension FogBlockConnectionIntTests {
    func createFogBlockConnection(transportProtocol: TransportProtocol) throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    func createFogBlockConnection(networkConfig: NetworkConfig) -> FogBlockConnection {
        FogBlockConnection(
            config: networkConfig.fogBlock,
            channelManager: GrpcChannelManager(),
            httpRequester: TestHttpRequester(),
            targetQueue: DispatchQueue.main)
    }
}
