//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

enum IdempotenceTestError: Error {
    case testError(String = String())
    case transactionSubmissionError(TransactionSubmissionError)
}

class TransactionIdempotenceTests: XCTestCase {

    func testIdempotenceSubmissionFailure() throws {
        let description = "Testing idempotence submission failure"
        try testSupportedProtocols(description: description) {
            try idempotenceSubmissionFailure(transportProtocol: $0, expectation: $1)
        }
    }

    func idempotenceSubmissionFailure(
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

        func submitStandardTransaction(
            completion: @escaping (Result<UInt64, IdempotenceTestError>) -> Void
        ) {
            let amt = Amount(mob: 100)

            client.updateBalances {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rngSeed: rngSeed
                ) { result in
                    guard let transaction = result.successOrFulfill(expectation: expect) else {
                        return
                    }

                    client.submitTransaction(transaction.transaction) {
                        switch $0 {
                        case .success:
                            waitForTransaction(
                                transaction: transaction.transaction,
                                completion: completion)
                        case .failure(let error):
                            completion(.failure(.transactionSubmissionError(error)))
                        }
                    }
                }
            }
        }

        submitStandardTransaction { result in
            guard result.successOrFulfill(expectation: expect) != nil else { return }

            // give things a chance to update so we don't get 'Inputs already spent' error
            Thread.sleep(forTimeInterval: 5)

            submitStandardTransaction {
                guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                switch error {
                case .testError(let msg):
                    XCTFail(msg)
                case .transactionSubmissionError(let transSubError):
                    switch transSubError {
                    case .outputAlreadyExists:
                        expect.fulfill()
                    default:
                        XCTFail(transSubError.localizedDescription)
                        expect.fulfill()
                    }
                }
            }
        }
    }

    func testTransactionIdempotence() throws {
        let description = "Testing transaction idempotence"
        try testSupportedProtocols(description: description) {
            try transactionIdempotence(transportProtocol: $0, expectation: $1)
        }
    }

    func transactionIdempotence(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let amt = Amount(mob: 100)
        let rngSeed = RngSeed()

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let expect = expectation(description: description)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
            expectation: expect,
            transportProtocol: .http)
        { client in
            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rngSeed: rngSeed
            ) { result in
                guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                    return
                }
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rngSeed: rngSeed
                ) {
                    guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                        return
                    }

                    XCTAssertEqual(transaction1, transaction2)
                    expect.fulfill()
                }

            }
        }
        waitForExpectations(timeout: 40)
    }

}
