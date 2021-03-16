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

        init(accountIndex: UInt8 = 0) throws {
            let accountKeyFixture = try AccountKey.Fixtures.Default(accountIndex: accountIndex)
            self.accountKey = accountKeyFixture.accountKey
            self.publicAddress = accountKey.publicAddress
            self.fogReportUrl = accountKeyFixture.fogReportUrl
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

    fileprivate static let viewPublicKeyB64 = "eJAcEYNOhC32vpjBJ5U1E+EWCV1BIswn2Ae0URy4HhE="
    fileprivate static let spendPublicKeyB64 = "9i/xwzoihbGu5hLthygfLGi7K1sPFDmhPkq3KPmO+2o="

}

extension PublicAddress.Fixtures.Serialization {

    fileprivate static let serializedDataB64Encoded = """
        CiIKIHiQHBGDToQt9r6YwSeVNRPhFgldQSLMJ9gHtFEcuB4REiIKIPYv8cM6IoWxruYS7YcoHyxouytbDxQ5oT5Ktyj\
        5jvtqGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qQGKcpgeIvBZMKl0DHQXmuvQjfRYAXtU1FV\
        zg3GIq3qNJQV6WsZTytMxiQ8Jp/ji2+n1O63EU6P7Oes+yyI1T1Iw=
        """

}
