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

@available(iOS 15.0, macOS 12.0, *)
class MobileCoinClientPublicApiIntTestsTransacting: XCTestCase {

    let numChecksForNewTx = 10

    func testSubmitTransaction() async throws {
        let description = "Submitting transaction"
        try await testSupportedProtocols(description: description) {
            if $0 == .http {
                try await self.submitTransaction(transportProtocol: $0)
            }
        }
    }

    func submitTransaction(
        transportProtocol: TransportProtocol
    ) async throws {
        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")

        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")

        try await client.updateBalances()

        let transaction = try await client.prepareTransaction(
            to: recipientAccountKey.publicAddress,
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
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")
        let recipient = recipientAccountKey.publicAddress

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

            print(client.accountActivity(for: .MOB).describeUnspentTxOuts())

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

            var numChecksRemaining = numChecksForNewTx
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

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        try await client.updateBalances()

        let fee = try await checkBlockVersionAndFee(client)
        let balancesBefore = try await checkBalances(client)
        try await prepareAndSubmit(client, fee)
        try await verifyBalanceChange(client, balancesBefore)
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
        let amountToReceive = Amount(10, in: .MOBUSD)

        let (creatorAccountKey, creator) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Creator")
        let (_, consumer) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Consumer")
        let creatorAddr = creatorAccountKey.publicAddress

        try await creator.updateBalances()
        try await consumer.updateBalances()

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
        let amountToSendWithoutFee = Amount(100, in: .MOB)
        let amountToReceive = Amount(10, in: .MOBUSD)

        func checkBlockVersionAndFee(
            _ client: MobileCoinClient
        ) async throws -> UInt64 {
            let blockVersion = try await client.blockVersion()
            XCTAssertGreaterThanOrEqual(blockVersion, 3, "Test cannot run on blockversion < 3 ...")
            return try await client.estimateTotalFee(
                toSendAmount: amountToSendWithoutFee,
                feeLevel: .minimum)
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

            var numChecksRemaining = numChecksForNewTx
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

                    let inFinal: UInt64
                    if let inFinalBal = balancesMap[inTokenId] {
                        inFinal = try XCTUnwrap(inFinalBal.amount())
                    } else {
                        inFinal = 0
                    }
                    let inInitial: UInt64
                    if let bal = balancesBeforeMap[inTokenId] {
                        inInitial = bal.amount()!
                    } else {
                        inInitial = 0
                    }

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

        let (creatorAccountKey, creator) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Creator")
        let (_, consumer) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Consumer")
        let creatorAddr = creatorAccountKey.publicAddress

        let creatorBalancesBefore = try await getBalances(creator)
        let consumerBalancesBefore = try await getBalances(consumer)
        let fee = try await checkBlockVersionAndFee(creator)

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
        let (clientAccountKey, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")

        func submitTransaction() async throws -> Balance {
            let balance = try await client.updateBalances().mobBalance
            print("Initial balance: \(balance)")

            let transaction = try await client.prepareTransaction(
                to: clientAccountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return balance
        }

        let initialBalance = try await submitTransaction()

        var numChecksRemaining = 10
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
                        XCTFail("Failed to receive a changed balance. initial balance: " +
                                "\(initialBalancePicoMob), fee: \(IntegrationTestFixtures.fee)" +
                                " balance: \(balancePicoMob), expected balance: " +
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
        let (clientAccountKey, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")

        func submitTransaction() async throws -> Balance {
            let balance = try await client.updateBalances().mobBalance
            print("Initial balance: \(balance)")
            let transaction = try await client.prepareTransaction(
                to: clientAccountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return balance
        }

        let initialBalance = try await submitTransaction()
        var numChecksRemaining = numChecksForNewTx
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
        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")

        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")
        let recipientPublicAddress = recipientAccountKey.publicAddress

        func submitTransaction() async throws -> Transaction {
            try await client.updateBalances()
            let transaction = try await client.prepareTransaction(to: recipientPublicAddress,
                                                                  amount: Amount(100, in: .MOB),
                                                                  fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return transaction.transaction
        }

        let transaction = try await submitTransaction()

        var numChecksRemaining = numChecksForNewTx

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
        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")
        let recipientPublicAddress = recipientAccountKey.publicAddress

        func submitTransaction() async throws -> Transaction {
            try await client.updateBalances()
            let transaction = try await client.prepareTransaction(to: recipientPublicAddress,
                                                                  amount: Amount(100, in: .MOB),
                                                                  fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return transaction.transaction
        }

        let transaction = try await submitTransaction()

        var numChecksRemaining = numChecksForNewTx

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
        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client")
        let (recipientAccountKey, recipient) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient")

        func submitTransaction() async throws -> Receipt {
            let balance = try await client.updateBalances().mobBalance
            print("Account 0 balance: \(balance)")
            let transaction = try await client.prepareTransaction(
                to: recipientAccountKey.publicAddress,
                amount: Amount(100, in: .MOB),
                fee: IntegrationTestFixtures.fee)
            try await client.submitTransaction(transaction: transaction.transaction)
            return transaction.receipt
        }

        let receipt = try await submitTransaction()
        var numChecksRemaining = numChecksForNewTx

        func checkStatus() async throws {
            numChecksRemaining -= 1
            print("Checking status...")
            let balance = try await recipient.updateBalances().mobBalance
            print("Account 1 balance: \(balance)")

            guard let status = recipient.status(of: receipt)
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

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client",
            config: config)
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient",
            config: config)

        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipientAccountKey.publicAddress,
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

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client",
            config: config)
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient",
            config: config)

        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipientAccountKey.publicAddress,
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

        let (_, client) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Client",
            config: config)
        let (recipientAccountKey, _) = try IntegrationTestFixtures.createDynamicClient(
            transportProtocol: transportProtocol,
            testName: #function,
            purpose: "Recipient",
            config: config)

        let balance = try await client.updateBalances().mobBalance
        guard let picoMob = try? XCTUnwrap(balance.amount()) else { return }
        print("balance: \(picoMob)")
        XCTAssertGreaterThan(picoMob, 0)
        guard picoMob > 0 else { return }

        let transaction = try await client.prepareTransaction(
            to: recipientAccountKey.publicAddress,
            amount: Amount(100, in: .MOB),
            fee: IntegrationTestFixtures.fee)
        try await client.submitTransaction(transaction: transaction.transaction)
    }

}

#endif
