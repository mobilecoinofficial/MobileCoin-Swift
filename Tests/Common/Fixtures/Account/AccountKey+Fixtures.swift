//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension AccountKey {
    enum Fixtures {}
}

extension AccountKey.Fixtures {
    struct Init {
        let mnemonic: Mnemonic
        var mnemonicString: String { mnemonic.phrase }

        let fogReportUrl = Self.fogReportUrl
        let fogReportId = Self.fogReportId
        let fogAuthoritySpki: Data

        let viewPrivateKey = DefaultZero.viewPrivateKey
        let spendPrivateKey = DefaultZero.spendPrivateKey

        init() throws {
            self.mnemonic = Self.mnemonic()
            self.fogAuthoritySpki = try XCTUnwrap(Data(base64Encoded: Self.fogAuthoritySpkiB64))
        }
    }
}

extension AccountKey.Fixtures {
    struct Default {
        let accountKey: AccountKey

        let fogReportUrl: String = Init.fogReportUrl
        let fogReportId: String = Init.fogReportId
        let fogAuthoritySpki: Data

        init(accountIndex: UInt8 = 0) throws {
            let initFixture = try Init()
            let mnemonic = Init.mnemonic(accountIndex: accountIndex)
            self.fogAuthoritySpki = initFixture.fogAuthoritySpki
            self.accountKey = try AccountKey.make(
                mnemonic: mnemonic.phrase,
                fogReportUrl: initFixture.fogReportUrl,
                fogReportId: initFixture.fogReportId,
                fogAuthoritySpki: self.fogAuthoritySpki).get()
        }
    }
}

extension AccountKey.Fixtures {
    struct DefaultZero {
        let accountKey: AccountKey

        let viewPrivateKey = Self.viewPrivateKey
        let spendPrivateKey = Self.spendPrivateKey

        let subaddressViewPrivateKey = Self.subaddressViewPrivateKey
        let subaddressSpendPrivateKey = Self.subaddressSpendPrivateKey

        init() throws {
            let initFixture = try Init()
            self.accountKey = try AccountKey.make(
                mnemonic: initFixture.mnemonicString,
                fogReportUrl: initFixture.fogReportUrl,
                fogReportId: initFixture.fogReportId,
                fogAuthoritySpki: initFixture.fogAuthoritySpki).get()
        }
    }
}

extension AccountKey.Fixtures {
    struct AlphaFog {
        let accountKey: AccountKey
        let manualAccountKey: AccountKey

        let viewPrivateKey = Self.viewPrivateKey
        let spendPrivateKey = Self.spendPrivateKey
        let publicAddress = Self.publicAddress
        let rootEntropy = Data(hexEncoded: "a801af55a4f6b35f0dbb4a9c754ae62b926d25dd6ed954f6e697c562a1641c21")!
        let fogReportUrl = Self.fogReportUrl
        let fogReportId = Self.fogReportId
        let fogAuthoritySpki = Data(hexEncoded: Self.fogAuthoritySpkiHex)!

        init() throws {
            self.accountKey = try AccountKey.make(entropy: rootEntropy, fogReportUrl: fogReportUrl, fogReportId: "", fogAuthoritySpki: fogAuthoritySpki).get()
            self.manualAccountKey = try AccountKey.make(
                viewPrivateKey: viewPrivateKey,
                spendPrivateKey: spendPrivateKey,
                fogReportUrl: fogReportUrl,
                fogReportId: fogReportId,
                fogAuthoritySpki: fogAuthoritySpki).get()
        }
    }
}

extension AccountKey.Fixtures {
    struct AliceAndBob {
        let alice: AccountKey
        let bob: AccountKey

        init() throws {
            self.alice = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.alice_bytes))))
            self.bob = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.bob_bytes))))
        }
    }
}

