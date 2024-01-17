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

/**
 AccountKey:

 privateSpendKey base64: RT7xHrq4LJvvGxVtf2oA9RrpxPEil5A0gRAWg9tYVQo=
 privateViewdKey base64: wzR4WMB6cqlv+pYKkyksGhsRNp0a5okI3Ljk3QSPuw8=

 FogInfo:

 reportUrlString fog://fog.test.mobilecoin.com
 reportUrl fog://fog.test.mobilecoin.com
 reportId
 authoritySpki base54 MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvnB9wTbTOT5uoizRYaYbw7XIEkInl8E7MGOAQj+xnC+F1rIXiCnc/t1+5IIWjbRGhWzo7RAwI5sRajn2sT4rRn9NXbOzZMvIqE4hmhmEzy1YQNDnfALAWNQ+WBbYGW+Vqm3IlQvAFFjVN1YYIdYhbLjAPdkgeVsWfcLDforHn6rR3QBZYZIlSBQSKRMY/tywTxeTCvK2zWcS0kbbFPtBcVth7VFFVPAZXhPi9yy1AvnldO6n7KLiupVmojlEMtv4FQkk604nal+j/dOplTATV8a9AJBbPRBZ/yQg57EG2Y2MRiHOQifJx0S5VbNyMm9bkS8TD7Goi59aCW6OT1gyeotWwLg60JRZTfyJ7lYWBSOzh0OnaCytRpSWtNZ6barPUeOnftbnJtE8rFhF7M4F66et0LI/cuvXYecwVwykovEVBKRF4HOK9GgSm17mQMtzrD7c558TbaucOWabYR04uhdAc3s10MkuONWG0wIQhgIChYVAGnFLvSpp2/aQEq3xrRSETxsixUIjsZyWWROkuA0IFnc8d7AmcnUBvRW7FT/5thWyk5agdYUGZ+7C1o69ihR1YxmoGh69fLMPIEOhYh572+3ckgl2SaV4uo9Gvkz8MMGRBcMIMlRirSwhCfozV2RyT5Wn1NgPpyc8zJL7QdOhL7Qxb+5WjnCVrQYHI2cCAwEAAQ==

 
 
 
 FogResolver:
 
 2024-01-11T15:48:12-0800 info com.mobilecoin : FogResolver.swift:50:addReportResponse(reportUrl:reportResponse:) - reportUrl: fog://fog.test.mobilecoin.com
 2024-01-11T15:48:12-0800 info com.mobilecoin : FogResolver.swift:51:addReportResponse(reportUrl:reportResponse:) - reportResponse base64: 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S/yIaeAUE+oJNUHeinkoEbdGNsXpFFLPDO5Z8vtASs0LxYTLnINUBHNMDn7GYFzfzy/0ObbUcZ9wLw4MP6BP2xKmyyrRqxya8fj0w6CO3XKjKwu10K0lb/0Vmmg7KlofHRH6YlMvA9dUyu8NpXNaHlqITH6J2RIYydcaugh7Im5vbmNlIjoiMTQxMzlmMTY2OTk3MjIyYzYzOWM1OWQzMmMwNTkyNGEiLCJpZCI6IjE3NjgwMjQ5MjU4Njg5NjE5NjM4MDIwMTUwNTg3MTQ0MDM2Mjk5MiIsInRpbWVzdGFtcCI6IjIwMjQtMDEtMTFUMjI6MDk6NDkuNTk4NDI2IiwidmVyc2lvbiI6NCwiZXBpZFBzZXVkb255bSI6ImdLSDBkZXhFcFlmdXlhR2dhS0tXbUg0Vko4cjBMM2FmMVcvL3A2eWErV2FOOUJBbFNXMUdqM05PV3ZyUUlFQXlMQ29mM2Z3Uzlwa0xuWnJZazNDWFFGT0hPdmNzeWRWZGxmQUVmL0RjUTZFZVNqck91OVhjRmlmVm1LSVpVR3RPQmxOczVNTkVXcXdFa3NqS2tGN054ck1Bc3VtOGRLS24zV1kzanRHRTJxOD0iLCJhZHZpc29yeVVSTCI6Imh0dHBzOi8vc2VjdXJpdHktY2VudGVyLmludGVsLmNvbSIsImFkdmlzb3J5SURzIjpbIklOVEVMLVNBLTAwMzM0IiwiSU5URUwtU0EtMDA2MTUiXSwiaXN2RW5jbGF2ZVF1b3RlU3RhdHVzIjoiU1dfSEFSREVOSU5HX05FRURFRCIsImlzdkVuY2xhdmVRdW90ZUJvZHkiOiJBZ0FCQUt3TUFBQU5BQTBBQUFBQUFMM2xnMzRIUE9rcTV1L3kwbDk0eHVNQUFBQUFBQUFBQUFBQUFBQUFBQUFBRlJVTEIvK0FEZ0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUJRQUFBQUFBQUFBSEFBQUFBQUFBQUNTRFZxb05OREdyeEYyaGR6ejlZWkdrOHBpYVNwbmFNZlJRdlh4R0hqRXJBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDL2Y2bFhwcWxLeTFpSVVieUhaK0RLVjNCc2VmVDhLcWE4dVpNQkxEdzRiQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBUUFCd0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQXl0a2dSKzdOMWFYQllwMmJCMkdOcFFQTVRidFFteHY4UlRXVDJJNmllTnNBbGl1dFh0Vk5MUUhZejJ0REhUZHMxR1VFbXcwN2VhcU9EbWJrRGRUUUcifRk6yiQAAAAAABLZBjCCA1UwggI9oAMCAQICAhAAMA0GCSqGSIb3DQEBCwUAMIGNMQswCQYDVQQGEwJVUzEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzETMBEGA1UECAwKQ2FsaWZvcm5pYTEVMBMGA1UECgwMVGVzdE5ldCBPTkxZMRAwDgYDVQQLDAdUZXN0TmV0MSgwJgYDVQQDDB9UZXN0TmV0IFBlbnVsdGltYXRlIEF1dGhvcml0eSAxMCAXDTIxMDMxMTAwNTQ1NFoYDzIwNzEwMzExMDA1NDU0WjCBiDELMAkGA1UEBhMCVVMxFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xEzARBgNVBAgMCkNhbGlmb3JuaWExFTATBgNVBAoMDFRlc3ROZXQgT05MWTEQMA4GA1UECwwHVGVzdE5ldDEjMCEGA1UEAwwaVGVzdE5ldCBMZWFmIENlcnRpZmljYXRlIDEwKjAFBgMrZXADIQCrfN6i/ZaV4h9ivoEsWwtKp9Thzd0BTqEUT8Phrq8D16OBuTCBtjAJBgNVHRMEAjAAMBEGCWCGSAGG+EIBAQQEAwIEMDAxBglghkgBhvhCAQ0EJBYiT3BlblNTTCBHZW5lcmF0ZWQgVGVzdCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUi4wvQXB3jD2/eJO8FB6GV7rNjbgwHwYDVR0jBBgwFoAUq8H5HFiIuVOtuJe8QJPM1p9EcN0wDgYDVR0PAQH/BAQDAgXgMBMGA1UdJQQMMAoGCCsGAQUFBwME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
 
 Printing description of context.tombstoneBlockIndex:
 2411107
 
 */
