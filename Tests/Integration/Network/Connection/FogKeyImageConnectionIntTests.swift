//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogKeyImageConnectionIntTests: XCTestCase {
    func testCheckKeyImagesReturnsNotSpentForFakeKeyImage() throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnection().checkKeyImages(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.results.count, request.queries.count)
            XCTAssertEqual(
                response.results.map { $0.keyImage.data },
                request.queries.map { $0.keyImage.data })
            for result in response.results {
                XCTAssertNotEqual(result.spentAt, 0)
                XCTAssertNotEqual(result.timestamp, 0)
                XCTAssertNotEqual(result.timestampResultCode, 0)
                XCTAssertEqual(result.keyImageResultCodeEnum, .notSpent)
            }

            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testCheckKeyImagesResponseIsPaddedForTooShortKeyImage() throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 0))
        request.queries = [query]
        try createFogKeyImageConnection().checkKeyImages(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertEqual(response.results.count, request.queries.count)
            for result in response.results {
                XCTAssertEqual(result.keyImage.data.count, 32)
                XCTAssertNotEqual(result.spentAt, 0)
                XCTAssertNotEqual(result.timestamp, 0)
                XCTAssertNotEqual(result.timestampResultCode, 0)
                XCTAssertEqual(result.keyImageResultCodeEnum, .notSpent)
            }

            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testCheckKeyImagesResponseFailsForTooLongKeyImage() throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 33))
        request.queries = [query]
        try createFogKeyImageConnection().checkKeyImages(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }
            print("error: \(error)")

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try XCTSkipUnless(IntegrationTestFixtures.fogRequiresCredentials)

        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnectionWithInvalidCredentials().checkKeyImages(request: request) {
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

extension FogKeyImageConnectionIntTests {
    func createFogKeyImageConnection() throws -> FogKeyImageConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig()
        return FogKeyImageConnection(
            config: networkConfig.fogKeyImage,
            channelManager: GrpcChannelManager(),
            targetQueue: DispatchQueue.main)
    }

    func createFogKeyImageConnectionWithInvalidCredentials() throws -> FogKeyImageConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials()
        return FogKeyImageConnection(
            config: networkConfig.fogKeyImage,
            channelManager: GrpcChannelManager(),
            targetQueue: DispatchQueue.main)
    }
}
