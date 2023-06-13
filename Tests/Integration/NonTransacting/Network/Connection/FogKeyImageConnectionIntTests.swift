//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin
import XCTest

class FogKeyImageConnectionIntTests: XCTestCase {
    func testCheckKeyImagesReturnsNotSpentForFakeKeyImage() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try checkKeyImagesReturnsNotSpentForFakeKeyImage(transportProtocol: transportProtocol)
        }
    }

    func checkKeyImagesReturnsNotSpentForFakeKeyImage(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnection(
            transportProtocol: transportProtocol
        ).checkKeyImages(request: request) {
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
        waitForExpectations(timeout: 40)
    }

    func testCheckKeyImagesResponseIsPaddedForTooShortKeyImage() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try checkKeyImagesResponseIsPaddedForTooShortKeyImage(
                    transportProtocol: transportProtocol)
        }
    }

    func checkKeyImagesResponseIsPaddedForTooShortKeyImage(
        transportProtocol: TransportProtocol
    ) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 0))
        request.queries = [query]
        try createFogKeyImageConnection(
            transportProtocol: transportProtocol
        ).checkKeyImages(request: request) {
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
        waitForExpectations(timeout: 40)
    }

    func testCheckKeyImagesResponseFailsForTooLongKeyImage() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try checkKeyImagesResponseFailsForTooLongKeyImage(transportProtocol: transportProtocol)
        }
    }

    func checkKeyImagesResponseFailsForTooLongKeyImage(
        transportProtocol: TransportProtocol
    ) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 33))
        request.queries = [query]
        try createFogKeyImageConnection(
            transportProtocol: transportProtocol
        ).checkKeyImages(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }
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

        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnectionWithInvalidCredentials(
            transportProtocol: transportProtocol
        ).checkKeyImages(request: request) {
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

extension FogKeyImageConnectionIntTests {
    func createFogKeyImageConnection(
        transportProtocol: TransportProtocol
    ) throws -> FogKeyImageConnection {
        let networkConfig = try NetworkConfigFixtures.create(using: transportProtocol)
        return createFogKeyImageConnection(networkConfig: networkConfig)
    }

    func createFogKeyImageConnectionWithInvalidCredentials(
        transportProtocol: TransportProtocol
    ) throws -> FogKeyImageConnection {
        let networkConfig = try NetworkConfigFixtures.createWithInvalidCredentials(
            using: transportProtocol)
        return createFogKeyImageConnection(networkConfig: networkConfig)
    }

    func createFogKeyImageConnection(networkConfig: NetworkConfig) -> FogKeyImageConnection {
        let httpFactory = HttpProtocolConnectionFactory(
                httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogKeyImageConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
