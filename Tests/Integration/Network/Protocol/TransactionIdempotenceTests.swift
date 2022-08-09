//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TransactionIdempotenceTests: XCTestCase {

    func testTransactionIdempotence() throws {
        let seed = Data32(repeating: 5)
        let rng1: MobileCoinRng = MobileCoinChaCha20Rng(seed: seed)
        let rng2: MobileCoinRng = MobileCoinChaCha20Rng(seed: seed)

        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let expect = expectation(description: description)

        try IntegrationTestFixtures.createMobileCoinClientWithBalance(
            expectation: expect,
            transportProtocol: .http)
        { client in
            client.prepareTransaction(
                to: recipient,
                memoType: .unused,
                amount: Amount(mob: 100),
                fee: IntegrationTestFixtures.fee,
                rng: rng1
            ) { result in
                guard let transaction1 = result.successOrFulfill(expectation: expect) else {
                    return
                }
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: Amount(mob: 100),
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

}
