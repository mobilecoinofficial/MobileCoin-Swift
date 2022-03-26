//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import LibMobileCoin
@testable import MobileCoin

class DestinationMemoTests: XCTestCase {
    func testDestinationMemoCreate() throws {
        let fixture = try Transaction.Fixtures.DestinationMemo()
        let destinationMemoData = try XCTUnwrap(
            DestinationMemoUtils.create(
                destinationPublicAddress: fixture.accountKey.publicAddress,
                numberOfRecipients: fixture.numberOfRecipients,
                fee: fixture.fee,
                totalOutlay: fixture.totalOutlay))
        
        XCTAssertEqual(
            DestinationMemoUtils.getAddressHash(memoData: destinationMemoData),
            fixture.accountKey.publicAddress.calculateAddressHash())

        XCTAssertEqual(
            DestinationMemoUtils.getFee(memoData: destinationMemoData),
            fixture.fee)

        XCTAssertEqual(
            DestinationMemoUtils.getTotalOutlay(memoData: destinationMemoData),
            fixture.totalOutlay)

        XCTAssertEqual(
            DestinationMemoUtils.getNumberOfRecipients(memoData: destinationMemoData),
            fixture.numberOfRecipients)
    }
}
