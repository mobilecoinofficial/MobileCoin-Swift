//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TxOutTests: XCTestCase {

    func testSerializedDataSerialization() throws {
        let fixture = try TxOut.Fixtures.Default()
        let txOut = fixture.txOut
        XCTAssertEqual(txOut.serializedData, fixture.serializedData)
    }

    func testSerializedDataDeserialization() throws {
        let fixture = try TxOut.Fixtures.Default()
        let deserialized = try XCTUnwrap(TxOut(serializedData: fixture.serializedData))
        XCTAssertEqual(deserialized, fixture.txOut)
    }

    func testKeyImage() throws {
        let fixture = try TxOut.Fixtures.Default()
        let txOut = fixture.txOut
        let recipientAccountKey = fixture.recipientAccountKey
        XCTAssertEqual(txOut.keyImage(accountKey: recipientAccountKey), fixture.keyImage)
    }

    func testValue() throws {
        let fixture = try TxOut.Fixtures.Default()
        let txOut = fixture.txOut
        let recipientAccountKey = fixture.recipientAccountKey
        XCTAssertEqual(txOut.value(accountKey: recipientAccountKey), fixture.value)
    }

}
