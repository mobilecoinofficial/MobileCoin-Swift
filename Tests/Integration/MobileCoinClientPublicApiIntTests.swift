//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable superfluous_disable_command
// swiftlint:disable type_body_length
// swiftlint:disable file_length
// swiftlint:disable empty_xctest_method

import MobileCoin
import XCTest

#if swift(>=5.5)

@available(iOS 15.0, *)
class MobileCoinClientPublicApiIntTests: XCTestCase {

    func testBalance() async throws {
        try XCTSkip()
        let description = "Updating account balance"
        try await testSupportedProtocols(description: description) {
            try await self.balance(transportProtocol: $0)
        }
    }

    func balance(transportProtocol: TransportProtocol) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)
        try await client.updateBalances()
        if let amountPicoMob = try? XCTUnwrap(client.balance(for: .MOB).amount()) {
            print("balance: \(amountPicoMob)")
            XCTAssertGreaterThan(amountPicoMob, 0)
        }
    }

    func testBalances() async throws {
        try XCTSkip()
        let description = "Updating account balances"
        try await testSupportedProtocols(description: description) {
            try await self.balances(transportProtocol: $0)
        }
    }

    func balances(transportProtocol: TransportProtocol) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

        let blockVersion = try await client.blockVersion()
        guard blockVersion >= 2 else {
            print("Test cannot run on blockversion < 2 ... " +
                  "returning with success without running test")
            return
        }

        try await client.updateBalances()
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
    }

    func testPrintBalances() async throws {
        try XCTSkip()
        let description = "Printing account balance"
        try await testSupportedProtocols(description: description) {
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

            print("account index \(index) public address \(key.publicAddress)")

            if let amtMob = try? XCTUnwrap(client.balance(for: .MOB)) {
                print("account index \(index) balance: \(amtMob)")
            }

            if let amtMobUSD = try? XCTUnwrap(client.balance(for: .MOBUSD)) {
                print("account index \(index) balance: \(amtMobUSD)")
            }

            if let amtTestToken = try? XCTUnwrap(client.balance(for: .TestToken)) {
                print("account index \(index) balance: \(amtTestToken)")
            }
        }
    }

    func testAccountActivity() async throws {
        let description = "Updating account balance"
        try await testSupportedProtocols(description: description) {
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
        let description = "Updating account balance"
        try await testSupportedProtocols(description: description) {
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
        let description = "Preparing transaction"
        try await testSupportedProtocols(description: description) {
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
        let description = "Submitting transaction"
        try await testSupportedProtocols(description: description) {
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
        let transaction = try await client.prepareTransaction(
            to: recipient,
            amount: Amount(100, in: .MOB),
            fee: IntegrationTestFixtures.fee)
        try await client.submitTransaction(transaction: transaction.transaction)
    }

    func testSubmitMobUSDTransaction() async throws {
        let description = "Submitting MobUSD Transaction"
        try await testSupportedProtocols(description: description) {
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

    func testCreateSignedContingentInput() async throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.hasSignedContingentInputs)

        let description = "Create signed contingent input"
        try await testSupportedProtocols(description: description) {
            try await self.createSignedContingentInput(transportProtocol: $0)
        }
    }

    func createSignedContingentInput(transportProtocol: TransportProtocol) async throws {
        let amountToSend = Amount(1, in: .MOB)
        let amountToReceive = Amount(10, in: .MOBUSD)

        let creatorIdx = 9
        let creatorPubAddress = try IntegrationTestFixtures.createPublicAddress(
            accountIndex: creatorIdx)

        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountIndex: creatorIdx,
                transportProtocol: transportProtocol)

        let sci = try await client.createSignedContingentInput(
                recipient: creatorPubAddress,
                amountToSend: amountToSend,
                amountToReceive: amountToReceive)
        XCTAssertNotNil(sci)
        XCTAssertTrue(sci.isValid)
    }

    func testCancelSignedContingentInput() async throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.hasSignedContingentInputs)

        let description = "Cancel SCI"
        try await testSupportedProtocols(description: description) {
            try await self.cancelSignedContingentInput(transportProtocol: $0)
        }
    }

    func prepareAndSubmitSignedContingentInput(
        _ creator: MobileCoinClient,
        _ creatorAddress: PublicAddress,
        _ consumer: MobileCoinClient,
        _ amountToSend: Amount,
        _ amountToReceive: Amount
    ) async throws {
        let sci = try await creator.createSignedContingentInput(
            recipient: creatorAddress,
            amountToSend: amountToSend,
            amountToReceive: amountToReceive)

        let pendingTransaction = try await consumer.prepareTransaction(presignedInput: sci)

        let publicKey = pendingTransaction.changeTxOutContext.txOutPublicKey
        XCTAssertNotNil(publicKey)

        let sharedSecret = pendingTransaction.changeTxOutContext.sharedSecretBytes
        XCTAssertNotNil(sharedSecret)

        let transaction = pendingTransaction.transaction
        print("transaction fixture: \(transaction.serializedData.hexEncodedString())")

        try await consumer.submitTransaction(transaction: transaction)
    }

    func cancelSignedContingentInput(transportProtocol: TransportProtocol) async throws {
        let amountToSend = Amount(100 + IntegrationTestFixtures.fee, in: .MOB)
        let amountToReceive = Amount(10, in: .TestToken)

        let creatorIdx = 4
        let creatorAddr = try IntegrationTestFixtures.createPublicAddress(accountIndex: creatorIdx)
        let creatorAcctKey = try IntegrationTestFixtures.createAccountKey(accountIndex: creatorIdx)
        let creator = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: creatorAcctKey,
            tokenId: .MOB,
            transportProtocol: transportProtocol
        )

        let consumerIdx = 5
        let consumerAcctKey =
            try IntegrationTestFixtures.createAccountKey(accountIndex: consumerIdx)
        let consumer = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: consumerAcctKey,
            tokenId: .TestToken,
            transportProtocol: transportProtocol
        )

        let sci = try await creator.createSignedContingentInput(
            recipient: creatorAddr,
            amountToSend: amountToSend,
            amountToReceive: amountToReceive)

        let cancelSciTx = try await creator.prepareCancelSignedContingentInputTransaction(
            signedContingentInput: sci,
            feeLevel: .minimum)

        try await creator.submitTransaction(transaction: cancelSciTx.transaction)

        // sleep 10s to allow transaction to resolve on chain
        try await Task.sleep(nanoseconds: UInt64(10 * 1_000_000_000))

        do {
            // this should fail
            try await prepareAndSubmitSignedContingentInput(
                creator,
                creatorAddr,
                consumer,
                amountToSend,
                amountToReceive)
            XCTFail("Signed Contingent Input submission should not succeed after cancelation")
        } catch {
            print("Attempt to consume SCI correctly failed with error \(error)")
        }
    }

    func testSubmitSignedContingentInputTransaction() async throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.hasSignedContingentInputs)

        let description = "Submitting SCI transaction"
        try await testSupportedProtocols(description: description) {
            try await self.submitSignedContingentInputTransaction(transportProtocol: $0)
        }
    }

    func submitSignedContingentInputTransaction(
        transportProtocol: TransportProtocol
    ) async throws {
        let amountToSend = Amount(100 + IntegrationTestFixtures.fee, in: .MOB)
        let amountToReceive = Amount(10, in: .TestToken)

        func checkBlockVersionAndFee(
            _ client: MobileCoinClient
        ) async throws -> UInt64 {
            let blockVersion = try await client.blockVersion()
            XCTAssertGreaterThanOrEqual(blockVersion, 3, "Test cannot run on blockversion < 3 ...")
            return try await client.estimateTotalFee(toSendAmount: amountToSend, feeLevel: .minimum)
        }

        func getBalances(
            _ client: MobileCoinClient
        ) async throws -> Balances {
            try await client.updateBalances()
            let balances = client.balances
            print(balances)
            return balances
        }

        func verifyBalanceChanges(
            _ client: MobileCoinClient,
            _ balancesBefore: Balances,
            _ amountOut: Amount,
            _ amountIn: Amount,
            _ fee: UInt64
        ) async throws {

            let outTokenId = amountOut.tokenId
            let inTokenId = amountIn.tokenId

            var numChecksRemaining = 5
            func checkBalanceChange() async throws {
                numChecksRemaining -= 1
                print("Updating balance...")
                let balances = try await client.updateBalances()
                print("Balances: \(balances)")

                do {
                    let balancesMap = balances.balances
                    let balancesBeforeMap = balancesBefore.balances

                    let outFinal = try XCTUnwrap(balancesMap[outTokenId]?.amount())
                    let outInitial = try XCTUnwrap(balancesBeforeMap[outTokenId]?.amount())

                    let inFinal = try XCTUnwrap(balancesMap[inTokenId]?.amount())
                    let inInitial = try XCTUnwrap(balancesBeforeMap[inTokenId]?.amount())

                    guard outInitial - outFinal == amountOut.value &&
                            inFinal - inInitial == amountIn.value - fee
                    else {
                        guard numChecksRemaining > 0 else {
                            XCTFail("Balances failed to correctly change. Initial balances: " +
                                    "\(outInitial), \(inInitial), Current balances: " +
                                    "\(outFinal), \(inFinal)")
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

        let creatorIdx = 4
        let creatorAddr = try IntegrationTestFixtures.createPublicAddress(accountIndex: creatorIdx)
        let creatorAcctKey = try IntegrationTestFixtures.createAccountKey(accountIndex: creatorIdx)
        let creator = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: creatorAcctKey,
            tokenId: .MOB,
            transportProtocol: transportProtocol
        )

        let consumerIdx = 5
        let consumerAcctKey =
            try IntegrationTestFixtures.createAccountKey(accountIndex: consumerIdx)
        let consumer = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: consumerAcctKey,
            tokenId: .TestToken,
            transportProtocol: transportProtocol
        )

        let fee = try await checkBlockVersionAndFee(creator)
        let creatorBalancesBefore = try await getBalances(creator)
        let consumerBalancesBefore = try await getBalances(consumer)
        try await prepareAndSubmitSignedContingentInput(
            creator,
            creatorAddr,
            consumer,
            amountToSend,
            amountToReceive)
        try await verifyBalanceChanges(
            creator,
            creatorBalancesBefore,
            amountToSend,
            amountToReceive,
            0)
        try await verifyBalanceChanges(
            consumer,
            consumerBalancesBefore,
            amountToReceive,
            amountToSend,
            fee)
    }

    func testSelfPaymentBalanceChange() async throws {
        let description = "Self payment"
        try await testSupportedProtocols(description: description) {
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
        let description = "Self payment"
        try await testSupportedProtocols(description: description) {
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
        let description = "Checking transaction status"
        try await testSupportedProtocols(description: description) {
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

    func testTransactionTxOutStatus() async throws {
        let description = "Checking transaction txOut status"
        try await testSupportedProtocols(description: description) {
            try await self.transactionTxOutStatus(transportProtocol: $0)
        }
    }

    func transactionTxOutStatus(
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
            let status = try await client.txOutStatus(of: transaction)
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
        let description = "Checking receipt status"
        try await testSupportedProtocols(description: description) {
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

    func testRecoverTransactions() async throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.hasRecoverableTestTransactions)

        let description = "Recovering transactions"
        try await testSupportedProtocols(description: description, timeout: 120) {
            try await self.recoverTransaction(transportProtocol: $0)
        }
    }

    func recoverTransaction(transportProtocol: TransportProtocol) async throws {

        func recoverTransactions(
            client: MobileCoinClient,
            contact: Contact,
            failOnNone: Bool = true
        ) -> [HistoricalTransaction] {

            let historicalTransacitions = client.recoverTransactions(contacts: Set([contact]))
            guard !historicalTransacitions.isEmpty else {
                if failOnNone {
                    XCTFail("Expected some historical transactions")
                }
                return []
            }

            let recovered = historicalTransacitions.filter({ $0.contact != nil })
            guard !recovered.isEmpty else {
                if failOnNone {
                    XCTFail("Expected some recovered transactions")
                }
                return []
            }

            return recovered
        }

        func verifyAllMemoTypesPresent(historicalTransactions: [HistoricalTransaction]) -> Bool {

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
                return false
            }

            return true
        }

        func waitForTransaction(
            senderClient: MobileCoinClient,
            transaction: Transaction,
            numChecks: Int = 10
        ) async throws {
            var numChecksRemaining = numChecks

            while numChecksRemaining > 0 {
                numChecksRemaining -= 1
                print("Checking status...")
                let balance = try await senderClient.updateBalances().mobBalance
                print("Sender balance: \(balance)")

                let status = try await senderClient.status(of: transaction)

                switch status {
                case .unknown:
                    guard numChecksRemaining > 0 else {
                        XCTFail("Failed to resolve trans status check after \(numChecks) tries")
                        return
                    }
                    print("Sleeping 2s before re-checking...")
                    Thread.sleep(forTimeInterval: 2)
                case .accepted(block: let block):
                    print("Transaction accepted in block index: \(block.index)")
                    XCTAssertGreaterThan(block.index, 0)
                    if let timestamp = block.timestamp {
                        print("Block timestamp: \(timestamp)")
                    }
                case .failed:
                    XCTFail("Transaction status check: Transaction failed")
                }
            }
        }

        func waitForReceipt(
            receiverClient: MobileCoinClient,
            receipt: Receipt,
            numChecks: Int = 10
        ) async throws {
            var numChecksRemaining = numChecks

            while numChecksRemaining > 0 {
                numChecksRemaining -= 1
                print("Checking status...")
                let balance = try await receiverClient.updateBalances().mobBalance
                print("Receiver balance: \(balance)")

                guard let status = receiverClient.status(of: receipt)
                    .successOrFulfill() else { return }
                print("Receipt status: \(status)")

                switch status {
                case .unknown:
                    guard numChecksRemaining > 0 else {
                        XCTFail("Failed to resolve receipt status check after \(numChecks) tries")
                        return
                    }
                    print("Sleeping 2s before re-checking...")
                    Thread.sleep(forTimeInterval: 2)
                case .received(block: let block):
                    print("Received in block index: \(block.index)")
                    XCTAssertGreaterThan(block.index, 0)
                    if let timestamp = block.timestamp {
                        print("Block timestamp: \(timestamp)")
                    }
                case .failed:
                    XCTFail("Receipt status check: Transaction failed")
                }
            }
        }

        func populateMemoTypes(
            _ client: MobileCoinClient,
            _ clientKey: AccountKey,
            _ contactClient: MobileCoinClient,
            _ contactKey: AccountKey
        ) async throws {

            print("Populating Memo Types for RTH Testing")
            let (a, aKey, b, bKey) = (client, clientKey, contactClient, contactKey)
            let combos = [
                (a, b, bKey.publicAddress, MemoType.recoverable),
                (b, a, aKey.publicAddress, MemoType.recoverable),
                (a, b, bKey.publicAddress, MemoType.recoverablePaymentIntent(id: 9)),
                (b, a, aKey.publicAddress, MemoType.recoverablePaymentRequest(id: 9)),
                (a, b, bKey.publicAddress, MemoType.recoverablePaymentRequest(id: 9)),
                (b, a, aKey.publicAddress, MemoType.recoverablePaymentIntent(id: 9)),
            ]

            for combo in combos {
                let (srcClient, dstClient, dstAddress, memoType) = combo

                let trans = try await srcClient.prepareTransaction(
                    to: dstAddress,
                    amount: Amount(100, in: .MOB),
                    fee: IntegrationTestFixtures.fee,
                    memoType: memoType)
                try await srcClient.updateBalances()
                try await srcClient.submitTransaction(transaction: trans.transaction)
                try await waitForTransaction(senderClient: client, transaction: trans.transaction)
                try await waitForReceipt(receiverClient: dstClient, receipt: trans.receipt)
            }
        }

        let clientIdx = 0
        let contactIdx = 1

        let contactKey = try IntegrationTestFixtures.createAccountKey(accountIndex: contactIdx)
        let contact = Contact(
            name: "Account Index \(contactIdx)",
            username: "test",
            publicAddress: contactKey.publicAddress)

        let clientKey = try IntegrationTestFixtures.createAccountKey(accountIndex: clientIdx)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountIndex: clientIdx,
            transportProtocol: transportProtocol
        )

        var recovered = recoverTransactions(client: client, contact: contact, failOnNone: false)
        if !verifyAllMemoTypesPresent(historicalTransactions: recovered) {
            let contactClient = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
                accountIndex: contactIdx,
                transportProtocol: transportProtocol
            )
            try await client.updateBalances()
            try await populateMemoTypes(client, clientKey, contactClient, contactKey)
            recovered = recoverTransactions(client: client, contact: contact)
            if !verifyAllMemoTypesPresent(historicalTransactions: recovered) {
                XCTFail("Expected all recovered transaction types on testNet")
            }
        }
    }

    func testConsensusTrustRootWorks() async throws {
        let description = "Submitting transaction"
        try await testSupportedProtocols(description: description) {
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
        let description = "Submitting transaction"
        try await testSupportedProtocols(description: description) {
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

        let description = "Submitting transaction"
        try await testSupportedProtocols(description: description) {
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

#endif
