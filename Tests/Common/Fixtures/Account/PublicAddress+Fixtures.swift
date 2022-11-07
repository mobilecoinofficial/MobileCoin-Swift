//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

extension PublicAddress {
    enum Fixtures {}
}

extension PublicAddress.Fixtures {
    struct Init {
        let accountKey: AccountKey

        init(accountIndex: UInt8 = 0) throws {
            self.accountKey = try AccountKey.Fixtures.Default(accountIndex: accountIndex).accountKey
        }
    }
}

extension PublicAddress.Fixtures {
    struct Default {
        let publicAddress: PublicAddress

        let accountKey: AccountKey
        let fogReportUrl: String
        let addressHash: Data
        var addressHashHex: String { addressHash.hexEncodedString() }
        var addressHashBase64: String { addressHash.base64EncodedString() }

        init(accountIndex: UInt8 = 0) throws {
            let accountKeyFixture = try AccountKey.Fixtures.Default(accountIndex: accountIndex)
            self.accountKey = accountKeyFixture.accountKey
            self.publicAddress = accountKey.publicAddress
            self.fogReportUrl = accountKeyFixture.fogReportUrl
            self.addressHash = try XCTUnwrap(accountKeyFixture.accountKey.publicAddress.addressHash)
        }
    }
}

extension PublicAddress.Fixtures {
    struct DefaultZero {
        let publicAddress: PublicAddress

        let accountKey: AccountKey
        let viewPublicKey: RistrettoPublic
        var viewPublicKeyData: Data { viewPublicKey.data }
        let spendPublicKey: RistrettoPublic
        var spendPublicKeyData: Data { spendPublicKey.data }

        init() throws {
            self.accountKey = try AccountKey.Fixtures.DefaultZero().accountKey
            self.publicAddress = accountKey.publicAddress
            self.viewPublicKey =
                try XCTUnwrap(RistrettoPublic(base64Encoded: Self.viewPublicKeyB64))
            self.spendPublicKey =
                try XCTUnwrap(RistrettoPublic(base64Encoded: Self.spendPublicKeyB64))
        }
    }
}

extension PublicAddress.Fixtures {
    struct DefaultWithoutFog {
        let publicAddress: PublicAddress

        let accountKey: AccountKey

        init(accountIndex: UInt8 = 0) {
            self.accountKey =
                AccountKey.Fixtures.DefaultWithoutFog(accountIndex: accountIndex).accountKey
            self.publicAddress = accountKey.publicAddress
        }
    }
}

extension PublicAddress.Fixtures {
    struct Serialization {
        let publicAddress: PublicAddress
        let serializedData: Data

        init() throws {
            self.publicAddress = try PublicAddress.Fixtures.DefaultZero().publicAddress
            self.serializedData = try XCTUnwrap(Data(base64Encoded: Self.serializedDataB64Encoded))
        }
    }
}

extension PublicAddress.Fixtures.DefaultZero {

    fileprivate static let viewPublicKeyB64 = "CK1CgouTTmWQeU94jFpVma+hLKgIC5Cvu7+SigowzW8="
    fileprivate static let spendPublicKeyB64 = "SqHrfSO3v+TbOXMnfYWHLrfc/hdck8XIdY7P14CtahA="

}

extension PublicAddress.Fixtures.Serialization {

    fileprivate static let serializedDataB64Encoded = """
        CiIKIAitQoKLk05lkHlPeIxaVZmvoSyoCAuQr7u/kooKMM1vEiIKIEqh630jt7/k2zlzJ32Fhy633P4XXJPFyHWOz9e\
        ArWoQGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qQEIjVGb+GOA3SXR9U2uPAY9AX02bJQsh28\
        MHNhMoep49uuWGzbq7a0Ya2YJyNb7xUqpSBnmjAKfpUQLqQkMMzYE=
        """

}
