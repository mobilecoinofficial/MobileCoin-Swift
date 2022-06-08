//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class DestinationMemoTests: XCTestCase {
    func testDestinationMemoCreate() throws {
        let fixture = try MemoData.Fixtures.DefaultDestinationMemo()

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

    func testDestinationMemoZeroOutlayCreate() throws {
        let fixture = try MemoData.Fixtures.DestinationZeroOutlayMemo()

        let destinationMemoData = try XCTUnwrap(
            DestinationMemoUtils.create(
                destinationPublicAddress: fixture.accountKey.publicAddress,
                numberOfRecipients: fixture.numberOfRecipients,
                fee: fixture.fee,
                totalOutlay: fixture.totalOutlay))

        XCTAssertEqual(
            DestinationMemoUtils.getTotalOutlay(memoData: destinationMemoData),
            fixture.totalOutlay)
    }
}
