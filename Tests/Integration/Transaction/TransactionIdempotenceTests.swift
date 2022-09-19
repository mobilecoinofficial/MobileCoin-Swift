//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TransactionIdempotenceTests: XCTestCase {

//    func testIdempotenceFailure() throws {
//        let description = "Updating account balance"
//        try testSupportedProtocols(description: description) {
//            try idempotenceFailure(transportProtocol: $0, expectation: $1)
//        }
//    }


    func testIdempotenceFailure() throws {
        let description = "Updating account balance"
        let expect = expectation(description: description)
        try idempotenceFailure(transportProtocol: .http, expectation: expect)
        waitForExpectations(timeout: 1000.0)
    }

    func idempotenceFailure(
        transportProtocol: TransportProtocol,
        expectation expect: XCTestExpectation
    ) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(
                accountIndex: 1,
                using: transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 0)
        let amt = Amount(mob: 100)
        let rng1 = MobileCoinChaCha20Rng()
        let rng2 = MobileCoinChaCha20Rng(seed: rng1.seed)

        func submitTransaction(rng: MobileCoinRng, callback: @escaping (Transaction) -> Void) {
            client.updateBalance {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: rng
                ) { result in
                    guard let transaction = result.successOrFulfill(expectation: expect) else {
                        return
                    }

                    client.submitTransaction(transaction.transaction) {
                        guard $0.successOrFulfill(expectation: expect) != nil else { return }

                        callback(transaction.transaction)
                    }
                }
            }
        }

        submitTransaction(rng: rng1) { (transaction: Transaction) in
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

                            client.updateBalance {
                                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                                client.prepareTransaction(
                                    to: recipient,
                                    memoType: .unused,
                                    amount: amt,
                                    fee: IntegrationTestFixtures.fee,
                                    rng: rng2
                                ) { result in
                                    guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                                        return
                                    }

                                    submitTransaction(rng: rng2) { (transaction: Transaction) in
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
                                                        XCTFail("Transaction status check: Idempotence failed - second transaction was successful")
                                                        expect.fulfill()
                                                        return
                                                    case .failed:
                                                        // the transaction SHOULD fail - fall through to fulfill expectation without failure
                                                        expect.fulfill()
                                                        return
                                                    }
                                                }
                                            }
                                        }
                                        checkStatus()
                                    }

                                }
                            }
                        case .failed:
                            XCTFail("Transaction status check: Transaction failed")
                        }
                    }
                }
            }
            checkStatus()
        }
    }

    func testTransactionIdempotence() throws {
        let amt = Amount(mob: 100)
        let rng1 = MobileCoinChaCha20Rng()
        let rng2 = MobileCoinChaCha20Rng(seed: rng1.seed)

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let expect = expectation(description: description)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
            expectation: expect,
            transportProtocol: .http)
        { client in
            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rng: rng1
            ) { result in
                guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                    return
                }
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: rng2
                ) {
                    guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                        return
                    }

                    XCTAssertEqual(transaction1, transaction2)
                    expect.fulfill()
                }

            }
        }
        waitForExpectations(timeout: 40)
    }

    func testTransactionIdempotenceWithWordPos() throws {
        let amt = Amount(mob: 100)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let rng1 = MobileCoinChaCha20Rng()

        let expect = expectation(description: "testing idempotence with word pos")

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
            expectation: expect,
            transportProtocol: .http)
        { client in

            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: amt,
                fee: IntegrationTestFixtures.fee,
                rng: rng1
            ) { result in
                guard result.successOrFulfill(expectation: expect) != nil else {
                    return
                }

                // the seed and wordpos
                let wordPos = rng1.wordPos()

                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: rng1
                ) { result in
                    guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                        return
                    }

                    // create rng w/same seed & cached wordpos state
                    let rng2 = MobileCoinChaCha20Rng(seed: rng1.seed)
                    rng2.setWordPos(wordPos)

                    client.prepareTransaction(
                        to: recipient,
                        memoType: .unused,
                        amount: amt,
                        fee: IntegrationTestFixtures.fee,
                        rng: rng2
                    ) {
                        guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                            return
                        }

                        XCTAssertEqual(transaction1, transaction2)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 40)
    }
}
