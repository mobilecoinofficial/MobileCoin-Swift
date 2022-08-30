//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TransactionIdempotenceTests: XCTestCase {

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