extension AccountKey.Fixtures {
    struct KnownTxOut {
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            self.senderAccountKey = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(
                            Data(hexEncoded: Self.senderAccountKeyHex))))
            self.receiverAccountKey = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(
                            Data(hexEncoded: Self.receiverAccountKeyHex))))
        }
    }
}

extension AccountKey.Fixtures {
    struct TxOutMemoParser {
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            self.senderAccountKey = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(
                            Data(hexEncoded: Self.senderAccountKeyHex))))
            self.destinationAccountKey = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(
                            Data(hexEncoded: Self.destinationAccountKeyHex))))
        }
    }
}

extension AccountKey.Fixtures {
    struct DefaultWithoutFog {
        let accountKey: AccountKey

        init(accountIndex: UInt8 = 0) {
            let mnemonic = Init.mnemonic(accountIndex: accountIndex)
            self.accountKey = AccountKey(mnemonic: mnemonic)
        }
    }
}

extension AccountKey.Fixtures {
    struct Serialization {
        let accountKey: AccountKey
        let serializedData: Data

        init() throws {
            self.accountKey = try AccountKey.Fixtures.DefaultZero().accountKey
            self.serializedData = try XCTUnwrap(Data(base64Encoded: Self.serializedDataB64Encoded))
        }
    }
}

extension AccountKey.Fixtures.Init {

    fileprivate static func mnemonic(accountIndex: UInt8 = 0) -> Mnemonic {
        Bip39Utils.mnemonic(fromEntropy: Data32(repeating: accountIndex))
    }

    fileprivate static let fogReportUrl = "fog://fog-report.fake.mobilecoin.com"
    fileprivate static let fogReportId = ""
    fileprivate static let fogAuthoritySpkiB64 = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxABZ75QZv9uH9/E823VTTmpWiOiehoqksZMqsDARqYdDexA\
        Qb1Y+qyT6Hlp5QMUHQlkomFKLnhe/0+wxZ1/uTqnhy2FRhrlclpOvczT10Smcx9RkKACpxCW095MWxeFwtMmLpqkXfl\
        4KeMptxdHRASHuLlKL+FXwOqKw3J2nw5q2DpBsg1ONkdW4m55ZFdimX3M7T/Wur5WlB+ntBpKFU/5T+rdD3OUm/tExb\
        Yk7C58XmYW08TnFR9JOMekFZMmTfl5d1ee3koyzz225QfNEupUJDVMXcg4whp826arxQIXrM2DfgwZnxFqS617dNsOP\
        NjIoAYSEFPczYTw9WHR7O3UISnYwYvCsXxGwLZLXFkgUBM5GKItvEHDbUh3C7ZjyM51A04EJg47G3nI1A6q9EVnmwGa\
        ZFxq8bJAzosn5zaSrbUA25hRff25C4BYNjydBI133PjSflLaGjnJYPruLO4XpzB3wszqKm3tiWN39sgC4sMWZfSlxlW\
        ox3SzY2XVl8Q9RqMO8LMUPNhwmTfpEXDW5+NqH+vMiH9UmnsiEwybFche4sE23NJTeO2Xytt55VfoD2Gidte/Sqt5AJ\
        UPu6nfK8QloOCZ1N99MrpWpcZPHittqaYHZ5lWXHKthp/im672hXPl8bNxMUoREqomZdD9mdj/P6w9zFeTkr7P9XQUC\
        AwEAAQ==
        """

}

extension AccountKey.Fixtures.AlphaFog {

    fileprivate static let spendPrivateKey = RistrettoPrivate(hexEncoded: Self.spendPrivateKeyHex)!
    fileprivate static let spendPrivateKeyHex = "3379daf11c7d26bde2be0ab557e79285f868a1e58058ab47063950435fc7670a"
    fileprivate static let viewPrivateKey = RistrettoPrivate(hexEncoded: Self.viewPrivateKeyHex)!
    fileprivate static let viewPrivateKeyHex = "605845eceee09d9bc719c590aac78b5bc2793420e716a41a12b22248be551d07"
    fileprivate static let publicAddressHex = "0a220a2046db671dc90016919bf8a2b0f8b2aefb6220cbff0fa30454f8fc0ffd1948820a12220a20340774b1e70402c197efe792b29b989edaa2c97020df6dc8cf09fd3870d83b251a2a666f673a2f2f666f672e616c7068612e646576656c6f706d656e742e6d6f62696c65636f696e2e636f6d2a40281a4c716a006fb8f813b7d42ce11b8b69c42e8ad709086482403a8142d5bd44d090e9e36565be143bd949ef85b0985c5ee44ad5397cbe2e1599551be181a08b"
    fileprivate static let publicAddress = PublicAddress(serializedData: Data(hexEncoded: Self.publicAddressHex)!)!
    fileprivate static let fogReportUrl = "fog://fog.alpha.development.mobilecoin.com"
    fileprivate static let fogReportId = ""
//    fileprivate static let fogAuthoritySpkiHex = """
//        30820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8\
//        724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf\
//        529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16\
//        586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4\
//        888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e\
//        5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d\
//        75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb\
//        0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b4\
//        54231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538\
//        f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f\
//        95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f\
//        4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182\
//        cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9b\
//        e3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a04\
//        5255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0\
//        b07286f9930203010001
//        """
    fileprivate static let fogAuthoritySpkiHex = "30820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0b07286f9930203010001"

}

