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
                    amount: Amount(mob: 100),
                    fee: IntegrationTestFixtures.fee,
                    rng: rng2
                ) {
                    guard let transaction2 = $0.successOrFulfill(expectation: expect) else {
                        return
                    }

                    let t1 = transaction1.transaction
                    let t2 = transaction2.transaction

                    XCTAssertEqual(t1.fee, t2.fee)
                    XCTAssertEqual(t1.inputKeyImages, t2.inputKeyImages)
                    XCTAssertEqual(t1.inputKeyImagesTyped, t2.inputKeyImagesTyped)
                    XCTAssertEqual(t1.outputPublicKeys, t2.outputPublicKeys)

//                    XCTAssertEqual(t1.anyOutput, t2.anyOutput)
//                    XCTAssertEqual(t1.hashValue, t2.hashValue)
                    XCTAssertEqual(t1.outputs, t2.outputs)

                    let t1Data = transaction1.transaction.serializedData.base64EncodedString()
                    let t2Data = transaction2.transaction.serializedData.base64EncodedString()
                    XCTAssertEqual(t1Data, t2Data)
                    expect.fulfill()
                }

            }
        }
        waitForExpectations(timeout: 40)
    }

}
