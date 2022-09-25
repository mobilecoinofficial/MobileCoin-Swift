//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

enum IdempotenceTestError: Error {
    case testError(String = String())
}

class TransactionIdempotenceTests: XCTestCase {

    func testAndroidIdempotenceOutputPublicKeyMatch() throws {
        let description = "Testing idempotence submission failure"
        try testSupportedProtocols(description: description) {
            try androidIdempotenceOutputPublicKeyMatch(transportProtocol: $0, expectation: $1)
        }
    }

    func androidIdempotenceOutputPublicKeyMatch(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let rngSeedHex =
            "676f746f2068747470733a2f2f6275792e6d6f62696c65636f696e2e636f6d00"
        let recipientAddressHex = """
            0a220a2048d9e6aa836d7aa57f7a9da9709603d8f5071faff4908c86ed829e68c0129f63\
            12220a207ee52b7741a8b9f3701ab716fa361483b03ddcaeecb64ba64355a3411c87d43d
            """
        let androidTxOutputPublicKeyHex =
            "d47d4f6525cee846a47106e92de3e63e5b3cb677b8ae4df7efd667e2bad15719"

        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 1,
                using: transportProtocol)
        let rngSeed = try XCTUnwrap(RngSeed(try XCTUnwrap(Data(hexEncoded: rngSeedHex))))
        let recipientAddressData = try XCTUnwrap(Data(hexEncoded: recipientAddressHex))
        let recipient = try XCTUnwrap(PublicAddress(serializedData: recipientAddressData))
        let androidTxOutputPublicKey = try XCTUnwrap(Data(hexEncoded: androidTxOutputPublicKeyHex))
        let amt = Amount(mob: 100)

        client.updateBalances {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }
            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rng: MobileCoinChaCha20Rng(rngSeed: rngSeed)
            ) { result in
                guard let payload = result.successOrFulfill(expectation: expect) else {
                    XCTFail("Invalid payload from prepareTransaction")
                    return
                }
                XCTAssertEqual(payload.payloadTxOutContext.txOutPublicKey, androidTxOutputPublicKey)
                expect.fulfill()
            }
        }
    }

    func testIdempotenceDoubleSubmissionFailure() throws {
        let description = "Testing idempotence submission failure"
        try testSupportedProtocols(description: description) {
            try idempotenceDoubleSubmissionFailure(transportProtocol: $0, expectation: $1)
        }
    }

    func idempotenceDoubleSubmissionFailure(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {

        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 1,
                using: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)
        let rngSeed = RngSeed()

        func waitForTransaction(
            transaction: Transaction,
            completion: @escaping (Result<UInt64, IdempotenceTestError>) -> Void
        ) {
            var numChecksRemaining = 10

            func checkStatus() {
                numChecksRemaining -= 1
                client.updateBalances {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }
                    client.txOutStatus(of: transaction) {
                        guard let status = $0.successOrFulfill(expectation: expect) else { return }
                        switch status {
                        case .unknown:
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to resolve transaction status check")
                                completion(.failure(.testError("Unknown transaction status")))
                                return
                            }

                            Thread.sleep(forTimeInterval: 2)
                            checkStatus()
                            return
                        case .accepted(block: let block):
                            XCTAssertGreaterThan(block.index, 0)
                            completion(.success(block.index))
                        case .failed:
                            XCTFail("Transaction status check: Transaction failed")
                        }
                    }
                }
            }
            checkStatus()
        }

        func submitTransaction(
            completion: @escaping (Result<Transaction, SubmitTransactionError>) -> Void
        ) {
            let amt = Amount(mob: 100)

            client.updateBalances {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: MobileCoinChaCha20Rng(rngSeed: rngSeed)
                ) { result in
                    guard let payload = result.successOrFulfill(expectation: expect) else {
                        return
                    }

                    let transaction = payload.transaction
                    client.submitTransaction(transaction: transaction, completion: { result in
                        completion(result.map({ _ in transaction }))
                    })
                }
            }
        }

        submitTransaction { result in
            guard let transaction = try? XCTUnwrapSuccess(result) else {
                XCTFail("Initial transaction submission failed")
                return
            }

            waitForTransaction(
                transaction: transaction,
                completion: { _ in
                    guard result.successOrFulfill(expectation: expect) != nil else { return }

                    // give things a chance to update so we don't get 'Inputs already spent' error
                    Thread.sleep(forTimeInterval: 5)

                    submitTransaction {
                        guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                        switch error.submissionError {
                        case .outputAlreadyExists:
                            expect.fulfill()
                        default:
                            XCTFail(error.localizedDescription)
                            expect.fulfill()
                        }
                    }
                })
        }
    }

    func testStaticAccountTransactionIdempotence() throws {
        let description = "Testing transaction idempotence"
        try testSupportedProtocols(description: description) {
            try staticAccountTransactionIdempotence(transportProtocol: $0, expectation: $1)
        }
    }

    func staticAccountTransactionIdempotence(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let amt = Amount(mob: 100)
        let rngSeed = RngSeed()

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
            expectation: expect,
            transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rng: MobileCoinChaCha20Rng(rngSeed: rngSeed)
            ) { result in
                guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                    return
                }
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: MobileCoinChaCha20Rng(rngSeed: rngSeed)
                ) {
                    guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                        return
                    }

                    XCTAssertTrue(PendingSinglePayloadTransaction.areIdempotent(
                        transaction1,
                        transaction2))
                    expect.fulfill()
                }

            }
        }
    }

}