extension AccountKey.Fixtures.DefaultZero {

    fileprivate static let viewPrivateKey =
        RistrettoPrivate(base64Encoded: "glKsF3hsRQw/FrPEL6yiGUuTrC3M/e3Y0w0opYvTIQA=")!
    fileprivate static let spendPrivateKey =
        RistrettoPrivate(base64Encoded: "U/o+g92rI0heZ4cyYuW2mD0aJ3HfFIPvWYqhh0SAfQU=")!

    fileprivate static let subaddressViewPrivateKey =
        RistrettoPrivate(base64Encoded: "Axo3oWR5s4wgkYX+cOmpSTaPLizY2WQZxyHODerPvwo=")!
    fileprivate static let subaddressSpendPrivateKey =
        RistrettoPrivate(base64Encoded: "7qHbcA+cQzjwccpYXDwCkLuxtPQFtWfhSDD7nuyH6go=")!

}

extension AccountKey.Fixtures.Serialization {

    fileprivate static let serializedDataB64Encoded = """
        CiIKIIJSrBd4bEUMPxazxC+sohlLk6wtzP3t2NMNKKWL0yEAEiIKIFP6PoPdqyNIXmeHMmLltpg9Gidx3xSD71mKoYd\
        EgH0FGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qpgQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDw\
        AwggIKAoICAQDEAFnvlBm/24f38TzbdVNOalaI6J6GiqSxkyqwMBGph0N7EBBvVj6rJPoeWnlAxQdCWSiYUoueF7/T7\
        DFnX+5OqeHLYVGGuVyWk69zNPXRKZzH1GQoAKnEJbT3kxbF4XC0yYumqRd+Xgp4ym3F0dEBIe4uUov4VfA6orDcnafD\
        mrYOkGyDU42R1bibnlkV2KZfcztP9a6vlaUH6e0GkoVT/lP6t0Pc5Sb+0TFtiTsLnxeZhbTxOcVH0k4x6QVkyZN+Xl3\
        V57eSjLPPbblB80S6lQkNUxdyDjCGnzbpqvFAheszYN+DBmfEWpLrXt02w482MigBhIQU9zNhPD1YdHs7dQhKdjBi8K\
        xfEbAtktcWSBQEzkYoi28QcNtSHcLtmPIznUDTgQmDjsbecjUDqr0RWebAZpkXGrxskDOiyfnNpKttQDbmFF9/bkLgF\
        g2PJ0EjXfc+NJ+UtoaOclg+u4s7henMHfCzOoqbe2JY3f2yALiwxZl9KXGVajHdLNjZdWXxD1Gow7wsxQ82HCZN+kRc\
        Nbn42of68yIf1SaeyITDJsVyF7iwTbc0lN47ZfK23nlV+gPYaJ2179Kq3kAlQ+7qd8rxCWg4JnU330yulalxk8eK22p\
        pgdnmVZccq2Gn+KbrvaFc+Xxs3ExShESqiZl0P2Z2P8/rD3MV5OSvs/1dBQIDAQAB
        """

}

