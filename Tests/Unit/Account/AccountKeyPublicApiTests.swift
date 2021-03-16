//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import MobileCoin
import XCTest

class AccountKeyPublicApiTests: XCTestCase {

    func testMake() throws {
        let fixture = try AccountKey.Fixtures.Init()
        _ = try AccountKey.make(
            rootEntropy: fixture.rootEntropyData,
            fogReportUrl: fixture.fogReportUrl,
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki).get()
    }

    func testWrongSchemeFails() throws {
        let fixture = try AccountKey.Fixtures.Init()
        XCTAssertThrowsError(try AccountKey.make(
            rootEntropy: fixture.rootEntropyData,
            fogReportUrl: "mc://fog-report.fake.mobilecoin.com",
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki).get())
    }

    func testSerializedDataSerialization() throws {
        let fixture = try AccountKey.Fixtures.Serialization()
        let accountKey = fixture.accountKey
        XCTAssertEqual(accountKey.serializedData, fixture.serializedData)
    }

    func testSerializedDataDeserialization() throws {
        let fixture = try AccountKey.Fixtures.Serialization()
        let deserialized = try XCTUnwrap(AccountKey(serializedData: fixture.serializedData))
        XCTAssertEqual(deserialized, fixture.accountKey)
    }

}