extension AccountKey.Fixtures {
    struct TestNet {
        let accountKey: AccountKey
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
            self.accountKey = try AccountKey.make(
                mnemonic: mnemonic.phrase,
                fogReportUrl: fogReportUrl,
                fogReportId: fogReportId,
                fogAuthoritySpki: self.fogAuthoritySpki).get()
        }
        
        init(accountIndex: UInt32) throws {
            self.mnemonic = Self.mnemonic()
            self.fogAuthoritySpki = try XCTUnwrap(Data(base64Encoded: Self.fogAuthoritySpkiB64))
            self.accountKey = try AccountKey.make(
                mnemonic: mnemonic.phrase,
                fogReportUrl: fogReportUrl,
                fogReportId: fogReportId,
                fogAuthoritySpki: self.fogAuthoritySpki,
                accountIndex: accountIndex).get()
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

        let viewPrivateKey: RistrettoPrivate
        let spendPrivateKey: RistrettoPrivate
        let publicAddress: PublicAddress
        let rootEntropy: Data
        let fogReportUrl = Self.fogReportUrl
        let fogReportId = Self.fogReportId
        let fogAuthoritySpki: Data

        init() throws {
            self.fogAuthoritySpki = try XCTUnwrap(Data(hexEncoded: Self.fogAuthoritySpkiHex))
            self.rootEntropy = try XCTUnwrap(Data(hexEncoded: Self.rootEntropyHex))
            self.viewPrivateKey = try XCTUnwrap(RistrettoPrivate(
                XCTUnwrap(Data(hexEncoded: Self.viewPrivateKeyHex))))
            self.spendPrivateKey = try XCTUnwrap(RistrettoPrivate(
                XCTUnwrap(Data(hexEncoded: Self.spendPrivateKeyHex))))
            self.publicAddress = try XCTUnwrap(PublicAddress(
                serializedData: XCTUnwrap(Data(hexEncoded: Self.publicAddressHex))))
            self.accountKey = try AccountKey.make(
                entropy: rootEntropy,
                fogReportUrl: fogReportUrl,
                fogReportId: "",
                fogAuthoritySpki: fogAuthoritySpki).get()

            self.manualAccountKey = try AccountKey.make(
                viewPrivateKey: viewPrivateKey,
                spendPrivateKey: spendPrivateKey,
                fogReportUrl: fogReportUrl,
                fogReportId: fogReportId,
                fogAuthoritySpki: fogAuthoritySpki).get()
        }
    }
}

