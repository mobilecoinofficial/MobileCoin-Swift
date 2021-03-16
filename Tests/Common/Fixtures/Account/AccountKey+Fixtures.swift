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
        let rootEntropy = Self.rootEntropy()
        var rootEntropyData: Data { rootEntropy.data }

        let fogReportUrl = Self.fogReportUrl
        let fogReportId = Self.fogReportId
        let fogAuthoritySpki: Data

        let viewPrivateKey = DefaultZero.viewPrivateKey
        let spendPrivateKey = DefaultZero.spendPrivateKey

        init() throws {
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
            let rootEntropy = Init.rootEntropy(accountIndex: accountIndex)
            self.fogAuthoritySpki = initFixture.fogAuthoritySpki
            self.accountKey = try AccountKey.make(
                rootEntropy: rootEntropy,
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
                rootEntropy: initFixture.rootEntropy,
                fogReportUrl: initFixture.fogReportUrl,
                fogReportId: initFixture.fogReportId,
                fogAuthoritySpki: initFixture.fogAuthoritySpki).get()
        }
    }
}

extension AccountKey.Fixtures {
    struct DefaultWithoutFog {
        let accountKey: AccountKey

        init(accountIndex: UInt8 = 0) {
            let rootEntropy = Init.rootEntropy(accountIndex: accountIndex)
            self.accountKey = AccountKey(rootEntropy: rootEntropy)
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

    fileprivate static func rootEntropy(accountIndex: UInt8 = 0) -> Data32 {
        Data32(repeating: accountIndex)
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

extension AccountKey.Fixtures.DefaultZero {

    fileprivate static let viewPrivateKey = RistrettoPrivate([
        176, 20, 109, 232, 205, 143, 91, 121, 98, 249, 231, 74, 94, 240, 243, 229, 138, 149, 80,
        201, 82, 122, 193, 68, 243, 135, 41, 240, 253, 63, 237, 14,
    ])!
    fileprivate static let spendPrivateKey = RistrettoPrivate([
        180, 191, 1, 167, 126, 212, 224, 101, 233, 8, 45, 75, 218, 103, 173, 211, 12, 136, 224, 33,
        220, 248, 31, 200, 78, 106, 156, 162, 203, 104, 225, 7,
    ])!

    fileprivate static let subaddressViewPrivateKey = RistrettoPrivate([
        190, 159, 158, 147, 230, 83, 60, 59, 37, 3, 134, 114, 0, 240, 50, 243, 30, 60, 78, 15, 23,
        150, 31, 246, 192, 1, 117, 76, 241, 99, 148, 8,
    ])!
    fileprivate static let subaddressSpendPrivateKey = RistrettoPrivate([
        128, 29, 25, 125, 89, 6, 98, 50, 91, 210, 140, 113, 249, 47, 95, 68, 249, 192, 181, 168, 30,
        209, 41, 9, 255, 9, 184, 51, 216, 181, 97, 6,
    ])!

}

extension AccountKey.Fixtures.Serialization {

    fileprivate static let serializedDataB64Encoded = """
        CiIKILAUbejNj1t5YvnnSl7w8+WKlVDJUnrBRPOHKfD9P+0OEiIKILS/Aad+1OBl6QgtS9pnrdMMiOAh3PgfyE5qnKL\
        LaOEHGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qpgQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDw\
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
