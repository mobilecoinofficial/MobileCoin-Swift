//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class SenderWithPaymentRequestMemoTests: XCTestCase {
    func testSenderWithPaymentRequestMemoCreate() throws {
        let fixture = try MemoData.Fixtures.SenderWithPaymentRequestMemo()
        
        let memoData = try XCTUnwrap(
            SenderWithPaymentRequestMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey,
                paymentRequestId: fixture.paymentRequestId))
        
        XCTAssertEqual(
            memoData.data.hexEncodedString(),
            fixture.expectedMemoData.hexEncodedString())

        XCTAssertTrue(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey))

        XCTAssertEqual(
            SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData),
            fixture.senderAccountKey.publicAddress.calculateAddressHash())

        XCTAssertEqual(
            SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData),
            fixture.paymentRequestId)
    }
}
