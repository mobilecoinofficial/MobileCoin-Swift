//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import MobileCoin
import XCTest

@available(iOS 13.0, *)
class MobileCoinClientPublicAsyncApiIntTests: XCTestCase {

    func testBalance() async throws {
        try await testSupportedProtocols {
            try await self.balance(transportProtocol: $0)
        }
    }

    func balance(
        transportProtocol: TransportProtocol
    ) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)
        try await client.updateBalances()
        if let amountPicoMob = try? XCTUnwrap(client.balance(for: .MOB).amount()) {
            print("balance: \(amountPicoMob)")
            XCTAssertGreaterThan(amountPicoMob, 0)
        }
    }

    func testPrintBalances() async throws {
        try await testSupportedProtocols {
            try await self.printBalance(transportProtocol: $0)
        }
    }

    func printBalance(
        transportProtocol: TransportProtocol
    ) async throws {
        for index in Array(0...9) {
            let key = try IntegrationTestFixtures.createAccountKey(accountIndex: index)

            let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountKey: key,
                transportProtocol: transportProtocol)

            try await client.updateBalances()

            if let amountPicoMob = try? XCTUnwrap(client.balance(for: .MOB).amount()) {
                print("account index \(index) public address \(key.publicAddress)")
                print("account index \(index) balance: \(amountPicoMob)")
            }
        }
    }

    func testBalances() async throws {
        try await testSupportedProtocols {
            try await self.balances(transportProtocol: $0)
        }
    }

    func balances(
        transportProtocol: TransportProtocol
    ) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountIndex: 0,
            using: transportProtocol)

        let blockVersion = try await client.blockVersion()
        guard blockVersion >= 2 else {
            print("Test cannot run on blockversion < 2 ... " +
                  "fulfilling the expectation as a success")
            return
        }

        try await client.updateBalances()

        let balances = client.balances
        print(balances)

        XCTAssertGreaterThanOrEqual(balances.balances.count, 1)

        print(client.accountActivity(for: .MOB).describeUnspentTxOuts())

        guard let mobBalance = balances.balances[.MOB] else {
            XCTFail("Expected Balance")
            return
        }

        XCTAssertTrue(
            mobBalance.amountParts.int > 0 ||
            mobBalance.amountParts.frac > 0
        )
    }

    func testAccountActivity() async throws {
        try await testSupportedProtocols {
            try await self.accountActivity(transportProtocol: $0)
        }
    }

    func accountActivity(
        transportProtocol: TransportProtocol
    ) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

        try await client.updateBalances()

        let accountActivity = client.accountActivity(for: .MOB)

        print("txOuts.count: \(accountActivity.txOuts.count)")
        XCTAssertGreaterThan(accountActivity.txOuts.count, 0)

        print("blockCount: \(accountActivity.blockCount)")
        XCTAssertGreaterThan(accountActivity.blockCount, 0)
    }

    func testUpdateBalance() async throws {
        try await testSupportedProtocols {
            try await self.updateBalance(transportProtocol: $0)
        }
    }

    func updateBalance(
        transportProtocol: TransportProtocol
    ) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)
        let balance = try await client.updateBalances().mobBalance

        if let amountPicoMob = try? XCTUnwrap(balance.amount()) {
            print("balance: \(amountPicoMob)")
            XCTAssertGreaterThan(amountPicoMob, 0)
        }
    }

    func testPrepareTransaction() async throws {
        try await testSupportedProtocols {
            try await self.prepareTransaction(transportProtocol: $0)
        }
    }

    func prepareTransaction(
        transportProtocol: TransportProtocol
    ) async throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )
        _ = try await client.prepareTransaction(to: recipient,
                                                amount: Amount(100, in: .MOB),
                                                fee: IntegrationTestFixtures.fee)
    }

    func testSubmitTransaction() async throws {
        try await testSupportedProtocols {
            try await self.submitTransaction(transportProtocol: $0)
        }
    }

    func submitTransaction(
        transportProtocol: TransportProtocol
    ) async throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)
        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 0)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )
        let transaction = try await client.prepareTransaction(to: recipient,
                                                              amount: Amount(100, in: .MOB),
                                                              fee: IntegrationTestFixtures.fee)
        try await client.submitTransaction(transaction: transaction.transaction)
    }

    func testSubmitMobUSDTransaction() async throws {
        try await testSupportedProtocols {
            try await self.submitMobUSDTransaction(transportProtocol: $0)
        }
    }

    func submitMobUSDTransaction(
        transportProtocol: TransportProtocol
    ) async throws {
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let amount = Amount(100, in: .MOBUSD)

        func checkBlockVersionAndFee(
            _ client: MobileCoinClient
        ) async throws -> UInt64 {
            let blockVersion = try await client.blockVersion()
            XCTAssertGreaterThanOrEqual(blockVersion, 2, "Test cannot run on blockversion < 2 ...")
            return try await client.estimateTotalFee(toSendAmount: amount, feeLevel: .minimum)
        }

        func prepareAndSubmit(
            _ client: MobileCoinClient,
            _ fee: UInt64
        ) async throws {
            let pendingTransaction = try await client.prepareTransaction(to: recipient,
                                                                         amount: amount,
                                                                         fee: fee)

            let publicKey = pendingTransaction.changeTxOutContext.txOutPublicKey
            XCTAssertNotNil(publicKey)

            let sharedSecret = pendingTransaction.changeTxOutContext.sharedSecretBytes
            XCTAssertNotNil(sharedSecret)

            let transaction = pendingTransaction.transaction
            print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

            try await client.submitTransaction(transaction: transaction)
        }

        func checkBalances(
            _ client: MobileCoinClient
        ) async throws -> Balances {
            try await client.updateBalances()

            let balances = client.balances
            print(balances)

            XCTAssertGreaterThan(balances.balances.count, 1)

            print(client.accountActivity(for: .MOB).describeUnspentTxOuts())

            let mobBalance = try XCTUnwrap(balances.balances[.MOB], "Expected Balance")
            XCTAssertTrue(
                mobBalance.amountParts.int > 0 ||
                mobBalance.amountParts.frac > 0
            )

            let mobUSDBalance = try XCTUnwrap(balances.balances[.MOBUSD], "Expected Balance")
            XCTAssertTrue(
                mobUSDBalance.amountParts.int > 0 ||
                mobUSDBalance.amountParts.frac > 0
            )

            let unknownTokenId = TokenId(UInt64(17000))
            XCTAssertNil(balances.balances[unknownTokenId])

            return balances
        }

        func verifyBalanceChange(
            _ client: MobileCoinClient,
            _ balancesBefore: Balances
        ) async throws {

            var numChecksRemaining = 5
            func checkBalanceChange() async throws {
                numChecksRemaining -= 1
                print("Updating balance...")
                let balances = try await client.updateBalances()
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
                            return
                        }

                        try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                        try await checkBalanceChange()
                        return
                    }
                } catch {}
            }
            try await checkBalanceChange()
        }

        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 0)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )
        let fee = try await checkBlockVersionAndFee(client)
        let balancesBefore = try await checkBalances(client)
        try await prepareAndSubmit(client, fee)
        try await verifyBalanceChange(client, balancesBefore)
    }

    func testSelfPaymentBalanceChange() async throws {
        try await testSupportedProtocols {
            try await self.selfPaymentBalanceChange(transportProtocol: $0)
        }
    }

    func selfPaymentBalanceChange(
        transportProtocol: TransportProtocol
    ) async throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 2)
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: accountKey,
            transportProtocol: transportProtocol)

        func submitTransaction() async throws -> Balance {
            let balance = try await client.updateBalances().mobBalance
            print("Initial balance: \(balance)")

            let transaction = try await client.prepareTransaction(
                to: accountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return balance
        }

        let initialBalance = try await submitTransaction()

        var numChecksRemaining = 5
        func checkBalance() async throws {
            numChecksRemaining -= 1
            print("Updating balance...")
            let balance = try await client.updateBalances().mobBalance
            print("Balance: \(balance)")

            do {
                let balancePicoMob = try XCTUnwrap(balance.amount())
                let initialBalancePicoMob = try XCTUnwrap(initialBalance.amount())
                let expectedBalancePicoMob =
                initialBalancePicoMob - IntegrationTestFixtures.fee
                guard balancePicoMob == expectedBalancePicoMob else {
                    guard numChecksRemaining > 0 else {
                        XCTFail("Failed to receive a changed balance. balance: " +
                                "\(balancePicoMob), expected balance: " +
                                "\(expectedBalancePicoMob) picoMOB")
                        return
                    }

                    try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                    try await checkBalance()
                    return
                }
            } catch {}
        }
        try await checkBalance()
    }

    func testSelfPaymentBalanceChangeFeeLevel() async throws {
        try await testSupportedProtocols {
            try await self.selfPaymentBalanceChangeFeeLevel(transportProtocol: $0)
        }
    }

    func selfPaymentBalanceChangeFeeLevel(
        transportProtocol: TransportProtocol
    ) async throws {
        let accountKey = try  IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: accountKey,
            transportProtocol: transportProtocol)

        func submitTransaction() async throws -> Balance {
            let balance = try await client.updateBalances().mobBalance
            print("Initial balance: \(balance)")
            let transaction = try await client.prepareTransaction(
                to: accountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return balance
        }

        let initialBalance = try await submitTransaction()
        var numChecksRemaining = 5
        func checkBalance() async throws {
            numChecksRemaining -= 1
            print("Updating balance...")
            let balance = try await client.updateBalances().mobBalance
            print("Balance: \(balance)")

            do {
                let balancePicoMob = try XCTUnwrap(balance.amount())
                let initialBalancePicoMob = try XCTUnwrap(initialBalance.amount())
                guard balancePicoMob != initialBalancePicoMob else {
                    guard numChecksRemaining > 0 else {
                        XCTFail("Failed to receive a changed balance. initial balance: " +
                                "\(initialBalancePicoMob), current balance: " +
                                "\(balancePicoMob) picoMOB")
                        return
                    }

                    try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                    try await checkBalance()
                    return
                }
            } catch {}
        }
        try await checkBalance()
    }

    func testTransactionStatus() async throws {
        try await testSupportedProtocols {
            try await self.transactionStatus(transportProtocol: $0)
        }
    }

    func transactionStatus(
        transportProtocol: TransportProtocol
    ) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountIndex: 1,
            using: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        func submitTransaction() async throws -> Transaction {
            try await client.updateBalances()
            let transaction = try await client.prepareTransaction(to: recipient,
                                                                  amount: Amount(100, in: .MOB),
                                                                  fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return transaction.transaction
        }

        let transaction = try await submitTransaction()

        var numChecksRemaining = 5

        func checkStatus() async throws {
            numChecksRemaining -= 1
            print("Updating balance...")
            let balance = try await client.updateBalances().mobBalance
            print("Balance: \(balance)")

            print("Checking status...")
            let status = try await client.status(of: transaction)
            print("Transaction status: \(status)")

            switch status {
            case .unknown:
                guard numChecksRemaining > 0 else {
                    XCTFail("Failed to resolve transaction status check")
                    return
                }

                try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                try await checkStatus()
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
        }
        try await checkStatus()
    }

    func testReceiptStatus() async throws {
        try await testSupportedProtocols {
            try await self.receiptStatus(transportProtocol: $0)
        }
    }

    func receiptStatus(
        transportProtocol: TransportProtocol
    ) async throws {
        let senderClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountIndex: 0,
            using: transportProtocol)
        let receiverAccountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 1)
        let receiverClient = try IntegrationTestFixtures.createMobileCoinClient(
            accountKey: receiverAccountKey,
            transportProtocol: transportProtocol)

        func submitTransaction() async throws -> Receipt {
            let balance = try await senderClient.updateBalances().mobBalance
            print("Account 0 balance: \(balance)")
            let transaction = try await senderClient.prepareTransaction(
                to: receiverAccountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await senderClient.submitTransaction(transaction: transaction.transaction)
            return transaction.receipt
        }

        let receipt = try await submitTransaction()
        var numChecksRemaining = 5

        func checkStatus() async throws {
            numChecksRemaining -= 1
            print("Checking status...")
            let balance = try await receiverClient.updateBalances().mobBalance
            print("Account 1 balance: \(balance)")

            guard let status = receiverClient.status(of: receipt)
                .successOrFulfill() else { return }
            print("Receipt status: \(status)")

            switch status {
            case .unknown:
                guard numChecksRemaining > 0 else {
                    XCTFail("Failed to resolve receipt status check")
                    return
                }

                try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                try await checkStatus()
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
        }
        try await checkStatus()
    }

    func testConsensusTrustRootWorks() async throws {
        try await testSupportedProtocols {
            try await self.consensusTrustRootWorks(transportProtocol: $0)
        }
    }

    func consensusTrustRootWorks(
        transportProtocol: TransportProtocol
    ) async throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(
            using: transportProtocol)
        XCTAssertSuccess(
            config.setConsensusTrustRoots(try NetworkPreset.trustRootsBytes()))
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            config: config,
            transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)

        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(100, in: .MOB),
            fee: IntegrationTestFixtures.fee
        )
        try await client.submitTransaction(transaction: transaction.transaction)
    }

    func testExtraConsensusTrustRootWorks() async throws {
        try await testSupportedProtocols {
            try await self.extraConsensusTrustRootWorks(transportProtocol: $0)
        }
    }

    func extraConsensusTrustRootWorks(
        transportProtocol: TransportProtocol
    ) async throws {
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
        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(100, in: .MOB),
            fee: IntegrationTestFixtures.fee)
        try await client.submitTransaction(transaction: transaction.transaction)
    }

    func testWrongConsensusTrustRootReturnsError() async throws {
        // Skipped because gRPC currently keeps retrying connection errors indefinitely.
        try XCTSkipIf(true)

        try await testSupportedProtocols {
            try await self.wrongConsensusTrustRootReturnsError(transportProtocol: $0)
        }
    }

    func wrongConsensusTrustRootReturnsError(
        transportProtocol: TransportProtocol
    ) async throws {
        var config = try IntegrationTestFixtures.createMobileCoinClientConfig(
            using: transportProtocol)
        XCTAssertSuccess(config.setConsensusTrustRoots([
            try MobileCoinClient.Config.Fixtures.Init().wrongTrustRootBytes,
        ]))
        let client = try IntegrationTestFixtures.createMobileCoinClient(
            accountIndex: 0,
            config: config,
            transportProtocol: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)
        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(100, in: .MOB),
            fee: IntegrationTestFixtures.fee)
        try await client.submitTransaction(transaction: transaction.transaction)
    }

}
