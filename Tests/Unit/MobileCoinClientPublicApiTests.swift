//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class MobileCoinClientPublicApiTests: XCTestCase {

    func testMakeConfig() throws {
        let fixture = try MobileCoinClient.Config.Fixtures.Init()
        XCTAssertSuccess(MobileCoinClient.Config.make(
            consensusUrl: fixture.consensusUrl,
            consensusAttestation: fixture.consensusAttestation,
            fogUrl: fixture.fogUrl,
            fogViewAttestation: fixture.fogViewAttestation,
            fogKeyImageAttestation: fixture.fogKeyImageAttestation,
            fogMerkleProofAttestation: fixture.fogMerkleProofAttestation,
            fogReportAttestation: fixture.fogReportAttestation,
            transportProtocol: TransportProtocol.http))
    }

    func testWrongConsensusUrlSchemeFails() throws {
        let fixture = try MobileCoinClient.Config.Fixtures.Init()
        let wrongConsensusSchemeUrls = [
            "https://node1.fake.mobilecoin.com",
            "mob://node1.fake.mobilecoin.com",
            "fog://node1.fake.mobilecoin.com",
        ]
        for wrongConsensusSchemeUrl in wrongConsensusSchemeUrls {
            XCTAssertFailure(MobileCoinClient.Config.make(
                consensusUrl: wrongConsensusSchemeUrl,
                consensusAttestation: fixture.consensusAttestation,
                fogUrl: fixture.fogUrl,
                fogViewAttestation: fixture.fogViewAttestation,
                fogKeyImageAttestation: fixture.fogKeyImageAttestation,
                fogMerkleProofAttestation: fixture.fogMerkleProofAttestation,
                fogReportAttestation: fixture.fogReportAttestation,
                transportProtocol: TransportProtocol.http))
        }
    }

    func testWrongFogUrlSchemeFails() throws {
        let fixture = try MobileCoinClient.Config.Fixtures.Init()
        let wrongFogSchemeUrls = [
            "https://fog.fake.mobilecoin.com",
            "mc://fog.fake.mobilecoin.com",
            "mob://fog.fake.mobilecoin.com",
            "fog-view://fog.fake.mobilecoin.com",
        ]
        for wrongFogSchemeUrl in wrongFogSchemeUrls {
            XCTAssertFailure(MobileCoinClient.Config.make(
                consensusUrl: fixture.consensusUrl,
                consensusAttestation: fixture.consensusAttestation,
                fogUrl: wrongFogSchemeUrl,
                fogViewAttestation: fixture.fogViewAttestation,
                fogKeyImageAttestation: fixture.fogKeyImageAttestation,
                fogMerkleProofAttestation: fixture.fogMerkleProofAttestation,
                fogReportAttestation: fixture.fogReportAttestation,
                transportProtocol: TransportProtocol.http))
        }
    }

    func testInvalidConsensusTrustRootFails() throws {
        let initFixture = try MobileCoinClient.Config.Fixtures.Init()
        let fixture = try MobileCoinClient.Config.Fixtures.Default()
        var config = fixture.config
        XCTAssertFailure(config.setConsensusTrustRoots([initFixture.invalidTrustRootBytes]))
    }

    func testInvalidFogTrustRootFails() throws {
        let initFixture = try MobileCoinClient.Config.Fixtures.Init()
        let fixture = try MobileCoinClient.Config.Fixtures.Default()
        var config = fixture.config
        XCTAssertFailure(config.setFogTrustRoots([initFixture.invalidTrustRootBytes]))
    }

    func testMake() throws {
        let fixture = try MobileCoinClient.Fixtures.Init()
        _ = MobileCoinClient.make(accountKey: fixture.accountKey, config: fixture.config)
    }

}
