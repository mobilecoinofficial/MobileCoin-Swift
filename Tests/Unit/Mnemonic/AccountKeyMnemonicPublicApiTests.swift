//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class AccountKeyMnemonicPublicApiTests: XCTestCase {

    func testAccountKeyFromMnemonicUsingAccountIndex0() throws {
        let fixture = try AccountKey.Fixtures.Init()
        let accountKey = try XCTUnwrapSuccess(AccountKey.make(
            mnemonic:
                "service margin rural era prepare axis fabric autumn season kingdom corn hover",
            fogReportUrl: fixture.fogReportUrl,
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki,
            accountIndex: 0))
        XCTAssertEqual(
            accountKey.serializedData,
            try XCTUnwrap(Data(base64Encoded: """
                CiIKIEvyrGPKQ6Ps0+QJqODVIrPAKv9xV7ycK/sJ0fzXt+4JEiIKIHofH9NIbr4BlMHczWO4WjTeb8ixdJ/\
                yv6UL/5WCRtsOGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qpgQwggIiMA0GCSqGSI\
                b3DQEBAQUAA4ICDwAwggIKAoICAQDEAFnvlBm/24f38TzbdVNOalaI6J6GiqSxkyqwMBGph0N7EBBvVj6rJ\
                PoeWnlAxQdCWSiYUoueF7/T7DFnX+5OqeHLYVGGuVyWk69zNPXRKZzH1GQoAKnEJbT3kxbF4XC0yYumqRd+\
                Xgp4ym3F0dEBIe4uUov4VfA6orDcnafDmrYOkGyDU42R1bibnlkV2KZfcztP9a6vlaUH6e0GkoVT/lP6t0P\
                c5Sb+0TFtiTsLnxeZhbTxOcVH0k4x6QVkyZN+Xl3V57eSjLPPbblB80S6lQkNUxdyDjCGnzbpqvFAheszYN\
                +DBmfEWpLrXt02w482MigBhIQU9zNhPD1YdHs7dQhKdjBi8KxfEbAtktcWSBQEzkYoi28QcNtSHcLtmPIzn\
                UDTgQmDjsbecjUDqr0RWebAZpkXGrxskDOiyfnNpKttQDbmFF9/bkLgFg2PJ0EjXfc+NJ+UtoaOclg+u4s7\
                henMHfCzOoqbe2JY3f2yALiwxZl9KXGVajHdLNjZdWXxD1Gow7wsxQ82HCZN+kRcNbn42of68yIf1SaeyIT\
                DJsVyF7iwTbc0lN47ZfK23nlV+gPYaJ2179Kq3kAlQ+7qd8rxCWg4JnU330yulalxk8eK22ppgdnmVZccq2\
                Gn+KbrvaFc+Xxs3ExShESqiZl0P2Z2P8/rD3MV5OSvs/1dBQIDAQAB
                """)))
    }

    func testAccountKeyFromMnemonicUsingAccountIndex1() throws {
        let fixture = try AccountKey.Fixtures.Init()
        let accountKey = try XCTUnwrapSuccess(AccountKey.make(
            mnemonic:
                "service margin rural era prepare axis fabric autumn season kingdom corn hover",
            fogReportUrl: fixture.fogReportUrl,
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki,
            accountIndex: 1))
        XCTAssertEqual(
            accountKey.serializedData,
            try XCTUnwrap(Data(base64Encoded: """
                CiIKIIyX8i7rCnT19ObUPkj4MM9e/rqiJKl56ncEpi8Dcu0KEiIKIPeo5iP9B6+073B+iOUuG27I9a7zJzv\
                f8dvA4cr0AJ4AGiRmb2c6Ly9mb2ctcmVwb3J0LmZha2UubW9iaWxlY29pbi5jb20qpgQwggIiMA0GCSqGSI\
                b3DQEBAQUAA4ICDwAwggIKAoICAQDEAFnvlBm/24f38TzbdVNOalaI6J6GiqSxkyqwMBGph0N7EBBvVj6rJ\
                PoeWnlAxQdCWSiYUoueF7/T7DFnX+5OqeHLYVGGuVyWk69zNPXRKZzH1GQoAKnEJbT3kxbF4XC0yYumqRd+\
                Xgp4ym3F0dEBIe4uUov4VfA6orDcnafDmrYOkGyDU42R1bibnlkV2KZfcztP9a6vlaUH6e0GkoVT/lP6t0P\
                c5Sb+0TFtiTsLnxeZhbTxOcVH0k4x6QVkyZN+Xl3V57eSjLPPbblB80S6lQkNUxdyDjCGnzbpqvFAheszYN\
                +DBmfEWpLrXt02w482MigBhIQU9zNhPD1YdHs7dQhKdjBi8KxfEbAtktcWSBQEzkYoi28QcNtSHcLtmPIzn\
                UDTgQmDjsbecjUDqr0RWebAZpkXGrxskDOiyfnNpKttQDbmFF9/bkLgFg2PJ0EjXfc+NJ+UtoaOclg+u4s7\
                henMHfCzOoqbe2JY3f2yALiwxZl9KXGVajHdLNjZdWXxD1Gow7wsxQ82HCZN+kRcNbn42of68yIf1SaeyIT\
                DJsVyF7iwTbc0lN47ZfK23nlV+gPYaJ2179Kq3kAlQ+7qd8rxCWg4JnU330yulalxk8eK22ppgdnmVZccq2\
                Gn+KbrvaFc+Xxs3ExShESqiZl0P2Z2P8/rD3MV5OSvs/1dBQIDAQAB
                """)))
    }

}
