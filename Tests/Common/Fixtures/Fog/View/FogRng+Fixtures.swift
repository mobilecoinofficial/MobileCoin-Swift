//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension FogRng {
    enum Fixtures {}
}

extension FogRng.Fixtures {
    struct Init {
        let subaddressViewPrivateKey: RistrettoPrivate
        let fogRngKey = FogRngKey(pubkey: Self.pubkey, version: Self.rngVersion)

        init() throws {
            self.subaddressViewPrivateKey = try XCTUnwrap(RistrettoPrivate(Data32(repeating: 1)))
        }
    }
}

extension FogRng.Fixtures {
    struct Default {
        let fogRng: FogRng

        var firstOutput: Data { outputs[0] }
        let outputs = [
            Data(base64Encoded: "hPL14yTJAx4fuS5gOOeiJA==")!,
            Data(base64Encoded: "cjYScHT+L4myQT3JHrS7Jg==")!,
            Data(base64Encoded: "QVkmM60zK+epF7SmEsnusg==")!,
            Data(base64Encoded: "SD7xWk62c5lnBg1pDz9qzg==")!,
        ]

        init() throws {
            let initFixture = try Init()
            self.fogRng = try FogRng.make(
                subaddressViewPrivateKey: initFixture.subaddressViewPrivateKey,
                fogRngKey: initFixture.fogRngKey).get()
        }
    }
}

extension FogRng.Fixtures.Init {

    fileprivate static let pubkey = Data(repeating: 2, count: 32)
    fileprivate static let rngVersion: UInt32 = 0

}
