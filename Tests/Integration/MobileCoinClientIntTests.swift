//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments

@testable import MobileCoin
import XCTest

class MobileCoinClientIntTests: XCTestCase {

    func testTransactionDoubleSubmissionFails() throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Submitting transaction twice")
        try IntegrationTestFixtures.createMobileCoinClientWithBalance(expectation: expect)
        { client in
            client.prepareTransaction(
                to: recipient,
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
        waitForExpectations(timeout: 20)
    }

    /// Tests that the transaction status check fails if the inputs were spent by another
    /// transaction
    func testTransactionStatusFailsWhenInputIsAlreadySpent() throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Checking transaction status")
        let submitTransaction = { (callback: @escaping (Transaction) -> Void) in
            client.updateBalance {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                Array(repeating: (), count: 2).mapAsync({ _, callback in
                    client.prepareTransaction(
                        to: recipient,
                        amount: 100,
                        fee: IntegrationTestFixtures.fee,
                        completion: callback)
                }, serialQueue: DispatchQueue.main, completion: {
                    guard let transactions = $0.successOrFulfill(expectation: expect)
                    else { return }
                    let (transactionToCheck, _) = transactions[0]
                    let (transactionToSubmit, _) = transactions[1]

                    // Ensure both Tx's are using the same inputs.
                    // Note: It is not strictly necessary that 2 transactions prepared in succession
                    // with the same amount/fee must use the same input TxOut's, however, for the
                    // time being this assertion is the best way to ensure that they do match. If
                    // TxOut selection becomes non-deterministic in the future, then this code
                    // should be changed to ensure the same inputs are selected.
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
        waitForExpectations(timeout: 20)
    }

    func testTransactionStatusDoesNotSucceedWithoutSubmission() throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Checking transaction status")

        func createTransaction(callback: @escaping (Transaction) -> Void) {
            senderClient.updateBalance {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                senderClient.prepareTransaction(
                    to: recipient,
                    amount: 100,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    callback(transaction)
                }
            }
        }

        createTransaction { (transaction: Transaction) in
            var numChecksRemaining = 5
            func checkStatus() {
                numChecksRemaining -= 1
                print("Checking status...")
                senderClient.status(of: transaction) {
                    guard let status = $0.successOrFulfill(expectation: expect) else { return }
                    print("Transaction status: \(status)")

                    switch status {
                    case .unknown:
                        guard numChecksRemaining > 0 else {
                            expect.fulfill()
                            return
                        }

                        Thread.sleep(forTimeInterval: 2)
                        checkStatus()
                        return
                    case .accepted:
                        XCTFail("Transaction status check incorrectly returned successful: " +
                            "\(status)")
                    case .failed:
                        break
                    }
                    expect.fulfill()
                }
            }
            checkStatus()
        }
        waitForExpectations(timeout: 20)
    }

    func testReceiptStatusDoesNotSucceedWithoutSubmission() throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0)
        let receiverAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let receiverClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: receiverAccountKey)

        let expect = expectation(description: "Checking receipt status fails")
        func updateBalances(callback: @escaping () -> Void) {
            senderClient.updateBalance {
                guard let senderBalance = $0.successOrFulfill(expectation: expect) else { return }
                print("Account 0 balance: \(senderBalance)")

                receiverClient.updateBalance {
                    guard let receiverBalance = $0.successOrFulfill(expectation: expect)
                    else { return }
                    print("Account 1 balance: \(receiverBalance)")

                    callback()
                }
            }
        }

        func createTransaction(callback: @escaping (Receipt) -> Void) {
            updateBalances {
                senderClient.prepareTransaction(
                    to: receiverAccountKey.publicAddress,
                    amount: 100,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (_, receipt) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    callback(receipt)
                }
            }
        }

        createTransaction { (receipt: Receipt) in
            var numChecksRemaining = 5

            func checkStatus() {
                numChecksRemaining -= 1
                print("Checking status...")
                receiverClient.updateBalance {
                    guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                    print("Account 1 balance: \(balance)")

                    guard let status = receiverClient.status(of: receipt)
                            .successOrFulfill(expectation: expect) else { return }
                    print("Receipt status: \(status)")

                    switch status {
                    case .unknown:
                        guard numChecksRemaining > 0 else {
                            expect.fulfill()
                            return
                        }

                        Thread.sleep(forTimeInterval: 2)
                        checkStatus()
                        return
                    case .received:
                        XCTFail("Receipt status check incorrectly returned successful: \(status)")
                    case .failed:
                        break
                    }
                    expect.fulfill()
                }
            }
            checkStatus()
        }
        waitForExpectations(timeout: 20)
    }

    func testConcurrentBalanceChecksWhileUpdating() throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient()

        let expect = expectation(description: "Checking account balance")
        let group = DispatchGroup()

        for _ in (0..<100) {
            group.enter()
            func async() {
                DispatchQueue.global().async {
                    do {
                        guard try XCTUnwrap(client.balance.amountPicoMob()) > 0 else {
                            async()
                            return
                        }
                    } catch {}
                    group.leave()
                }
            }
            async()
        }

        group.enter()
        client.updateBalance {
            guard let balance = $0.successOrLeaveGroup(group) else { return }

            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }
            group.leave()
        }

        group.notify(queue: DispatchQueue.main) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testConcurrentBalanceUpdates() throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient()

        let expect = expectation(description: "Checking account balance")
        let group = DispatchGroup()

        for _ in (0..<5) {
            group.enter()
            DispatchQueue.global().async {
                client.updateBalance {
                    guard let balance = $0.successOrLeaveGroup(group) else { return }

                    if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                        print("balance: \(amountPicoMob)")
                        XCTAssertGreaterThan(amountPicoMob, 0)
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: DispatchQueue.main) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

}
