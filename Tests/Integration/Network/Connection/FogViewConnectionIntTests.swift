//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogViewConnectionIntTests: XCTestCase {
    func testEnclaveRequest() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testEnclaveRequestReturnsTxOuts() throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let fogViewConnection = try createFogViewConnection()

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
                let rng = try FogRng.make(accountKey: accountKey, fogRngKey: fogRngKey).get()

                var request = FogView_QueryRequest()
                request.getTxos = rng.outputs(count: 5)
                fogViewConnection.query(requestAad: FogView_QueryRequestAAD(), request: request) {
                    guard let response = $0.successOrFulfill(expectation: expect) else { return }

                    XCTAssertGreaterThan(response.highestProcessedBlockCount, 0)
                    XCTAssertEqual(response.txOutSearchResults.count, 5)
                    for txOutResult in response.txOutSearchResults {
                        XCTAssert(request.getTxos.contains(txOutResult.searchKey))
                        XCTAssertEqual(txOutResult.resultCodeEnum, .found)
                    }
                    XCTAssertGreaterThan(response.lastKnownBlockCount, 0)
                    XCTAssertGreaterThan(response.lastKnownBlockCumulativeTxoCount, 0)

                    expect.fulfill()
                }
            })
        }

        waitForExpectations(timeout: 20)
    }

    func testEnclaveRequestReturnsNotFoundForFakeData() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testEnclaveRequestReturnsBadSearchKeyForEmptySearchKey() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testEnclaveRequestReturnsBadSearchKeyForInvalidSearchKey() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testEnclaveRequestReturnsBadSearchKeyForTooShortSearchKey() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testEnclaveRequestReturnsBadSearchKeyForTooLongSearchKey() throws {
        let fogViewConnection = try createFogViewConnection()

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

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try XCTSkipUnless(IntegrationTestFixtures.fogRequiresCredentials)

        let expect = expectation(description: "Making Fog View enclave request")
        try createFogViewConnectionWithInvalidCredentials().query(
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
    func createFogViewConnection() throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig()
        return createFogViewConnection(networkConfig: networkConfig)
    }

    func createFogViewConnectionWithInvalidCredentials() throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidCredentials()
        return createFogViewConnection(networkConfig: networkConfig)
    }

    func createFogViewConnection(networkConfig: NetworkConfig) -> FogViewConnection {
        FogViewConnection(
            config: networkConfig.fogView,
            channelManager: GrpcChannelManager(),
            targetQueue: DispatchQueue.main)
    }
}
