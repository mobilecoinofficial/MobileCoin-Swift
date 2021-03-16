//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import MobileCoin
import XCTest

class MobileCoinClientPublicApiTests: XCTestCase {

    func testMake() throws {
        let fixture = try MobileCoinClient.Fixtures.Init()
        let config = try MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            fogUrl: fixture.fogUrl).get()
        _ = MobileCoinClient.make(accountKey: fixture.accountKey, config: config)
    }

    func testWrongConsensusUrlSchemeFails() throws {
        let fixture = try MobileCoinClient.Fixtures.Init()
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: "https://node1.fake.mobilecoin.com",
            fogUrl: fixture.fogUrl).get())
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: "mob://node1.fake.mobilecoin.com",
            fogUrl: fixture.fogUrl).get())
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: "fog://node1.fake.mobilecoin.com",
            fogUrl: fixture.fogUrl).get())
    }

    func testWrongFogUrlSchemeFails() throws {
        let fixture = try MobileCoinClient.Fixtures.Init()
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            fogUrl: "https://fog.fake.mobilecoin.com").get())
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            fogUrl: "mc://fog.fake.mobilecoin.com").get())
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            fogUrl: "mob://fog.fake.mobilecoin.com").get())
        XCTAssertThrowsError(try MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            fogUrl: "fog-view://fog.fake.mobilecoin.com").get())
    }

    func testInvalidConsensusTrustRootFails() throws {
        let fixture = try MobileCoinClient.Config.Fixtures.Default()
        var config = fixture.config
        XCTAssertFailure(config.setConsensusTrustRoots([fixture.invalidTrustRootBytes]))
    }

    func testInvalidFogTrustRootFails() throws {
        let fixture = try MobileCoinClient.Config.Fixtures.Default()
        var config = fixture.config
        XCTAssertFailure(config.setFogTrustRoots([fixture.invalidTrustRootBytes]))
    }

}
