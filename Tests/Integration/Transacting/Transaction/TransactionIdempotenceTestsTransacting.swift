//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

#if swift(>=5.5)

@available(iOS 15.0, macOS 12.0, *)
enum IdempotenceTestError: Error {
    case testError(String = String())
}

@available(iOS 15.0, macOS 12.0, *)
class TransactionIdempotenceTestsTransacting: XCTestCase {

    func testIdempotenceDoubleSubmissionFailure() async throws {
        let description = "Testing idempotence submission failure"
        try await testSupportedProtocols(description: description) {
            try await self.idempotenceDoubleSubmissionFailure(transportProtocol: $0)
        }
    }

    func idempotenceDoubleSubmissionFailure(
        transportProtocol: TransportProtocol
    ) async throws {
        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")

        try await client.updateBalances()

        let rngSeed = RngSeed()

        func submitTransaction() async throws -> Transaction {
            let amt = Amount(mob: 100)

            try await client.updateBalances()
            let payload = try await client.prepareTransaction(
                to: recipientAccountKey.publicAddress,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rng: MobileCoinChaCha20Rng(rngSeed: rngSeed),
                memoType: .unused)
            let transaction = payload.transaction
            try await client.submitTransaction(transaction: transaction)
            return transaction
        }

        let transaction = try await submitTransaction()

        var txComplete = false
        while !txComplete {
            try await client.updateBalances()
            let txStatus = try await client.status(of: transaction)
            switch txStatus {
            case .accepted(block: _ ):
                txComplete = true
            case .failed:
                XCTFail("First transaction failed or failed to succeed in time")
                return
            case .unknown:
                // throttle the polling a bit
                sleep(1)
            }
        }

        do {
            _ = try await submitTransaction()
        } catch let subTransError as SubmitTransactionError {
            switch subTransError.submissionError {
            case .outputAlreadyExists:
                print("Success! Got output already exists as expected!")
                return
            default:
                XCTFail("Received error: \(subTransError)")
            }
        } catch {
            XCTFail("Temp Failure: \(error)")
        }
        XCTFail("Second submission should not have succeeded")
    }
}

#endif
