//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end multiline_function_chains

@testable import MobileCoin
import XCTest

@available(iOS 13.0, *)
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
