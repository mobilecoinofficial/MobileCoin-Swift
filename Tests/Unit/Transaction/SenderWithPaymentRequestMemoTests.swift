//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class SenderWithPaymentRequestMemoTests: XCTestCase {
    func testSenderWithPaymentRequestMemoCreate() throws {
        let fixture = try Transaction.Fixtures.SenderWithPaymentRequestMemo()
        
        let memoData = try XCTUnwrap(
            SenderWithPaymentRequestMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey,
                paymentRequestId: fixture.paymentRequestId))
        
        XCTAssertEqual(
            memoData.data.hexEncodedString(),
            fixture.expectedSenderAddressHash.hexEncodedString())
        
        XCTAssertTrue(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey))

        XCTAssertEqual(
            fixture.senderAccountKey.publicAddress.calculateAddressHash(),
            SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData))
        
        XCTAssertEqual(
            SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData),
            fixture.paymentRequestId)
    }
}
