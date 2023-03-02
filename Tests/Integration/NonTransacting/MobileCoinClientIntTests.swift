//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_body_length closure_body_length

@testable import MobileCoin
import XCTest

class MobileCoinClientIntTests: XCTestCase {

    func testTransactionStatusDoesNotSucceedWithoutSubmission() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionStatusDoesNotSucceedWithoutSubmission(
                    transportProtocol: $0,
                    expectation: $1)
        }
    }

    func transactionStatusDoesNotSucceedWithoutSubmission(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 0,
                using: transportProtocol)
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

    func receiptStatusDoesNotSucceedWithoutSubmission(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 0,
                using: transportProtocol)
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

    func concurrentBalanceChecks(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

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

    func concurrentBalanceChecksWhileUpdating(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

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

    func concurrentBalanceUpdates(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

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
