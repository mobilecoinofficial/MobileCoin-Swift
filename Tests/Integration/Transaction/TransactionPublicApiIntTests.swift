//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class TransactionPublicApiIntTests: XCTestCase {

    func testSerializedDataGRPC() throws {
        try serializedData(transportProtocol: TransportProtocol.grpc)
    }
    
    func testSerializedDataHTTP() throws {
        try serializedData(transportProtocol: TransportProtocol.http)
    }
    
    func serializedData(transportProtocol: TransportProtocol) throws {
        let client = try IntegrationTestFixtures.createMobileCoinClient(transportProtocol:transportProtocol)
        let recipient = try IntegrationTestFixtures.createPublicAddress(accountIndex: 1)

        let expect = expectation(description: "Testing Transaction serialization")
        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expect) else { return }
            if let amountPicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                print("got balance: \(amountPicoMob)")
            }

            client.prepareTransaction(
                to: recipient,
                amount: 10,
                fee: IntegrationTestFixtures.fee
            ) {
                guard let (transaction, _) = $0.successOrFulfill(expectation: expect)
                else { return }

                if let deserialized =
                    try? XCTUnwrap(Transaction(serializedData: transaction.serializedData))
                {
                    XCTAssertEqual(deserialized, transaction)
                }
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
    }

}
