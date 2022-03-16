//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class TxOutMemoBuilderTests: XCTestCase {
    
    func testCreateWithSenderAndDestination() throws {
        let fixture = try AccountKey.Fixtures.Default()
        XCTAssertNotNil(
            TxOutMemoBuilder.createRecoverableMemoBuilder(accountKey: fixture.accountKey))
    }
    
    func testDefault() throws {
        XCTAssertNotNil(
            TxOutMemoBuilder.createDefaultMemoBuilder())
    }
    
    func testcreateSenderPaymentRequestAndDestinationMemoBuilder() throws {
        let fixture = try AccountKey.Fixtures.Default()
        let paymentRequestId : UInt64 = 1
        XCTAssertNotNil(
            TxOutMemoBuilder.createRecoverablePaymentRequestMemoBuilder(
                paymentRequestId: paymentRequestId,
                accountKey: fixture.accountKey
            ))
    }
    
    
}
