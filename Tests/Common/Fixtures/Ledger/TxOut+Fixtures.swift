//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension TxOut {
    enum Fixtures {}
}

extension TxOut.Fixtures {
    struct Default {
        let txOut: TxOut

        let serializedData = Self.serializedData
        let recipientAccountKey: AccountKey
        let keyImage: KeyImage
        let value = Self.value
        let tokenId = Self.tokenId

        let wrongAccountKey: AccountKey

        init(accountIndex: UInt8 = 255) throws {
            let accountKey = Self.accountKey(accountIndex: accountIndex)
            try self.init(accountKey: accountKey)
        }

        init(accountKey: AccountKey) throws {
            self.recipientAccountKey = accountKey
            self.txOut = try Self.txOut(accountKey: recipientAccountKey)
            self.keyImage = try XCTUnwrap(KeyImage(base64Encoded: Self.keyImageBase64Encoded))
            self.wrongAccountKey = Self.wrongAccountKey()
        }
    }
}

extension TxOut.Fixtures {
    struct TestNet {
        let txOut: TxOut

        let serializedData = Self.serializedData
        let recipientAccountKey: AccountKey
        let keyImage: KeyImage
        let value = Self.value
        let tokenId = Self.tokenId

        let wrongAccountKey: AccountKey

        init(accountIndex: UInt8 = 255) throws {
            let accountKey = try Self.accountKey(accountIndex: accountIndex)
            try self.init(accountKey: accountKey)
        }

        init(accountKey: AccountKey) throws {
            self.recipientAccountKey = accountKey
            self.txOut = try Self.txOut(accountKey: recipientAccountKey)
            self.keyImage = try XCTUnwrap(KeyImage(base64Encoded: Self.keyImageBase64Encoded))
            self.wrongAccountKey = try Self.wrongAccountKey()
        }
    }
}

extension TxOut.Fixtures.Default {
    fileprivate static let defaultBlockVersion = BlockVersion.minRTHEnabled

    fileprivate static func accountKey(accountIndex: UInt8) -> AccountKey {
        AccountKey.Fixtures.DefaultWithoutFog(accountIndex: accountIndex).accountKey
    }

    fileprivate static func wrongAccountKey() -> AccountKey {
        AccountKey.Fixtures.DefaultWithoutFog(accountIndex: 254).accountKey
    }

    fileprivate static func txOut(accountKey: AccountKey) throws -> TxOut {
        try TransactionBuilder.output(
            publicAddress: accountKey.publicAddress,
            amount: Amount(value, in: tokenId),
            fogResolver:
                FogResolver.Fixtures.Default(reportUrl: accountKey.fogReportUrl).fogResolver,
            blockVersion: defaultBlockVersion,
            rng: TestRng()
        ).get()
    }

    fileprivate static let serializedData = Data(base64Encoded: """
        Ci0KIgogBLssqSqN8jQARYHR96C0MgS9vSBxCY1x60FHi4el1GsRs+XfPwGwvG4SIgogmFwyP8+0UqrA\
        oqiAsHY36oCmvj+b2eIbD+CKqydGWXAaIgogBF8KR3dl0gxGFdIa+LvY3ZwOO1zkDQu908KBMwFZfkki\
        VgpUbgYTxUjexTpVTynv91YtSvLT8XyPuxxfV05xwRTjjrGDm1TkuHkCmnzbw3a3ETt6RrNlwLKGfLfg\
        BBkvsI4a8UMl/r21BigZytKZNbZJ52DSsgEAKkQKQt9sSGH/eHqo8hywXe1D2XiXqjRTFQdG4qDRnHw4\
        IcMR9Lv7UcTKZOIpNVa1rEJqI0yIPj9+6uw2yTyBJvuYbmNTaA==
        """)!

    fileprivate static let keyImageBase64Encoded = "6LmUstevIcLo0k6lcyXTBaRjdm9ktKqg/VnX2ivayA4="
    fileprivate static let value: UInt64 = 2_499_990_000_000_000
    fileprivate static let tokenId = TokenId.MOB

}

