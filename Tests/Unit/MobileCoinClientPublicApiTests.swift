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
            mistyswapUrl: fixture.mistyswapUrl,
            mistyswapAttestation: fixture.mistyswapAttestation,
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
                mistyswapUrl: fixture.mistyswapUrl,
                mistyswapAttestation: fixture.mistyswapAttestation,
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
                mistyswapUrl: fixture.mistyswapUrl,
                mistyswapAttestation: fixture.mistyswapAttestation,
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

    func testWrappedRistrettoPrivate() throws {
        let validRistretto = "3379daf11c7d26bde2be0ab557e79285f868a1e58058ab47063950435fc7670a"
        let validRistrettoData = try XCTUnwrap(Data(hexEncoded: validRistretto))
        let validKey = WrappedRistrettoPrivate(validRistrettoData)
        XCTAssertNotNil(validKey?.data, "Init should succeed")
    }

    func testWrappedRistrettoPrivateFailure() throws {
        let invalidRistretto = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        let invalidRistrettoData = try XCTUnwrap(Data(hexEncoded: invalidRistretto))
        let invalidKey = WrappedRistrettoPrivate(invalidRistrettoData)
        XCTAssertNil(invalidKey, "Init should fail")
    }

    func testWrappedRistrettoPublic() throws {
        let validRistretto = "c235c13c4dedd808e95f428036716d52561fad7f51ce675f4d4c9c1fa1ea2165"
        let validRistrettoData = try XCTUnwrap(Data(hexEncoded: validRistretto))
        let validKey = WrappedRistrettoPublic(validRistrettoData)
        XCTAssertNotNil(validKey?.data, "Init should succeed")
    }

    func testWrappedRistrettoPublicFailure() throws {
        let invalidRistretto = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        let invalidRistrettoData = try XCTUnwrap(Data(hexEncoded: invalidRistretto))
        let invalidKey = WrappedRistrettoPublic(invalidRistrettoData)
        XCTAssertNil(invalidKey, "Init should fail")
    }
}
