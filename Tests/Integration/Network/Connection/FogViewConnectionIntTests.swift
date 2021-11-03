//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogViewConnectionIntTests: XCTestCase {
    func testEnclaveRequestGRPC() throws {
        try enclaveRequest(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestHTTP() throws {
        try enclaveRequest(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequest(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")
        fogViewConnection.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            print("highestProcessedBlockCount: \(response.highestProcessedBlockCount)")
            print("lastKnownBlockCount: \(response.lastKnownBlockCount)")
            print("lastKnownBlockCumulativeTxoCount: \(response.lastKnownBlockCumulativeTxoCount)")

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertGreaterThan(response.rngs.count, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsTxOutsGRPC() throws {
        try enclaveRequestReturnsTxOuts(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsTxOutsHTTP() throws {
        try enclaveRequestReturnsTxOuts(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsTxOuts(transportProtocol: TransportProtocol) throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        func fetchRngRecords(success: @escaping (FogView_RngRecord) -> Void) {
            fogViewConnection.query(
                requestAad: FogView_QueryRequestAAD(),
                request: FogView_QueryRequest()
            ) {
                guard let response = $0.successOrFulfill(expectation: expect) else { return }

                XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
                XCTAssertGreaterThan(response.rngs.count, 0)
                XCTAssertEqual(response.txOutSearchResults.count, 0)
                XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
                XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)
                guard !response.rngs.isEmpty else { expect.fulfill(); return }

                success(response.rngs[0])
            }
        }

        fetchRngRecords { rngRecord in
            XCTAssertNoThrowOrFulfill(expectation: expect, evaluating: {
                let fogRngKey = FogRngKey(rngRecord.pubkey)
                let rng = try FogRng.make(fogRngKey: fogRngKey, accountKey: accountKey).get()

                var request = FogView_QueryRequest()
                request.getTxos = rng.outputs(count: 5)
                fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
                    guard let response = $0.successOrFulfill(expectation: expect) else { return }

                    XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
                    XCTAssertEqual(response.txOutSearchResults.count, 5)
                    for txOutResult in response.txOutSearchResults {
                        XCTAssert(request.getTxos.contains(txOutResult.searchKey))
                    }
                    XCTAssertEqual(response.txOutSearchResults.first?.resultCodeEnum, .found)
                    XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
                    XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

                    expect.fulfill()
                }
            })
        }

        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsNotFoundForFakeDataGRPC() throws {
        try enclaveRequestReturnsNotFoundForFakeData(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsNotFoundForFakeDataHTTP() throws {
        try enclaveRequestReturnsNotFoundForFakeData(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsNotFoundForFakeData(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogView_QueryRequest()
        let fakeSearchKey = Data(repeating: 1, count: 16)
        request.getTxos = [fakeSearchKey]
        fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 1)
            if let result = response.txOutSearchResults.first {
                XCTAssertEqual(Array(result.searchKey), Array(fakeSearchKey))
                XCTAssertEqual(result.resultCodeEnum, .notFound)
            }
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsBadSearchKeyForEmptySearchKeyGRPC() throws {
        try enclaveRequestReturnsBadSearchKeyForEmptySearchKey(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsBadSearchKeyForEmptySearchKeyHTTP() throws {
        try enclaveRequestReturnsBadSearchKeyForEmptySearchKey(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsBadSearchKeyForEmptySearchKey(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogView_QueryRequest()
        let invalidSearchKey = Data(repeating: 0, count: 16)
        request.getTxos = [invalidSearchKey]
        fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 1)
            if let result = response.txOutSearchResults.first {
                XCTAssertEqual(Array(result.searchKey), Array(invalidSearchKey))
                XCTAssertEqual(result.resultCodeEnum, .badSearchKey)
            }
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsBadSearchKeyForInvalidSearchKeyGRPC() throws {
        try enclaveRequestReturnsBadSearchKeyForInvalidSearchKey(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsBadSearchKeyForInvalidSearchKeyHTTP() throws {
        try enclaveRequestReturnsBadSearchKeyForInvalidSearchKey(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsBadSearchKeyForInvalidSearchKey(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogView_QueryRequest()
        let invalidSearchKey = Data(repeating: 0, count: 0)
        request.getTxos = [invalidSearchKey]
        fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 1)
            if let result = response.txOutSearchResults.first {
                // TODO: this can be re-enabled once Fog returns the exact search key used
                // XCTAssertEqual(Array(result.searchKey), Array(invalidSearchKey))
                XCTAssertEqual(result.resultCodeEnum, .badSearchKey)
            }
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsBadSearchKeyForTooShortSearchKeyGRPC() throws {
        try enclaveRequestReturnsBadSearchKeyForTooShortSearchKey(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsBadSearchKeyForTooShortSearchKeyHTTP() throws {
        try enclaveRequestReturnsBadSearchKeyForTooShortSearchKey(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsBadSearchKeyForTooShortSearchKey(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogView_QueryRequest()
        let invalidSearchKey = Data(repeating: 1, count: 8)
        request.getTxos = [invalidSearchKey]
        fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 1)
            if let result = response.txOutSearchResults.first {
                // TODO: this can be re-enabled once Fog returns the exact search key used
                // XCTAssertEqual(Array(result.searchKey), Array(invalidSearchKey))
                XCTAssertEqual(result.resultCodeEnum, .badSearchKey)
            }
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsBadSearchKeyForTooLongSearchKeyGRPC() throws {
        try enclaveRequestReturnsBadSearchKeyForTooLongSearchKey(transportProtocol: TransportProtocol.grpc)
    }
    
    func testEnclaveRequestReturnsBadSearchKeyForTooLongSearchKeyHTTP() throws {
        try enclaveRequestReturnsBadSearchKeyForTooLongSearchKey(transportProtocol: TransportProtocol.http)
    }
    
    func enclaveRequestReturnsBadSearchKeyForTooLongSearchKey(transportProtocol: TransportProtocol) throws {
        let fogViewConnection = try createFogViewConnection(transportProtocol:transportProtocol)

        let expect = expectation(description: "Making Fog View enclave request")

        var request = FogView_QueryRequest()
        let invalidSearchKey = Data(repeating: 1, count: 32)
        request.getTxos = [invalidSearchKey]
        fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
            XCTAssertEqual(response.txOutSearchResults.count, 1)
            if let result = response.txOutSearchResults.first {
                // TODO: this can be re-enabled once Fog returns the exact search key used
                // XCTAssertEqual(Array(result.searchKey), Array(invalidSearchKey))
                XCTAssertEqual(result.resultCodeEnum, .badSearchKey)
            }
            XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
            XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

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

        let expect = expectation(description: "Making Fog View enclave request")
        try createFogViewConnectionWithInvalidCredentials(transportProtocol:transportProtocol).query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
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

extension FogViewConnectionIntTests {
    func createFogViewConnection(transportProtocol: TransportProtocol) throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(transportProtocol: transportProtocol)
        return createFogViewConnection(networkConfig: networkConfig)
    }

    func createFogViewConnectionWithInvalidCredentials(transportProtocol: TransportProtocol) throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials(transportProtocol: transportProtocol)
        return createFogViewConnection(networkConfig: networkConfig)
    }

    func createFogViewConnection(networkConfig: NetworkConfig) -> FogViewConnection {
        FogViewConnection(
            config: networkConfig.fogView,
            channelManager: GrpcChannelManager(),
            httpRequester: TestHttpRequester(),
            targetQueue: DispatchQueue.main)
    }
}
