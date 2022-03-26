//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class SenderMemoTests: XCTestCase {
    func testSenderMemoCreate() throws {
        let fixture = try Transaction.Fixtures.SenderMemo()
        
        let memoData = try XCTUnwrap(
            SenderMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey))
        
        XCTAssertEqual(
            memoData.data.hexEncodedString(),
            fixture.expectedSenderAddressHash.hexEncodedString())
        
        XCTAssertTrue(
            SenderMemoUtils.isValid(
                memoData: memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey))

        XCTAssertEqual(
            fixture.senderAccountKey.publicAddress.calculateAddressHash(),
            SenderMemoUtils.getAddressHash(memoData: memoData))
    }
}
