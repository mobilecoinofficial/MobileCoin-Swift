//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class RecoverableMemoTests: XCTestCase {

    func testRecoverValid() throws {
        let fixture = try RecoverableMemo.Fixtures.SingleSenderMemoTx()
        let result = MobileCoinClient.recover(
            txOut: fixture.ownedTxOut,
            contacts: fixture.contacts)

        XCTAssertEqual(result.txOut, fixture.ownedTxOut)
        XCTAssertEqual(result.contact?.publicAddress, fixture.matchingContact.publicAddress)
        XCTAssertEqual(result.memo, fixture.memo)
    }

    func testRecoverMany() throws {
        let fixture = try RecoverableMemo.Fixtures.Many()
        let results = MobileCoinClient.recoverTransactions(
            fixture.onesTxOuts,
            contacts: fixture.contacts)

        // Check that all results were "recovered"
        XCTAssertEqual(results.filter({ $0.memo == nil }).count, 0)

        // Check the address hash in the memo matches the contact
        results.forEach({
            guard
                let contact = $0.contact,
                let memo = $0.memo,
                contact.publicAddress.calculateAddressHash() == memo.addressHash
            else {
                XCTFail("Contact address hash does not equal the memo address hash")
                return
            }
        })
    }

    func testBadContactsRecover() throws {
        let fixture = try RecoverableMemo.Fixtures.Many()
        let results = MobileCoinClient.recoverTransactions(
            fixture.onesTxOuts,
            contacts: fixture.badContacts)

        // Check that all authenticated sender memo results were not "recovered"
        let authenticatedSenderMemoTxOuts = results.filter {
            $0.txOut.recoverableMemo.isAuthenticatedSenderMemo
        }
        .filter {
            $0.memo != nil
        }
        XCTAssertEqual(authenticatedSenderMemoTxOuts.count, 0)
    }

}
