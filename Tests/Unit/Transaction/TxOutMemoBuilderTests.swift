//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

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
        let paymentRequestId: UInt64 = 1
        XCTAssertNotNil(
            TxOutMemoBuilder.createRecoverablePaymentRequestMemoBuilder(
                paymentRequestId: paymentRequestId,
                accountKey: fixture.accountKey))
    }

    func testcreateSenderPaymentIntentAndDestinationMemoBuilder() throws {
        let fixture = try AccountKey.Fixtures.Default()
        let paymentIntentId: UInt64 = 1
        XCTAssertNotNil(
            TxOutMemoBuilder.createRecoverablePaymentIntentMemoBuilder(
                paymentIntentId: paymentIntentId,
                accountKey: fixture.accountKey))
    }

}