extension AccountKey.Fixtures.AliceAndBob {
    static let alice_bytes =
        """
        0a220a20ec8cb9814ac5c1a4aacbc613e756744679050927cc9e5f8772c6d649d4a5ac0612220a20\
        e7ef0b2772663314ecd7ee92008613764ab5669666d95bd2621d99d60506cb0d1a1e666f673a2f2f\
        666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f7\
        0d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
        ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779\
        840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676\
        ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308e\
        d3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
        fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0f\
        ba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2e\
        d4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac\
        04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
        50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea420\
        89991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de\
        777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a\
        64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
        a9e055395078d0b07286f9930203010001
        """

    static let bob_bytes =
        """
        0a220a20553a1c51c1e91d3105b17c909c163f8bc6faf93718deb06e5b9fdb9a24c2560912220a20\
        db8b25545216d606fc3ff6da43d3281e862ba254193aff8c408f3564aefca5061a1e666f673a2f2f\
        666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f7\
        0d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
        ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779\
        840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676\
        ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308e\
        d3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
        fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0f\
        ba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2e\
        d4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac\
        04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
        50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea420\
        89991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de\
        777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a\
        64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
        a9e055395078d0b07286f9930203010001
        """
}

extension AccountKey.Fixtures.TxOutMemoParser {

    static let senderAccountKeyHex =
        """
        0a220a20553a1c51c1e91d3105b17c909c163f8bc6faf93718deb06e5b9fdb9a24c2560912220a20\
        db8b25545216d606fc3ff6da43d3281e862ba254193aff8c408f3564aefca5061a1e666f673a2f2f\
        666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f7\
        0d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
        ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779\
        840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676\
        ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308e\
        d3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
        fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0f\
        ba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2e\
        d4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac\
        04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
        50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea420\
        89991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de\
        777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a\
        64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
        a9e055395078d0b07286f9930203010001
        """

    static let destinationAccountKeyHex =
        """
        0a220a20ec8cb9814ac5c1a4aacbc613e756744679050927cc9e5f8772c6d649d4a5ac0612220a20\
        e7ef0b2772663314ecd7ee92008613764ab5669666d95bd2621d99d60506cb0d1a1e666f673a2f2f\
        666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f7\
        0d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
        ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779\
        840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676\
        ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308e\
        d3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
        fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0f\
        ba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2e\
        d4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac\
        04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
        50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea420\
        89991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de\
        777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a\
        64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
        a9e055395078d0b07286f9930203010001
        """

}
extension AccountKey.Fixtures.KnownTxOut {
    static let senderAccountKeyHex =
            """
            0a220a20b1f765d30fbb85b605f04edd29bb9cbb83938f68600d4a618863e9664e7b960912220a20\
            dae7da08e27ea4f17a233f15c234b58ce20d0d2727abb98e9bdcf04aeea540081a11666f673a2f2f\
            6578616d706c652e636f6d
            """

    static let receiverAccountKeyHex =
            """
            0a220a20ff6b8ebfe4cda6a2bca7fa6061e73c752ecc3c01876a25b984f0230bcdab8b0712220a20\
            197d2746aac53be4911b6dd01b3e67d5565fcf322c87c75add37959a608e4a021a11666f673a2f2f\
            6578616d706c652e636f6d
            """
}
