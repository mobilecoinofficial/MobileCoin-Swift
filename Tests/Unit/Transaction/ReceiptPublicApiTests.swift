//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class ReceiptPublicApiTests: XCTestCase {

    func testSerializedDataSerialization() throws {
        let fixture = try Receipt.Fixtures.Default()
        let receipt = fixture.receipt
        XCTAssertEqual(receipt.serializedData, fixture.serializedData)
    }

    func testSerializedDataDeserialization() throws {
        let fixture = try Receipt.Fixtures.Default()
        let deserialized = try XCTUnwrap(Receipt(serializedData: fixture.serializedData))
        XCTAssertEqual(deserialized, fixture.receipt)
    }

    func testTxOutPublicKey() throws {
        let fixture = try Receipt.Fixtures.Default()
        XCTAssertEqual(fixture.receipt.txOutPublicKey, fixture.txOutPublicKeyData)
    }

    func testTombstoneBlockIndex() throws {
        let fixture = try Receipt.Fixtures.Default()
        let receipt = fixture.receipt
        XCTAssertEqual(receipt.txTombstoneBlockIndex, fixture.txTombstoneBlockIndex)
    }

    func testValidateAndUnmaskValue() throws {
        let fixture = try Receipt.Fixtures.Default()
        XCTAssertEqual(
            fixture.receipt.validateAndUnmaskValue(accountKey: fixture.accountKey),
            fixture.value)
    }

    func testValidateAndUnmaskValueReturnsNilWithWrongAccountKey() throws {
        let fixture = try Receipt.Fixtures.Default()
        XCTAssertNil(fixture.receipt.validateAndUnmaskValue(accountKey: fixture.wrongAccountKey))
    }

}
