//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable type_body_length

import MobileCoin
import XCTest

class MobileCoinClientPublicApiIntTests: XCTestCase {

    func testBalance() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try balance(transportProtocol: transportProtocol)
        }
    }

    func balance(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

        let expect = expectation(description: "Updating account balance")
        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testAccountActivity() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try accountActivity(transportProtocol: transportProtocol)
        }
    }
    
    func accountActivity(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)

        let expect = expectation(description: "Updating account balance")
        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            let accountActivity = client.accountActivity

            print("txOuts.count: \(accountActivity.txOuts.count)")
            XCTAssertGreaterThan(accountActivity.txOuts.count, 0)

            print("blockCount: \(accountActivity.blockCount)")
            XCTAssertGreaterThan(accountActivity.blockCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testUpdateBalance() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try updateBalance(transportProtocol: transportProtocol)
        }
    }
    
    func updateBalance(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Updating account balance")
        try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol).updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }

            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testPrepareTransaction() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try prepareTransaction(transportProtocol: transportProtocol)
        }
    }
    
    func prepareTransaction(transportProtocol: TransportProtocol) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Preparing transaction")
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
        waitForExpectations(timeout: 20)
    }

    func testSubmitTransaction() throws {
        let supportedProtocols = TransportProtocol.supportedProtocols
        try supportedProtocols.enumerated().forEach { (index, transportProtocol) in
            let expect = expectation(description: "Submitting transaction")
            try submitTransaction(transportProtocol: transportProtocol, expectation: expect)
            waitForExpectations(timeout: 20)
            
            if index != (supportedProtocols.count - 1) {
                sleep(10)
            }
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
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try selfPaymentBalanceChange(transportProtocol: transportProtocol)
        }
    }
    
    func selfPaymentBalanceChange(transportProtocol: TransportProtocol) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        let expect = expectation(description: "Self payment")
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
        waitForExpectations(timeout: 20)
    }

    func testSelfPaymentBalanceChangeFeeLevel() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try selfPaymentBalanceChangeFeeLevel(transportProtocol: transportProtocol)
        }
    }
    
    func selfPaymentBalanceChangeFeeLevel(transportProtocol: TransportProtocol) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)

        let expect = expectation(description: "Self payment")
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
        waitForExpectations(timeout: 20)
    }

    func testTransactionStatus() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try transactionStatus(transportProtocol: transportProtocol)
        }
    }
    
    func transactionStatus(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 1, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        let expect = expectation(description: "Checking transaction status")

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
        waitForExpectations(timeout: 20)
    }

    func testReceiptStatus() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try receiptStatus(transportProtocol: transportProtocol)
        }
    }
    
    func receiptStatus(transportProtocol: TransportProtocol) throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, transportProtocol: transportProtocol)
        let receiverAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let receiverClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: receiverAccountKey,
            transportProtocol: transportProtocol)

        let expect = expectation(description: "Checking receipt status")

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
        waitForExpectations(timeout: 40)
    }

    func testConsensusTrustRootWorks() throws {
        let supportedProtocols = TransportProtocol.supportedProtocols
        let onlyHTTPSupported = supportedProtocols.count == 1 && supportedProtocols.contains(where: {$0 == TransportProtocol.http})
        try XCTSkipIf(onlyHTTPSupported)
        try supportedProtocols.filter({$0 != TransportProtocol.http}).forEach { transportProtocol in
            try consensusTrustRootWorks(transportProtocol: transportProtocol)
        }
    }
    
    func consensusTrustRootWorks(transportProtocol: TransportProtocol) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(
            config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()))
        let client = try IntegrationTestFixtures.createMobileCoinClient(config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        let expect = expectation(description: "Submitting transaction")
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
        waitForExpectations(timeout: 20)
    }

    func testExtraConsensusTrustRootWorks() throws {
        let supportedProtocols = TransportProtocol.supportedProtocols
        let onlyHTTPSupported = supportedProtocols.count == 1 && supportedProtocols.contains(where: {$0 == TransportProtocol.http})
        try XCTSkipIf(onlyHTTPSupported)
        try supportedProtocols.filter({$0 != TransportProtocol.http}).forEach { transportProtocol in
            try extraConsensusTrustRootWorks(transportProtocol: transportProtocol)
        }
    }
    
    func extraConsensusTrustRootWorks(transportProtocol: TransportProtocol) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()
            + [try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 1, config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Submitting transaction")
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
        waitForExpectations(timeout: 20)
    }

    func testWrongConsensusTrustRootReturnsError() throws {
        let supportedProtocols = TransportProtocol.supportedProtocols
        let onlyHTTPSupported = supportedProtocols.count == 1 && supportedProtocols.contains(where: {$0 == TransportProtocol.http})
        try XCTSkipIf(onlyHTTPSupported)
        try supportedProtocols.filter({$0 != TransportProtocol.http}).forEach { transportProtocol in
            try wrongConsensusTrustRootReturnsError(transportProtocol: transportProtocol)
        }
    }
    
    func wrongConsensusTrustRootReturnsError(transportProtocol: TransportProtocol) throws {
        // Skipped because gRPC currently keeps retrying connection errors indefinitely.
        try XCTSkipIf(true)

        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(transportProtocol:transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots([
            try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes,
        ]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(accountIndex: 0, config: config, transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        let expect = expectation(description: "Submitting transaction")
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
        waitForExpectations(timeout: 20)
    }

}
