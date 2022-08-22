//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable empty_xctest_method

@testable import MobileCoin
import XCTest

@available(iOS 13.0, *)
class TransactionIdempotenceTests: XCTestCase {

    func testTransactionSeedIdempotenceProtocols() async throws {
        let description = "Testing Transaction Idempotence with RNG Seed Initialization"
        try await testSupportedProtocols(description: description) {
            try await self.testTransactionSeedIdempotence(transportProtocol: $0)
        }
    }

    func testTransactionSeedIdempotence(transportProtocol: TransportProtocol) async throws {

        let seed = withMcInfallibleReturningOptional {
            try? Data(randomOfLength: 32)
        }

        let seed32 = withMcInfallibleReturningOptional {
            Data32(seed)
        }

        let rng1: MobileCoinRng = MobileCoinChaCha20Rng(seed32: seed32)
        let rng2: MobileCoinRng = MobileCoinChaCha20Rng(seed32: seed32)

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )

        let tx1 = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(mob: 100),
            fee: IntegrationTestFixtures.fee,
            rng: rng1,
            memoType: .unused)

        let tx2 = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(mob: 100),
            fee: IntegrationTestFixtures.fee,
            rng: rng2,
            memoType: .unused)

        XCTAssertEqual(tx1, tx2)
    }

    func testTransactionWordPosIdempotenceProtocols() async throws {
        let description = "Testing Transaction Idempotence with RNG Seed Initialization"
        try await testSupportedProtocols(description: description) {
            try await self.testTransactionWordPosIdempotence(transportProtocol: $0)
        }
    }

    func testTransactionWordPosIdempotence(transportProtocol: TransportProtocol) async throws {
        let rng1 = MobileCoinChaCha20Rng()

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )

        // prepare first transaction to get RNG past initial wordpos
        _ = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(mob: 100),
            fee: IntegrationTestFixtures.fee,
            rng: rng1,
            memoType: .unused)

        // capture wordpos
        let seed = rng1.seed
        let wordPos = rng1.wordPos()

        let tx2 = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(mob: 100),
            fee: IntegrationTestFixtures.fee,
            rng: rng1,
            memoType: .unused)

        let rng2 = MobileCoinChaCha20Rng(seed: seed)
        rng2.setWordPos(wordPos)

        let tx3 = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(mob: 100),
            fee: IntegrationTestFixtures.fee,
            rng: rng2,
            memoType: .unused)

        XCTAssertEqual(tx2, tx3)
    }
}
