//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import Foundation
@testable import MobileCoin

extension MobileCoinClient.Config {
    enum Fixtures {}
}

extension MobileCoinClient.Config.Fixtures {
    struct Init {
        let consensusUrl = "mc://node1.fake.mobilecoin.com"
        let fogUrl = "fog://fog.fake.mobilecoin.com"
        let mistyswapUrl = "insecure-mistyswap//34.133.197.146:4040/"

        let trustRootsBytes: [Data]

        let wrongTrustRootBytes: Data
        let invalidTrustRootBytes: Data

        let consensusAttestation = Attestation()
        let fogViewAttestation = Attestation()
        let fogMerkleProofAttestation = Attestation()
        let fogKeyImageAttestation = Attestation()
        let fogReportAttestation = Attestation()
        let mistyswapAttestation = Attestation()

        init() throws {
            let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
            self.trustRootsBytes = trustRootsFixture.trustRootsBytes
            self.wrongTrustRootBytes = trustRootsFixture.wrongTrustRootBytes
            self.invalidTrustRootBytes = trustRootsFixture.invalidTrustRootBytes
        }
    }
}

extension MobileCoinClient.Config.Fixtures {
    struct Default {
        let config: MobileCoinClient.Config

        init() throws {
            let initFixture = try Init()
            self.config = try MobileCoinClient.Config.make(
                consensusUrl: initFixture.consensusUrl,
                consensusAttestation: initFixture.consensusAttestation,
                fogUrl: initFixture.fogUrl,
                fogViewAttestation: initFixture.fogViewAttestation,
                fogKeyImageAttestation: initFixture.fogKeyImageAttestation,
                fogMerkleProofAttestation: initFixture.fogMerkleProofAttestation,
                fogReportAttestation: initFixture.fogReportAttestation,
                mistyswapUrl: initFixture.mistyswapUrl,
                mistyswapAttestation: initFixture.mistyswapAttestation,
                transportProtocol: TransportProtocol.http).get()
        }
    }
}

extension MobileCoinClient {
    enum Fixtures {}
}

extension MobileCoinClient.Fixtures {
    struct Init {
        let accountKey: AccountKey
        let config: MobileCoinClient.Config

        init(accountIndex: UInt8 = 0) throws {
            self.accountKey = try AccountKey.Fixtures.Default(accountIndex: accountIndex).accountKey
            self.config = try MobileCoinClient.Config.Fixtures.Default().config
        }
    }
}
