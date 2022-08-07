//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension Receipt {
    enum Fixtures {}
}

extension Receipt.Fixtures {
    struct Default {
        let receipt: Receipt

        let serializedData = Self.serializedData
        let accountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        var txOutPublicKeyData: Data { txOutPublicKey.data }
        let value = Self.value
        var txTombstoneBlockIndex = Self.txTombstoneBlockIndex

        let wrongAccountKey: AccountKey

        init() throws {
            self.receipt = try Self.receipt()
            self.accountKey = Self.accountKey()
            self.txOutPublicKey =
                try XCTUnwrap(RistrettoPublic(base64Encoded: Self.txOutPublicKeyBase64Encoded))
            self.wrongAccountKey = Self.wrongAccountKey()
        }
    }
}

extension Receipt.Fixtures.Default {

    fileprivate static let defaultBlockVersion = BlockVersion.minRTHEnabled

    fileprivate static func accountKey() -> AccountKey {
        AccountKey.Fixtures.DefaultWithoutFog(accountIndex: 255).accountKey
    }

    fileprivate static func wrongAccountKey() -> AccountKey {
        AccountKey.Fixtures.DefaultWithoutFog(accountIndex: 254).accountKey
    }

    fileprivate static func receipt() throws -> Receipt {
        let accountKey = self.accountKey()
        return try TransactionBuilder.outputWithReceipt(
            publicAddress: accountKey.publicAddress,
            amount: value,
            tombstoneBlockIndex: 100,
            blockVersion: defaultBlockVersion,
            rng: MobileCoinDefaultRng()
        ).get().receipt
    }

    fileprivate static let serializedData = Data(base64Encoded: """
        CiIKIARfCkd3ZdIMRhXSGvi72N2cDjtc5A0LvdPCgTMBWX5JEiIKIFf4+WnFJ5XvgQ3Si6ewxByjiZKIhwJO4AfN1cP\
        9PDr+GGQiLQoiCiDIZT/y7TcjyGcnounBT/vfd3aEthkR9NSPRDC3iwGQFxG5uTt4u1G0bg==
        """)!

    fileprivate static let txOutPublicKeyBase64Encoded =
        "BF8KR3dl0gxGFdIa+LvY3ZwOO1zkDQu908KBMwFZfkk="
    fileprivate static let value: UInt64 = 10
    fileprivate static let txTombstoneBlockIndex: UInt64 = 100

}
