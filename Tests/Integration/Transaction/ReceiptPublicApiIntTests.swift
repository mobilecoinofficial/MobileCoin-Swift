//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class ReceiptPublicApiIntTests: XCTestCase {

    func testSerializedDataGRPC() throws {
        try serializedData(transportProtocol: TransportProtocol.grpc)
    }
    
    func testSerializedDataHTTP() throws {
        try serializedData(transportProtocol: TransportProtocol.http)
    }
    
    func serializedData(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Testing Receipt serialization")
        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("got balance: \(amountPicoMob)")
            }

            client.prepareTransaction(to: recipient, amount: 10, fee: IntegrationTestFixtures.fee) {
                guard let (_, receipt) = $0.successOrFulfill(expectation: expect) else { return }
                if let deserialized =
                    try? XCTUnwrap(Receipt(serializedData: receipt.serializedData))
                {
                    XCTAssertEqual(deserialized, receipt)
                }
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
    }

    func testValidateAndUnmaskValueAcceptsGRPC() throws {
        try validateAndUnmaskValueAccepts(transportProtocol: TransportProtocol.grpc)
    }
    
    func testValidateAndUnmaskValueAcceptsHTTP() throws {
        try validateAndUnmaskValueAccepts(transportProtocol: TransportProtocol.http)
    }
    
    func validateAndUnmaskValueAccepts(transportProtocol: TransportProtocol) throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        let expect = expectation(description: "testing confirmation number")
        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("got balance: \(amountPicoMob)")
            }

            client.prepareTransaction(
                to: accountKey.publicAddress,
                amount: 10,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (_, receipt) = $0.successOrFulfill(expectation: expect) else { return }

                XCTAssertNotNil(receipt.validateAndUnmaskValue(accountKey: accountKey))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
    }

    func testValidateAndUnmaskValueRejectsGRPC() throws {
        try validateAndUnmaskValueRejects(transportProtocol: TransportProtocol.grpc)
    }
    
    func testValidateAndUnmaskValueRejectsHTTP() throws {
        try validateAndUnmaskValueRejects(transportProtocol: TransportProtocol.http)
    }
    
    func validateAndUnmaskValueRejects(transportProtocol: TransportProtocol) throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let accountKey2 = try IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let accountKey3 = try IntegrationTestFixtures.createAccountKey(accountIndex: 3)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        let expect = expectation(description: "testing confirmation number")
        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("got balance: \(amountPicoMob)")
            }

            client.prepareTransaction(
                to: accountKey.publicAddress,
                amount: 10,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (_, receipt) = $0.successOrFulfill(expectation: expect) else { return }

                XCTAssertNotNil(receipt.validateAndUnmaskValue(accountKey: accountKey))
                XCTAssertNil(receipt.validateAndUnmaskValue(accountKey: accountKey2))
                XCTAssertNil(receipt.validateAndUnmaskValue(accountKey: accountKey3))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
    }

}
