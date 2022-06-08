//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
import XCTest

extension RecoverableMemo {
    enum Fixtures {}
}

extension RecoverableMemo.Fixtures {
    struct Default {
        let ownedTxOut: OwnedTxOut
        let contacts: Set<Contact>
        let matchingContact: Contact
        let memo: RecoveredMemo

        init() throws {
            let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
            self.ownedTxOut = OwnedTxOut(
                fixture.knownTxOut,
                receivedBlock: Self.receivedBlock,
                spentBlock: Self.spentBlock)
            self.contacts = try Contact.Fixtures.DefaultValidSet().contacts
            self.matchingContact = try XCTUnwrap(self.contacts.first)

            let senderPublicAddress = fixture.senderAccountKey.publicAddress
            self.memo = try XCTUnwrap(
                fixture.knownTxOut.recoverableMemo.recover(publicAddress: senderPublicAddress))
        }
    }
}

extension RecoverableMemo.Fixtures.Default {
    static var receivedBlock = BlockMetadata(index: 10000, timestamp: nil)
    static var spentBlock = BlockMetadata(index: 20000, timestamp: nil)
}
