//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable type_body_length

import MobileCoin
import XCTest

class MobileCoinClientPublicApiIntTests: XCTestCase {

    func testBalance() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try balance(transportProtocol: $0, expectation: $1)
        }
    }

    func balance(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }

            expect.fulfill()
        }
    }

    func testAccountActivity() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try accountActivity(transportProtocol: $0, expectation: $1)
        }
    }
    
    func accountActivity(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            let accountActivity = client.accountActivity

            print("txOuts.count: \(accountActivity.txOuts.count)")
            XCTAssertGreaterThan(accountActivity.txOuts.count, 0)

            print("blockCount: \(accountActivity.blockCount)")
            XCTAssertGreaterThan(accountActivity.blockCount, 0)

            expect.fulfill()
        }
    }

    func testUpdateBalance() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try updateBalance(transportProtocol: $0, expectation: $1)
        }
    }
    
    func updateBalance(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol).updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }

            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }
            expect.fulfill()
        }
    }

    func testPrepareTransaction() throws {
        let description = "Preparing transaction"
        try testSupportedProtocols(description: description) {
            try prepareTransaction(transportProtocol: $0, expectation: $1)
        }
    }
    
    func prepareTransaction(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(expectation: expect, transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                print("Transaction preparation successful")
                expect.fulfill()
            }
        }
    }

    func testSubmitTransaction() throws {
        let description = "Submitting transaction"
        try testSupportedProtocols(description: description) {
            try submitTransaction(transportProtocol: $0, expectation: $1)
        }
    }
    
    func submitTransaction(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(expectation: expect, transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

    func testSelfPaymentBalanceChange() throws {
        let description = "Self payment"
        try testSupportedProtocols(description: description) {
            try selfPaymentBalanceChange(transportProtocol: $0, expectation: $1)
        }
    }
    
    func selfPaymentBalanceChange(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        func submitTransaction(callback: @escaping (Balance) -> Void) {
            client.updateBalance {
                guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                print("Initial balance: \(balance)")

                client.prepareTransaction(
                    to: accountKey.publicAddress,
                    amount: 100,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    client.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }

                        print("Transaction submission successful")
                        callback(balance)
                    }
                }
            }
        }

        submitTransaction { initialBalance in
            var numChecksRemaining = 5
            func checkBalance() {
                numChecksRemaining -= 1
                print("Updating balance...")
                client.updateBalance {
                    guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balance: \(balance)")

                    do {
                        let balancePicoMob = try XCTUnwrap(balance.amountPicoMob())
                        let initialBalancePicoMob = try XCTUnwrap(initialBalance.amountPicoMob())
                        let expectedBalancePicoMob =
                            initialBalancePicoMob - IntegrationTestFixtures.fee
                        guard balancePicoMob == expectedBalancePicoMob else {
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to receive a changed balance. balance: " +
                                    "\(balancePicoMob), expected balance: " +
                                    "\(expectedBalancePicoMob) picoMOB")
                                expect.fulfill()
                                return
                            }

                            Thread.sleep(forTimeInterval: 2)
                            checkBalance()
                            return
                        }
                    } catch {}
                    expect.fulfill()
                }
            }
            checkBalance()
        }
    }

    func testSelfPaymentBalanceChangeFeeLevel() throws {
        let description = "Self payment"
        try testSupportedProtocols(description: description) {
            try selfPaymentBalanceChangeFeeLevel(transportProtocol: $0, expectation: $1)
        }
    }
    
    func selfPaymentBalanceChangeFeeLevel(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        func submitTransaction(callback: @escaping (Balance) -> Void) {
            client.updateBalance {
                guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                print("Initial balance: \(balance)")

                client.prepareTransaction(
                    to: accountKey.publicAddress,
                    amount: 100,
                    feeLevel: .minimum
                ) {
                    guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    client.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }

                        print("Transaction submission successful")
                        callback(balance)
                    }
                }
            }
        }

        submitTransaction { initialBalance in
            var numChecksRemaining = 5
            func checkBalance() {
                numChecksRemaining -= 1
                print("Updating balance...")
                client.updateBalance {
                    guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balance: \(balance)")

                    do {
                        let balancePicoMob = try XCTUnwrap(balance.amountPicoMob())
                        let initialBalancePicoMob = try XCTUnwrap(initialBalance.amountPicoMob())
                        guard balancePicoMob != initialBalancePicoMob else {
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to receive a changed balance. initial balance: " +
                                    "\(initialBalancePicoMob), current balance: " +
                                    "\(balancePicoMob) picoMOB")
                                expect.fulfill()
                                return
                            }

                            Thread.sleep(forTimeInterval: 2)
                            checkBalance()
                            return
                        }
                    } catch {}
                    expect.fulfill()
                }
            }
            checkBalance()
        }
    }

    func testTransactionStatus() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionStatus(transportProtocol: $0, expectation: $1)
        }
    }
    
    func transactionStatus(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 1, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)


        func submitTransaction(callback: @escaping (Transaction) -> Void) {
            client.updateBalance {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                client.prepareTransaction(
                    to: recipient,
                    amount: 100,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    client.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }

                        callback(transaction)
                    }
                }
            }
        }

        submitTransaction { (transaction: Transaction) in
            var numChecksRemaining = 5

            func checkStatus() {
                numChecksRemaining -= 1
                print("Updating balance...")
                client.updateBalance {
                    guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balance: \(balance)")

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
                        case .failed:
                            XCTFail("Transaction status check: Transaction failed")
                        }
                        expect.fulfill()
                    }
                }
            }
            checkStatus()
        }
    }

    func testReceiptStatus() throws {
        let description = "Checking receipt status"
        try testSupportedProtocols(description: description) {
            try receiptStatus(transportProtocol: $0, expectation: $1)
        }
    }
    
    func receiptStatus(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, transportProtocol: transportProtocol)
        let receiverAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let receiverClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: receiverAccountKey,
            transportProtocol: transportProtocol)


        func submitTransaction(callback: @escaping (Receipt) -> Void) {
            senderClient.updateBalance {
                guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                print("Account 0 balance: \(balance)")

                senderClient.prepareTransaction(
                    to: receiverAccountKey.publicAddress,
                    amount: 100,
                    fee: IntegrationTestFixtures.fee
                ) {
                    guard let (transaction, receipt) = $0.successOrFulfill(expectation: expect)
                    else { return }

                    senderClient.submitTransaction(transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }

                        callback(receipt)
                    }
                }
            }
        }

        submitTransaction { (receipt: Receipt) in
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
                            XCTFail("Failed to resolve receipt status check")
                            expect.fulfill()
                            return
                        }

                        Thread.sleep(forTimeInterval: 2)
                        checkStatus()
                        return
                    case .received(block: let block):
                        print("Block index: \(block.index)")
                        XCTAssertGreaterThan(block.index, 0)

                        if let timestamp = block.timestamp {
                            print("Block timestamp: \(timestamp)")
                        }
                    case .failed:
                        XCTFail("Receipt status check: Transaction failed")
                    }
                    expect.fulfill()
                }
            }
            checkStatus()
        }
    }

    func testConsensusTrustRootWorks() throws {
        let description = "Submitting transaction"
        try testSupportedProtocols(description: description) {
            try consensusTrustRootWorks(transportProtocol: $0, expectation: $1)
        }
    }
    
    func consensusTrustRootWorks(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(
            config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()))
        let client = try IntegrationTestFixtures.createMobileCoinClient(config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            guard let picoMob = try? XCTUnwrap(balance.amountPicoMob()) else
            { expect.fulfill(); return }
            print("balance: \(picoMob)")
            XCTAssertGreaterThan(picoMob, 0)
            guard picoMob > 0 else { expect.fulfill(); return }

            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

    func testExtraConsensusTrustRootWorks() throws {
        let description = "Submitting transaction"
        try testSupportedProtocols(description: description) {
            try extraConsensusTrustRootWorks(transportProtocol: $0, expect: $1)
        }
    }
    
    func extraConsensusTrustRootWorks(transportProtocol: TransportProtocol, expect: XCTestExpectation) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()
            + [try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 1, config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            guard let picoMob = try? XCTUnwrap(balance.amountPicoMob()) else
            { expect.fulfill(); return }
            print("balance: \(picoMob)")
            XCTAssertGreaterThan(picoMob, 0)
            guard picoMob > 0 else { expect.fulfill(); return }

            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

    func testWrongConsensusTrustRootReturnsError() throws {
        // Skipped because gRPC currently keeps retrying connection errors indefinitely.
        try XCTSkipIf(true)

        let description = "Submitting transaction"
        try testSupportedProtocols(description: description) {
            try wrongConsensusTrustRootReturnsError(transportProtocol: $0, expectation: $1)
        }
    }
    
    func wrongConsensusTrustRootReturnsError(transportProtocol: TransportProtocol, expectation expect: XCTestExpectation) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots([
            try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes,
        ]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            guard let picoMob = try? XCTUnwrap(balance.amountPicoMob()) else
            { expect.fulfill(); return }
            print("balance: \(picoMob)")
            XCTAssertGreaterThan(picoMob, 0)
            guard picoMob > 0 else { expect.fulfill(); return }

            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                print("Submitting transaction...")
                client.submitTransaction(transaction) {
                    XCTAssertFailure($0)
                    expect.fulfill()
                }
            }
        }
    }

}
