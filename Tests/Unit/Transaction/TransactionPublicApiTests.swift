//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class TransactionPublicApiTests: XCTestCase {

    func testSerializedDataSerialization() throws {
        let fixture = try Transaction.Fixtures.Serialization()
        let transaction = fixture.transaction
        XCTAssertEqual(transaction.serializedData, fixture.serializedData)
    }

    func testSerializedDataDeserialization() throws {
        let fixture = try Transaction.Fixtures.Serialization()
        let deserialized = try XCTUnwrap(Transaction(serializedData: fixture.serializedData))
        XCTAssertEqual(deserialized, fixture.transaction)
    }

    func testInputKeyImages() throws {
        let fixture = try Transaction.Fixtures.Default()
        let transaction = fixture.transaction
        XCTAssertEqual(transaction.inputKeyImages, fixture.inputKeyImages)
    }

    func testOutputPublicKeys() throws {
        let fixture = try Transaction.Fixtures.Default()
        let transaction = fixture.transaction
        XCTAssertEqual(transaction.outputPublicKeys, fixture.outputPublicKeys)
    }

    func testFee() throws {
        let fixture = try Transaction.Fixtures.Default()
        let transaction = fixture.transaction
        XCTAssertEqual(transaction.fee, fixture.fee.value)
    }

    func testTombstoneBlockIndex() throws {
        let fixture = try Transaction.Fixtures.Default()
        let transaction = fixture.transaction
        XCTAssertEqual(transaction.tombstoneBlockIndex, fixture.tombstoneBlockIndex)
    }

}
