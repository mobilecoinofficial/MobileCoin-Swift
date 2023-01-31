//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length

@testable import MobileCoin
import XCTest

class MobileCoinClientPublicApiIntTests: XCTestCase {

    func testBalance() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try balance(transportProtocol: $0, expectation: $1)
        }
    }

    func balance(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

        client.updateBalance {
            guard $0.successOrFulfill(expectation: expect) != nil else { return }

            if let amountPicoMob = try? XCTUnwrap(client.balance.amountPicoMob()) {
                print("balance: \(amountPicoMob)")
                XCTAssertGreaterThan(amountPicoMob, 0)
            }

            expect.fulfill()
        }
    }

    func testPrintBalances() throws {
        let description = "Printing account balance"
        try testSupportedProtocols(description: description) {
            try printBalance(transportProtocol: $0, expectation: $1)
        }
    }

    func printBalance(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let numAccounts = IntegrationTestFixtures.testAccountCount
        let serialQueue = DispatchQueue(label: "com.mobilecoin.printBalances")

        func completion(_ result: Result<[Balance], ConnectionError>) {
            guard let balances = try? XCTUnwrapSuccess(result) else {
                return
            }

            balances.enumerated().forEach({ index, balance in
                guard let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) else {
                    return
                }
                print("account index \(index) balance: \(amountPicoMob)")
            })
        }

        [0, 1, 2, 3, 4, 5].mapAsync({ index, callback in
            guard
                let key = try? IntegrationTestFixtures.createAccountKey(accountIndex: index)
            else {
                return
            }

            guard let client = try? IntegrationTestFixtures.createMobileCoinClient(
                accountKey: key,
                transportProtocol: transportProtocol
            ) else {
                return
            }

            client.updateBalance(completion: callback)
        },
        serialQueue: serialQueue,
        completion: { result in
            completion(result.map { $0.compactMap { $0 } })
            expect.fulfill()
        })

    }

    func testBalances() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try balances(transportProtocol: $0, expectation: $1)
        }
    }

    func balances(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountIndex: 0,
            using: transportProtocol)

        client.blockVersion {
            guard let blockVersion = try? $0.get(), blockVersion >= 2 else {
                print("Test cannot run on blockversion < 2 ... " +
                      "fulfilling the expectation as a success")
                expect.fulfill()
                return
            }

            client.updateBalances {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                let balances = client.balances
                print(balances)

                XCTAssertGreaterThan(balances.balances.count, 1)

                print(client.accountActivity.describeUnspentTxOuts())

                guard let mobBalance = balances.balances[.MOB] else {
                    XCTFail("Expected Balance")
                    return
                }

                XCTAssertTrue(
                    mobBalance.amountParts.int > 0 ||
                    mobBalance.amountParts.frac > 0
                )

                guard let mobUSDBalance = balances.balances[.MOB] else {
                    XCTFail("Expected Balance")
                    return
                }

                XCTAssertTrue(
                    mobUSDBalance.amountParts.int > 0 ||
                    mobUSDBalance.amountParts.frac > 0
                )

                let unknownTokenId = TokenId(UInt64(17000))
                XCTAssertNil(balances.balances[unknownTokenId])

                expect.fulfill()
            }
        }
    }

    func testAccountActivity() throws {
        let description = "Updating account balance"
        try testSupportedProtocols(description: description) {
            try accountActivity(transportProtocol: $0, expectation: $1)
        }
    }

    func accountActivity(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

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

    func updateBalance(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol).updateBalance {
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

    func prepareTransaction(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol)
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

    func submitTransaction(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

    func defragmentationTesting(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {

        func fragmentAccount(with index: Int) {

        }

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol)
        { client in
            client.prepareTransaction(
                to: recipient,
                amount: 100,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")
                    expect.fulfill()
                }
            }
        }
    }

    func testSubmitMobUSDTransaction() throws {
        let description = "Submitting transaction"
        try testSupportedProtocols(description: description) {
            try submitMobUSDTransaction(transportProtocol: $0, expectation: $1)
        }
    }

    func submitMobUSDTransaction(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let amount = Amount(100, in: .MOBUSD)

        func checkBlockVersionAndFee(
                _ client: MobileCoinClient,
                _ expect: XCTestExpectation,
                _ completion: @escaping (UInt64) -> Void
        ) {

            client.blockVersion {
                guard let blockVersion = try? $0.get(), blockVersion >= 2 else {
                    print("Test cannot run on blockversion < 2 ... " +
                          "fulfilling the expectation as a success")
                    expect.fulfill()
                    return
                }

                client.estimateTotalFee(toSendAmount: amount, feeLevel: .minimum) { estimatedFee in
                    guard let fee = estimatedFee.successOrFulfill(expectation: expect)
                    else { return }

                    completion(fee)
                }
            }
        }

        func prepareAndSubmit(
                _ client: MobileCoinClient,
                _ expect: XCTestExpectation,
                _ fee: UInt64,
                _ completion: @escaping () -> Void
        ) {

            client.prepareTransaction(
                to: recipient,
                amount: amount,
                fee: fee
            ) {
                guard let pendingTransaction = $0.successOrFulfill(expectation: expect)
                else { return }

                let publicKey = pendingTransaction.changeTxOutContext.txOutPublicKey
                XCTAssertNotNil(publicKey)

                let sharedSecret = pendingTransaction.changeTxOutContext.sharedSecretBytes
                XCTAssertNotNil(sharedSecret)

                let transaction = pendingTransaction.transaction
                print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

                client.submitTransaction(transaction) {
                    guard $0.successOrFulfill(expectation: expect) != nil else { return }

                    print("Transaction submission successful")

                    completion()
                }
            }
        }

        func checkBalances(
                _ client: MobileCoinClient,
                _ expect: XCTestExpectation,
                _ completion: @escaping (Balances) -> Void
        ) {

            client.updateBalances {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                let balances = client.balances
                print(balances)

                XCTAssertGreaterThan(balances.balances.count, 1)

                print(client.accountActivity.describeUnspentTxOuts())

                guard let mobBalance = balances.balances[.MOB] else {
                    XCTFail("Expected Balance")
                    return
                }

                XCTAssertTrue(
                    mobBalance.amountParts.int > 0 ||
                    mobBalance.amountParts.frac > 0
                )

                guard let mobUSDBalance = balances.balances[.MOBUSD] else {
                    XCTFail("Expected Balance")
                    return
                }

                XCTAssertTrue(
                    mobUSDBalance.amountParts.int > 0 ||
                    mobUSDBalance.amountParts.frac > 0
                )

                let unknownTokenId = TokenId(UInt64(17000))
                XCTAssertNil(balances.balances[unknownTokenId])

                completion(balances)
            }
        }

        func verifyBalanceChange(
                _ client: MobileCoinClient,
                _ balancesBefore: Balances,
                _ expect: XCTestExpectation
                ) {

            var numChecksRemaining = 5
            func checkBalanceChange() {
                numChecksRemaining -= 1
                print("Updating balance...")
                client.updateBalances {
                    guard let balances = $0.successOrFulfill(expectation: expect) else { return }
                    print("Balances: \(balances)")

                    do {
                        let balancesMap = balances.balances
                        let balancesBeforeMap = balancesBefore.balances
                        let mobUSD = try XCTUnwrap(balancesMap[.MOBUSD]?.amount())
                        let initialMobUSD = try XCTUnwrap(balancesBeforeMap[.MOBUSD]?.amount())

                        guard mobUSD != initialMobUSD else {
                            guard numChecksRemaining > 0 else {
                                XCTFail("Failed to receive a changed balance. initial balance: " +
                                    "\(initialMobUSD), current balance: " +
                                    "\(mobUSD) microMOBUSD")
                                expect.fulfill()
                                return
                            }

                            Thread.sleep(forTimeInterval: 2)
                            checkBalanceChange()
                            return
                        }
                    } catch {}
                    expect.fulfill()
                }
            }
            checkBalanceChange()
        }

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol) { client in
            checkBlockVersionAndFee(client, expect) { fee in
                checkBalances(client, expect) { balancesBefore in
                    prepareAndSubmit(client, expect, fee) {
                        verifyBalanceChange(client, balancesBefore, expect)
                    }
                }
            }
        }
    }

    func testRecoverTransactions() throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.hasRecoverableTestTransactions)

        let description = "Recovering transactions"
        try testSupportedProtocols(description: description) {
            try recoverTransaction(transportProtocol: $0, expectation: $1)
        }
    }

    func recoverTransaction(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let publicAddress = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let contact = Contact(
            name: "Account Index 1",
            username: "one",
            publicAddress: publicAddress)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                expectation: expect,
                transportProtocol: transportProtocol)
        { client in
            let historicalTransacitions = client.recoverTransactions(contacts: Set([contact]))
            guard !historicalTransacitions.isEmpty else {
                XCTFail("Expected some historical transactions on testNet")
                return
            }

            let recovered = historicalTransacitions.filter({ $0.contact != nil })
            guard !recovered.isEmpty else {
                XCTFail("Expected some recovered transactions on testNet")
                return
            }

            // Test for presence of each RTH memo type
            var destinationWithPaymentIntent = false
            var destinationWithPaymentRequest = false
            var destination = false
            var senderWithPaymentIntent = false
            var senderWithPaymentRequest = false
            var sender = false

            recovered.forEach({
                switch $0.memo {
                case .destinationWithPaymentIntent(let memo):
                    guard
                        memo.fee > 0,
                        memo.numberOfRecipients > 0,
                        memo.paymentIntentId > 0,
                        memo.totalOutlay > 0
                    else {
                        return
                    }
                    destinationWithPaymentIntent = true
                case .destinationWithPaymentRequest(let memo):
                    guard
                        memo.fee > 0,
                        memo.numberOfRecipients > 0,
                        memo.paymentRequestId > 0,
                        memo.totalOutlay > 0
                    else {
                        return
                    }
                    destinationWithPaymentRequest = true
                case .senderWithPaymentIntent(let memo):
                    guard memo.paymentIntentId > 0 else { return }
                    senderWithPaymentIntent = true
                case .senderWithPaymentRequest(let memo):
                    guard memo.paymentRequestId > 0 else { return }
                    senderWithPaymentRequest = true
                case .sender:
                    sender = true
                case .destination(let memo):
                    guard
                        memo.fee > 0,
                        memo.numberOfRecipients > 0,
                        memo.totalOutlay > 0
                    else {
                        return
                    }
                    destination = true
                case .none:
                    return
                }
            })

            guard
                sender,
                destination,
                destinationWithPaymentIntent,
                destinationWithPaymentRequest,
                senderWithPaymentIntent,
                senderWithPaymentRequest
            else {
                XCTFail("Expected all recovered transaction types on testNet")
                return
            }

            expect.fulfill()
        }
    }

    func testSelfPaymentBalanceChange() throws {
        let description = "Self payment"
        try testSupportedProtocols(description: description) {
            try selfPaymentBalanceChange(transportProtocol: $0, expectation: $1)
        }
    }

    func selfPaymentBalanceChange(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountKey: accountKey,
                transportProtocol: transportProtocol)

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

    func selfPaymentBalanceChangeFeeLevel(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountKey: accountKey,
                transportProtocol: transportProtocol)

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

    func transactionStatus(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 1,
                using: transportProtocol)
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

    func testTransactionTxOutStatus() throws {
        let description = "Checking transaction status"
        try testSupportedProtocols(description: description) {
            try transactionTxOutStatus(transportProtocol: $0, expectation: $1)
        }
    }

    func transactionTxOutStatus(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 1,
                using: transportProtocol)
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
                    client.txOutStatus(of: transaction) {
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

    func receiptStatus(
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

    func consensusTrustRootWorks(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(
                using: transportProtocol)
        XCTAssertSuccess(
            config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()))
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                config: config,
                transportProtocol: transportProtocol)
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

    func extraConsensusTrustRootWorks(
        transportProtocol: TransportProtocol,
        expect: XCTestExpectation
    ) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(
                using: transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()
            + [try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(
                    accountIndex: 1,
                    config: config,
                    transportProtocol: transportProtocol)
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

    func wrongConsensusTrustRootReturnsError(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(
                using: transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots([
            try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes,
        ]))
        let client =
            try IntegrationTestFixtures.createMobileCoinClient(
                    accountIndex: 0,
                    config: config,
                    transportProtocol: transportProtocol)
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

extension AccountActivity {
    public func describeUnspentTxOuts() -> String {
        [
            self.txOuts.filter { $0.spentBlock == nil }.map {
                "Unspent TxOut \($0.value) \($0.tokenId.name)"
            },
        ]
        .flatMap({ $0 })
        .joined(separator: ", \n")
    }
}
