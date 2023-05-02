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
        let description = "Updating account balances"
        try await testSupportedProtocols(description: description) {
            try await self.balances(transportProtocol: $0)
        }
    }

    func balances(transportProtocol: TransportProtocol) async throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(using: transportProtocol)

        let blockVersion = try await client.blockVersion()
        guard blockVersion >= 2 else {
            print("Test cannot run on blockversion < 2, " +
                  "returning as success without running test")
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
//        try XCTSkip()
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
        let accountKey = try IntegrationTestFixtures.createAccountKey(accountIndex: 0)
        let client = try await IntegrationTestFixtures.createMobileCoinClientWithBalance(
            accountKey: accountKey,
            transportProtocol: transportProtocol
        )
        _ = try await client.prepareTransaction(to: recipient,
                                                amount: Amount(100, in: .MOB),
                                                fee: IntegrationTestFixtures.fee)
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

        let creatorIdx = 0
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
