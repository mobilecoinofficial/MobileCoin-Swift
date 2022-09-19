//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

@available(iOS 13.0.0, *)
class TransactionIdempotenceTests: XCTestCase {

    func createMobileCoinClientWithBalance() async throws -> MobileCoinClient {
        let expect = expectation(description: "Creating client")
        return await withCheckedContinuation { continuation in
            do {
                try IntegrationTestFixtures.createMobileCoinClientWithBalance(
                    expectation: expect,
                    transportProtocol: .http)
                { client in
                    continuation.resume(returning: client)
                }
            }
            catch {
                print("Error creating client")
            }
        }
    }
    
    func createTestTransaction(seed: Data) async throws -> PendingSinglePayloadTransaction {
        let amt = Amount(mob: 100)
        let rng = MobileCoinChaCha20Rng(seed:seed)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)
        let client = try await createMobileCoinClientWithBalance()
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                client.prepareTransaction(
                    to: recipient,
                    memoType: .unused,
                    amount: amt,
                    fee: IntegrationTestFixtures.fee,
                    rng: rng
                ) { result in
                    switch result {
                    case .success(let transaction):
                        continuation.resume(returning: transaction)
                    case .failure(let error):
                        continuation.resume(throwing:error)
                    }
                }
            }
        }
    }

    func testTransactionIdempotence() async throws {
        let seed = MobileCoinChaCha20Rng().seed
        let controlTrans = try await createTestTransaction(seed: seed)
        let controlTransData = controlTrans.transaction.serializedData
        for i in 1...1000  {
            let trans = try await createTestTransaction(seed: seed)
            let transData = trans.transaction.serializedData
            XCTAssertEqual(trans, controlTrans)
            XCTAssertEqual(transData, controlTransData)
            let comparison = controlTrans.transaction.proto.compareIdempotently(transData.transaction)
            XCTAssertTrue(comparison)
            print("Transaction \(i) equal to control")
        }
        await waitForExpectations(timeout: 10000)
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
