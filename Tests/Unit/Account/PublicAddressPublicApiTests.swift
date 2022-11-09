//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

import MobileCoin
import XCTest

class PublicAddressPublicApiTests: XCTestCase {

    func testInit() throws {
        let fixture = try PublicAddress.Fixtures.Init()
        _ = fixture.accountKey.publicAddress
    }

    func testSerializedDataSerialization() throws {
        let fixture = try PublicAddress.Fixtures.Serialization()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.serializedData, fixture.serializedData)
    }

    func testSerializedDataDeserialization() throws {
        let fixture = try PublicAddress.Fixtures.Serialization()
        let deserialized = try XCTUnwrap(PublicAddress(serializedData: fixture.serializedData))
        XCTAssertEqual(deserialized, fixture.publicAddress)
    }

    func testViewPublicKey() throws {
        let fixture = try PublicAddress.Fixtures.DefaultZero()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.viewPublicKey, fixture.viewPublicKeyData)
    }

    func testSpendPublicKey() throws {
        let fixture = try PublicAddress.Fixtures.DefaultZero()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.spendPublicKey, fixture.spendPublicKeyData)
    }

    func testFogReportUrlString() throws {
        let fixture = try PublicAddress.Fixtures.Default()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.fogReportUrlString, fixture.fogReportUrl)
    }

    func testAddressHashHex() throws {
        let fixture = try PublicAddress.Fixtures.Default()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.addressHash?.hexEncodedString(), fixture.addressHashHex)
    }

    func testAddressHashBase64() throws {
        let fixture = try PublicAddress.Fixtures.Default()
        let publicAddress = fixture.publicAddress
        XCTAssertEqual(publicAddress.addressHash?.base64EncodedString(), fixture.addressHashBase64)
    }

}
