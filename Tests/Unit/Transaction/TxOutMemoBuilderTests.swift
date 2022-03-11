//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class TxOutMemoBuilderTests: XCTestCase {
    
    func testCreateWithSenderAndDestination() throws {
        let fixture = try AccountKey.Fixtures.Default()
        XCTAssertSuccess(
            TxOutMemoBuilder.createSenderAndDestinationRTHMemoBuilder(accountKey: fixture.accountKey))
    }
    
    func testDefault() throws {
        XCTAssertSuccess(
            TxOutMemoBuilder.createDefaultRTHMemoBuilder())
    }
    
    func testcreateSenderPaymentRequestAndDestinationRTHMemoBuilder() throws {
        let fixture = try AccountKey.Fixtures.Default()
        let paymentRequestId : UInt64 = 1
        XCTAssertSuccess(
            TxOutMemoBuilder.createSenderPaymentRequestAndDestinationRTHMemoBuilder(
                accountKey: fixture.accountKey,
                paymentRequestId: paymentRequestId))
    }
    
}
