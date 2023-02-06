//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class MobileCoinClientPublicApiIntTests: XCTestCase {

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
