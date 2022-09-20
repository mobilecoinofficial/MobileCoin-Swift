//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable line_length

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
        let rngSeed = MobileCoinChaCha20Rng().rngSeed

        func submitTransaction(rngSeed: RngSeed, expectFailure: Bool, callback: @escaping (Transaction) -> Void) {
            client.updateBalance {
                guard $0.successOrFulfill(expectation: expect) != nil else { return }

                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rngSeed: rngSeed
                ) { result in
                    guard let transaction = result.successOrFulfill(expectation: expect) else {
                        return
                    }

                    client.submitTransaction(transaction.transaction) {
                        switch $0 {
                        case .success:
                            guard !expectFailure else {
                                XCTAssertFalse(true)
                                expect.fulfill()
                                return
                            }
                            callback(transaction.transaction)
                        case .failure(let error):
                            guard expectFailure else {
                                XCTAssertFalse(true)
                                expect.fulfill()
                                return
                            }

                            switch error {
                            case .outputAlreadyExists:
                                expect.fulfill()
                            default:
                                XCTAssertFalse(true)
                                expect.fulfill()
                            }
                        }
                    }
                }
            }
        }

        submitTransaction(rngSeed: rngSeed, expectFailure: false) { (transaction: Transaction) in
            var numChecksRemaining = 10

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

                            print("Sleeping 20s")
                            sleep(20)
                            print("Updating balance...")
                            client.updateBalance {
                                guard let balance = $0.successOrFulfill(expectation: expect) else { return }
                                print("Balance: \(balance)")

                                print("Checking status...")

                                submitTransaction(rngSeed: rngSeed, expectFailure: true) { (transaction: Transaction) in
                                    var numChecksRemaining = 10

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
                        case .failed:
                            XCTFail("Transaction status check: Transaction failed")
                        }
                    }
                }
            }
            checkStatus()
        }
    }

    func testStaticAccountTransactionIdempotence() throws {
        let amt = Amount(mob: 100)
        let rngSeed = RngSeed()

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
                rngSeed: rngSeed
            ) { result in
                guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                    return
                }
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rngSeed: rngSeed
                ) {
                    guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                        return
                    }

                    XCTAssertTrue(PendingSinglePayloadTransaction.areIdempotent(
                        transaction1,
                        transaction2))
                    expect.fulfill()
                }

            }
        }
        waitForExpectations(timeout: 40)
    }

}
