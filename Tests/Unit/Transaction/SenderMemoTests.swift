//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class SenderMemoTests: XCTestCase {
    func testSenderMemoCreate() throws {
        let fixture = try Transaction.Fixtures.SenderMemo()
        
        let senderMemoData = try XCTUnwrap(
            SenderMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey))
        
        XCTAssertTrue(
            SenderMemoUtils.isValid(
                memoData: senderMemoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey))

        XCTAssertEqual(
            fixture.senderAccountKey.publicAddress.calculateAddressHash(),
            SenderMemoUtils.getAddressHash(memoData: senderMemoData))
    }
}
