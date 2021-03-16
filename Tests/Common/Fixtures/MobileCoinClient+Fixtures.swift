//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import Foundation
@testable import MobileCoin
import NIOSSL

extension MobileCoinClient {
    enum Fixtures {}
}

extension MobileCoinClient.Fixtures {
    struct Init {
        let accountKey: AccountKey

        let consensusUrl = "mc://node1.fake.mobilecoin.com"
        let fogUrl = "fog://fog.fake.mobilecoin.com"

        init(accountIndex: UInt8 = 0) throws {
            self.accountKey = try AccountKey.Fixtures.Default(accountIndex: accountIndex).accountKey
        }
    }
}

extension MobileCoinClient.Config {
    enum Fixtures {}
}

extension MobileCoinClient.Config.Fixtures {
    struct Default {
        let config: MobileCoinClient.Config

        let consensusUrl = "mc://node1.fake.mobilecoin.com"
        let fogUrl = "fog://fog.fake.mobilecoin.com"

        let trustRootBytes: Data

        let wrongTrustRootBytes: Data
        let invalidTrustRootBytes: Data

        init() throws {
            self.config = try MobileCoinClient.Config.make(
                consensusUrl: self.consensusUrl,
                fogUrl: self.fogUrl).get()

            let trustRootsFixture = try NetworkConfig.Fixtures.TrustRoots()
            self.trustRootBytes = trustRootsFixture.trustRootBytes
            self.wrongTrustRootBytes = trustRootsFixture.wrongTrustRootBytes
            self.invalidTrustRootBytes = trustRootsFixture.invalidTrustRootBytes
        }
    }
}
