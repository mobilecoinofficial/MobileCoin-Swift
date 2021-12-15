//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogKeyImageConnectionIntTests: XCTestCase {
    func testCheckKeyImagesReturnsNotSpentForFakeKeyImageGRPC() throws {
        try checkKeyImagesReturnsNotSpentForFakeKeyImage(transportProtocol: TransportProtocol.grpc)
    }
    
    func testCheckKeyImagesReturnsNotSpentForFakeKeyImageHTTP() throws {
        try checkKeyImagesReturnsNotSpentForFakeKeyImage(transportProtocol: TransportProtocol.http)
    }
    
    func checkKeyImagesReturnsNotSpentForFakeKeyImage(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnection(transportProtocol:transportProtocol).checkKeyImages(request: request) {
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

    func testCheckKeyImagesResponseIsPaddedForTooShortKeyImageGRPC() throws {
        try checkKeyImagesResponseIsPaddedForTooShortKeyImage(transportProtocol: TransportProtocol.grpc)
    }
    
    func testCheckKeyImagesResponseIsPaddedForTooShortKeyImageHTTP() throws {
        try checkKeyImagesResponseIsPaddedForTooShortKeyImage(transportProtocol: TransportProtocol.http)
    }
    
    func checkKeyImagesResponseIsPaddedForTooShortKeyImage(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 0))
        request.queries = [query]
        try createFogKeyImageConnection(transportProtocol:transportProtocol).checkKeyImages(request: request) {
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

    func testCheckKeyImagesResponseFailsForTooLongKeyImageGRPC() throws {
        try checkKeyImagesResponseFailsForTooLongKeyImage(transportProtocol: TransportProtocol.grpc)
    }
    
    func testCheckKeyImagesResponseFailsForTooLongKeyImageHTTP() throws {
        try checkKeyImagesResponseFailsForTooLongKeyImage(transportProtocol: TransportProtocol.http)
    }
    
    func checkKeyImagesResponseFailsForTooLongKeyImage(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 33))
        request.queries = [query]
        try createFogKeyImageConnection(transportProtocol:transportProtocol).checkKeyImages(request: request) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }
            print("error: \(error)")

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

        let expect = expectation(description: "Fog CheckKeyImages request")

        var request = FogLedger_CheckKeyImagesRequest()
        var query = FogLedger_KeyImageQuery()
        query.keyImage = External_KeyImage(Data(repeating: 0, count: 32))
        request.queries = [query]
        try createFogKeyImageConnectionWithInvalidCredentials(transportProtocol:transportProtocol).checkKeyImages(request: request) {
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
    func createFogKeyImageConnection(transportProtocol:TransportProtocol) throws -> FogKeyImageConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol:transportProtocol)
        return createFogKeyImageConnection(networkConfig: networkConfig)
    }

    func createFogKeyImageConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> FogKeyImageConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogKeyImageConnection(networkConfig: networkConfig)
    }

    func createFogKeyImageConnection(networkConfig: NetworkConfig) -> FogKeyImageConnection {
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogKeyImageConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig.fogKeyImage,
            targetQueue: DispatchQueue.main)
    }
}
