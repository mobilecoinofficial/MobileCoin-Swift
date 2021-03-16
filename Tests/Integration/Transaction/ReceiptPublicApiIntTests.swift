//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class ReceiptPublicApiIntTests: XCTestCase {

    func testSerializedData() throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient()
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

    func testValidateAndUnmaskValueAccepts() throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey)

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

    func testValidateAndUnmaskValueRejects() throws {
        let accountKey = try IntegrationTestFixtures.createAccountKey()
        let accountKey2 = try IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let accountKey3 = try IntegrationTestFixtures.createAccountKey(accountIndex: 3)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey)

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
