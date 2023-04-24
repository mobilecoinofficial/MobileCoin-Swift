//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments function_body_length closure_body_length

@testable import MobileCoin
import XCTest

class MobileCoinClientIntTests: XCTestCase {

    func testTransactionDoubleSubmissionFails() throws {
        let description = "Submitting transaction twice"
        try testSupportedProtocols(description: description) {
            try transactionDoubleSubmissionFails(transportProtocol: $0, expectation: $1)
        }
    }

    func transactionDoubleSubmissionFails(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")

        client.updateBalances { _ in
            client.prepareTransaction(
                to: recipientAccountKey.publicAddress,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                client.submitTransaction(transaction) { result in
                    guard result.successOrFulfill(expectation: expect) != nil else { return }
                    print("First transaction submission successful")

                    Thread.sleep(forTimeInterval: 2)

                    client.submitTransaction(transaction) { result in
                        guard let error = result.failureOrFulfill(expectation: expect)
                        else { return }
                        print("Second transaction submission: \(error)")

                        expect.fulfill()
                    }
                }
            }
        }
    }

    /// Tests that the transaction status check fails if the inputs were spent by another
    /// transaction
    func testTransactionStatusFailsWhenInputIsAlreadySpent() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionStatusFailsWhenInputIsAlreadySpent(
                    transportProtocol: $0,
                    expectation: $1)
        }
    }

    func transactionStatusFailsWhenInputIsAlreadySpent(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")

        client.updateBalances { _ in
            let submitTransaction = { (callback: @escaping (Transaction) -> Void) in
                client.updateBalance {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    Array(repeating: (), count: 2).mapAsync({ _, callback in
                        client.prepareTransaction(
                            to: recipientAccountKey.publicAddress,
                            amount: 100,
                            fee: IntegrationTestFixtures.fee,
                            completion: callback)
                    }, serialQueue: DispatchQueue.main, completion: {
                        guard let transactions = $0.successOrFulfill(expectation: expect)
                        else { return }
                        let (transactionToCheck, _) = transactions[0]
                        let (transactionToSubmit, _) = transactions[1]

                        // Ensure both Tx's are using the same inputs.
                        // Note: It is not strictly necessary that 2 transactions prepared in
                        // succession with the same amount/fee must use the same input TxOut's,
                        // however, for the time being this assertion is the best way to ensure
                        // that they do match. If TxOut selection becomes non-deterministic in the
                        // future, then this code should be changed to ensure the same inputs are
                        // selected.
                        XCTAssertEqual(
                            transactions[0].0.inputKeyImagesTyped,
                            transactions[1].0.inputKeyImagesTyped)

                        client.submitTransaction(transactionToSubmit) {
                            guard $0.successOrFulfill(expectation: expect) != nil else { return }

                            callback(transactionToCheck)
                        }
                    })
                }
            }

            submitTransaction { (transaction: Transaction) in
                var numChecksRemaining = 5

                func checkStatus() {
                    numChecksRemaining -= 1
                    print("Checking status...")
                    client.status(of: transaction) {
                        guard let status = $0.successOrFulfill(expectation: expect) else { return }
                        print("Transaction status: \(status)")

                        switch status {
                        case .unknown:
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to resolve transaction status check")
                                expect.fulfill()
                                return
                            }

                            Thread.sleep(forTimeInterval: 2)
                            checkStatus()
                            return
                        case .accepted(block: let block):
                            print("Block index: \(block.index)")
                            XCTAssertGreaterThan(block.index, 0)

                            if let timestamp = block.timestamp {
                                print("Block timestamp: \(timestamp)")
                            }
                            XCTFail("Transaction status check succeeded when it should have failed")
                        case .failed:
                            break
                        }

                        expect.fulfill()
                    }
                }
                checkStatus()
            }
        }
    }

}
