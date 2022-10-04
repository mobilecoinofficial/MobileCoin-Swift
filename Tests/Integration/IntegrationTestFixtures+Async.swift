//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

#if swift(>=5.5)
// swiftlint:disable superfluous_disable_command
// swiftlint:disable multiline_parameters

@available(iOS 15.0, *)
extension IntegrationTestFixtures {

    static func createMobileCoinClientWithBalance(
        accountKey: AccountKey,
        transportProtocol: TransportProtocol
    ) async throws -> MobileCoinClient {
        let client = try createMobileCoinClient(accountKey: accountKey,
                                                transportProtocol: transportProtocol)
        let balances = try await client.updateBalances()
        let picoMob = try XCTUnwrap(balances.mobBalance.amount())
        XCTAssertGreaterThan(picoMob, 0)
        return client
    }

}

#endif
