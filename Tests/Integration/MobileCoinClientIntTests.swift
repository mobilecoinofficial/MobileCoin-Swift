//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments

@testable import MobileCoin
import XCTest

class MobileCoinClientIntTests: XCTestCase {

    func testTransactionDoubleSubmissionFails() throws {
        let description = "Submitting transaction twice"
        try testSupportedProtocols(description: description) {
            try transactionDoubleSubmissionFails(transportProtocol: $0, expectation: $1)
        }
    }

    func transactionDoubleSubmissionFails(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(expectation: expect, transportProtocol: transportProtocol)
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
    }

    /// Tests that the transaction status check fails if the inputs were spent by another
    /// transaction
    func testTransactionStatusFailsWhenInputIsAlreadySpent() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionStatusFailsWhenInputIsAlreadySpent(transportProtocol: $0, expectation: $1)
        }
    }
    
    func transactionStatusFailsWhenInputIsAlreadySpent(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

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
    }

    func testTransactionStatusDoesNotSucceedWithoutSubmission() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionStatusDoesNotSucceedWithoutSubmission(transportProtocol: $0, expectation: $1)
        }
    }
    
    func transactionStatusDoesNotSucceedWithoutSubmission(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)


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
    }

    func testReceiptStatusDoesNotSucceedWithoutSubmission() throws {
        let description = "Checking receipt status fails"
        try testSupportedProtocols(description: description) {
            try receiptStatusDoesNotSucceedWithoutSubmission(transportProtocol: $0, expectation: $1)
        }
    }
    
    func receiptStatusDoesNotSucceedWithoutSubmission(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, transportProtocol: transportProtocol)
        let receiverAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let receiverClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: receiverAccountKey,
            transportProtocol: transportProtocol)

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
    }

    func testConcurrentBalanceChecks() throws {
        let description = "Checking account balance"
        try testSupportedProtocols(description: description) {
            try concurrentBalanceChecks(transportProtocol: $0, expectation: $1)
        }
    }
    
    func concurrentBalanceChecks(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }

            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
                guard amountPicoMob > 0 else { expect.fulfill(); return }
            }

            concurrentReadCachedBalance()
        }
        func concurrentReadCachedBalance() {
            let group = DispatchGroup()
            for _ in (0..<100) {
                group.enter()
                DispatchQueue.global().async {
                    if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                        print("balance: \(amountPicoMob)")
                        XCTAssertGreaterThan(amountPicoMob, 0)
                        guard amountPicoMob > 0 else { expect.fulfill(); return }
                    }
                    group.leave()
                }
            }
            group.notify(queue: DispatchQueue.main) {
                expect.fulfill()
            }
        }
    }

    func testConcurrentBalanceChecksWhileUpdating() throws {
        let description = "Checking account balance"
        try testSupportedProtocols(description: description) {
            try concurrentBalanceChecksWhileUpdating(transportProtocol: $0, expectation: $1)
        }
    }
    
    func concurrentBalanceChecksWhileUpdating(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

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
    }

    func testConcurrentBalanceUpdates() throws {
        let description = "Checking account balance"
        try testSupportedProtocols(description: description) {
            try concurrentBalanceUpdates(transportProtocol: $0, expectation: $1)
        }
    }
    
    func concurrentBalanceUpdates(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

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
    }

}