extension TxOut.Fixtures.TestNet {
    fileprivate static let defaultBlockVersion = BlockVersion.minRTHEnabled

    fileprivate static func accountKey(accountIndex: UInt8) throws -> AccountKey {
        try AccountKey.Fixtures.TestNet().accountKey
    }

    fileprivate static func wrongAccountKey() throws -> AccountKey {
        try AccountKey.Fixtures.TestNet(accountIndex: 254).accountKey
    }

    fileprivate static func txOut(accountKey: AccountKey) throws -> TxOut {
        try TransactionBuilder.output(
            publicAddress: accountKey.publicAddress,
            amount: Amount(value, in: tokenId),
            fogResolver:
                FogResolver.Fixtures.TestNet(reportUrl: accountKey.fogReportUrl).fogResolver,
            blockVersion: defaultBlockVersion,
            rng: TestRng()
        ).get()
    }

    fileprivate static let serializedData = Data(base64Encoded: """
        Ci0KIgogBLssqSqN8jQARYHR96C0MgS9vSBxCY1x60FHi4el1GsRs+XfPwGwvG4SIgogmFwyP8+0UqrA\
        oqiAsHY36oCmvj+b2eIbD+CKqydGWXAaIgogBF8KR3dl0gxGFdIa+LvY3ZwOO1zkDQu908KBMwFZfkki\
        VgpUbgYTxUjexTpVTynv91YtSvLT8XyPuxxfV05xwRTjjrGDm1TkuHkCmnzbw3a3ETt6RrNlwLKGfLfg\
        BBkvsI4a8UMl/r21BigZytKZNbZJ52DSsgEAKkQKQt9sSGH/eHqo8hywXe1D2XiXqjRTFQdG4qDRnHw4\
        IcMR9Lv7UcTKZOIpNVa1rEJqI0yIPj9+6uw2yTyBJvuYbmNTaA==
        """)!

    fileprivate static let keyImageBase64Encoded = "6LmUstevIcLo0k6lcyXTBaRjdm9ktKqg/VnX2ivayA4="
    fileprivate static let value: UInt64 = 2_499_990_000_000_000
    fileprivate static let tokenId = TokenId.MOB

}

extension TxOut.Fixtures {
    struct RandomTxOuts {
        let txOuts: [MockOwnedTxOut]
        let knowableBlockCount = UInt64(100)

        init(number: UInt64) throws {
            self.txOuts = [UInt64](0..<number).map({ _ in
                Self.createRandomTxOut()
            })
        }
    }
}

extension TxOut.Fixtures.RandomTxOuts {
    fileprivate static func createRandomTxOut() -> MockOwnedTxOut {
        let randomValue = UInt64.random(in: 0..<UInt64.max)
        let randomTokenId = UInt64.random(in: 0..<UInt64.max)
        return MockOwnedTxOut(value: randomValue, tokenId: TokenId(randomTokenId))
    }
}

extension TxOut.Fixtures {
    struct RealWorldTxOuts {
        let txOuts: [MockOwnedTxOut]
        let knowableBlockCount = UInt64(100)

        init(number: UInt64, possibleTokens: UInt64) throws {
            self.txOuts = [UInt64](0..<number).map({ _ in
                Self.createEitherOrTxOut(possibleTokens: possibleTokens)
            })
        }
    }
}

extension TxOut.Fixtures.RealWorldTxOuts {
    fileprivate static func createEitherOrTxOut(possibleTokens: UInt64) -> MockOwnedTxOut {
        let randomValue = UInt64.random(in: 0..<10_000_000_000_000)
        let randomTokenId = UInt64.random(in: 0..<possibleTokens)
        return MockOwnedTxOut(value: randomValue, tokenId: TokenId(randomTokenId))
    }
}

struct MockOwnedTxOut {
    let value: UInt64

    let tokenId: TokenId

    init(
        value: UInt64,
        tokenId: TokenId
    ) {
        self.value = value
        self.tokenId = tokenId
    }
}

extension MockOwnedTxOut: Equatable {}
extension MockOwnedTxOut: Hashable {}