extension AccountKey.Fixtures.AlphaFog {
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

extension AccountKey.Fixtures.TestNet {

    fileprivate static func mnemonic(accountIndex: UInt8 = 0) -> Mnemonic {
        Bip39Utils.mnemonic(fromEntropy: Data32(repeating: accountIndex))
    }

    fileprivate static let fogReportUrl = "fog://fog.test.mobilecoin.com"
    fileprivate static let fogReportId = ""
    fileprivate static let fogAuthoritySpkiB64 = """
        MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvnB9wTbTOT5uoizRYaYbw7XIEkInl8E7MGOA\
        Qj+xnC+F1rIXiCnc/t1+5IIWjbRGhWzo7RAwI5sRajn2sT4rRn9NXbOzZMvIqE4hmhmEzy1YQNDnfALA\
        WNQ+WBbYGW+Vqm3IlQvAFFjVN1YYIdYhbLjAPdkgeVsWfcLDforHn6rR3QBZYZIlSBQSKRMY/tywTxeT\
        CvK2zWcS0kbbFPtBcVth7VFFVPAZXhPi9yy1AvnldO6n7KLiupVmojlEMtv4FQkk604nal+j/dOplTAT\
        V8a9AJBbPRBZ/yQg57EG2Y2MRiHOQifJx0S5VbNyMm9bkS8TD7Goi59aCW6OT1gyeotWwLg60JRZTfyJ\
        7lYWBSOzh0OnaCytRpSWtNZ6barPUeOnftbnJtE8rFhF7M4F66et0LI/cuvXYecwVwykovEVBKRF4HOK\
        9GgSm17mQMtzrD7c558TbaucOWabYR04uhdAc3s10MkuONWG0wIQhgIChYVAGnFLvSpp2/aQEq3xrRSE\
        TxsixUIjsZyWWROkuA0IFnc8d7AmcnUBvRW7FT/5thWyk5agdYUGZ+7C1o69ihR1YxmoGh69fLMPIEOh\
        Yh572+3ckgl2SaV4uo9Gvkz8MMGRBcMIMlRirSwhCfozV2RyT5Wn1NgPpyc8zJL7QdOhL7Qxb+5WjnCV\
        rQYHI2cCAwEAAQ==
        """
}

extension AccountKey.Fixtures.AlphaFog {

    fileprivate static let spendPrivateKeyHex =
        "3379daf11c7d26bde2be0ab557e79285f868a1e58058ab47063950435fc7670a"
    fileprivate static let viewPrivateKeyHex =
        "605845eceee09d9bc719c590aac78b5bc2793420e716a41a12b22248be551d07"
    fileprivate static let publicAddressHex = """
        0a220a2046db671dc90016919bf8a2b0f8b2aefb6220cbff0fa30454f8fc0ffd1948820a12220a20340774b1e70\
        402c197efe792b29b989edaa2c97020df6dc8cf09fd3870d83b251a2a666f673a2f2f666f672e616c7068612e64\
        6576656c6f706d656e742e6d6f62696c65636f696e2e636f6d2a40281a4c716a006fb8f813b7d42ce11b8b69c42\
        e8ad709086482403a8142d5bd44d090e9e36565be143bd949ef85b0985c5ee44ad5397cbe2e1599551be181a08b
        """
    fileprivate static let fogReportUrl = "fog://fog.alpha.development.mobilecoin.com"
    fileprivate static let fogReportId = ""
    fileprivate static let fogAuthoritySpkiHex = """
        30820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8\
        724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf\
        529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16\
        586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4\
        888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e\
        5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d\
        75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb\
        0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b4\
        54231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538\
        f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f\
        95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f\
        4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182\
        cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9b\
        e3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a04\
        5255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0\
        b07286f9930203010001
        """

