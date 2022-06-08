//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class RecoverableMemoTests: XCTestCase {

    func testRecoverValid() throws {
        let fixture = try RecoverableMemo.Fixtures.Default()
        let result = MobileCoinClient.recover(
            txOut: fixture.ownedTxOut,
            contacts: fixture.contacts)

        XCTAssertEqual(result.txOut, fixture.ownedTxOut)
        XCTAssertEqual(result.contact?.publicAddress, fixture.matchingContact.publicAddress)
        XCTAssertEqual(result.memo, fixture.memo)
    }

    func testRecoverNone() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultUnused()
    }

    func testHistoricalTransactionSorting() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
    }

}