    fileprivate static let rootEntropyHex =
        "a801af55a4f6b35f0dbb4a9c754ae62b926d25dd6ed954f6e697c562a1641c21"

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

extension AccountKey.Fixtures {
    struct SeedableRng {
        // The rust code uses a seedable random number generator when testing transactions and the
        // transaction builder. The following account keys were generated with the corresponding
        // "seed" input 1u8, 2u8, etc..
        //
        // ```rust
        // let mut rng: StdRng = SeedableRng::from_seed([1u8; 32]);
        // let recipient = AccountKey::random_with_fog(&mut rng);
        // ```

        let oneSeed: AccountKey
        let twoSeed: AccountKey
        let threeSeed: AccountKey
        let fourSeed: AccountKey
        let fiveSeed: AccountKey
        let sixSeed: AccountKey
        let sevenSeed: AccountKey

        init() throws {
            self.oneSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.oneSeed))))
            self.twoSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.twoSeed))))
            self.threeSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.threeSeed))))
            self.fourSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.fourSeed))))
            self.fiveSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.fiveSeed))))
            self.sixSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.sixSeed))))
            self.sevenSeed = try XCTUnwrap(
                AccountKey(serializedData: XCTUnwrap(Data(hexEncoded: Self.sevenSeed))))
        }
    }
}

extension AccountKey.Fixtures.SeedableRng {
    static let oneSeed =
            """
            0a220a209af500f3af465b5954ab07b6eacd34c2bc6cadeea065ebd8b7f51f9383ccb\
            50312220a2037b1398cd78e25e251fa46019c7519e6b1859c97a6cee287a28d60e26c\
            4e79061a11666f673a2f2f6578616d706c652e636f6d
            """

    static let twoSeed =
            """
            0a220a20c76ec8723f3b198bf8bde76fca07cf98082189ad30a057d25271faabdd105\
            e0912220a20e9ee1a958444aef8bb3b9f8a4b3e01b3ea2e1d25dca8fd8ae91ce3adbc\
            fcb1081a11666f673a2f2f6578616d706c652e636f6d
            """

    static let threeSeed =
            """
            0a220a2095ba5c2207ab830d05a6c4adac0d10f3961c518acf990f1577ac7ff5eae8d\
            d0f12220a20b7b08e9435d572cc67540c2d08677c176ec89af06a42453ed6d1faa01d\
            0839031a11666f673a2f2f6578616d706c652e636f6d
            """

    static let fourSeed =
            """
            0a220a20502f8a05935f6bcb8f09273c09fbd6f26a4343ea88ba44966ed202f0cf25d\
            b0a12220a200ba7060b742ba4b324a4def279ecb4beeb8e56f6910b24f12638ea4ab3\
            175f0d1a11666f673a2f2f6578616d706c652e636f6d
            """

    static let fiveSeed =
            """
            0a220a203669115236ed0475033f224692803c125bfb8c92e1733f3b24939e69d9f53f0512220a20\
            c695947b751a352326e2bbdf6e5f4e91547d57ad3676dad1b2d429574192be061a11666f673a2f2f\
            6578616d706c652e636f6d
            """

    static let sixSeed =
            """
            0a220a20e75fb8cd4426d483ecf2cb57d9707e956829620f643717726029891e3cf4200f12220a20\
            c3e3517fa7262b43ac9a485c68e84f88697d88a57eab9555986c9b84c9dafd0e1a11666f673a2f2f\
            6578616d706c652e636f6d
            """

    static let sevenSeed =
            """
            0a220a20f27e1e42d395de188cf0d55e063e544642053e655125ba259e4753618d3b1e0a12220a20\
            76a08a852248c6ce5d94c8e60dfdbdec5ec18fc896e8ab3208e2bbffe5a09e091a11666f673a2f2f\
            6578616d706c652e636f6d
            """

}
