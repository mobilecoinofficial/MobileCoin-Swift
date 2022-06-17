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
    struct SingleSenderMemoTx {
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
            let contacts = try Contact.Fixtures.DefaultValidSet().contacts
            self.matchingContact = try XCTUnwrap(contacts.first)
            self.contacts = contacts

            let senderPublicAddress = fixture.senderAccountKey.publicAddress
            self.memo = try XCTUnwrap(
                fixture.knownTxOut.recoverableMemo.recover(publicAddress: senderPublicAddress))
        }
    }
}

extension RecoverableMemo.Fixtures.SingleSenderMemoTx {
    static var receivedBlock = BlockMetadata(index: 10000, timestamp: nil)
    static var spentBlock = BlockMetadata(index: 20000, timestamp: nil)
}

extension RecoverableMemo.Fixtures {
    struct Many {
        let oneAccountKey: AccountKey
        let twoAccountKey: AccountKey
        let threeAccountKey: AccountKey
        let fourAccountKey: AccountKey
        let onesTxOuts: Set<OwnedTxOut>
        let contacts: Set<Contact>
        let badContacts: Set<Contact>

        init() throws {
            let accountFixture = try AccountKey.Fixtures.SeedableRng()
            self.oneAccountKey = accountFixture.oneSeed
            self.twoAccountKey = accountFixture.twoSeed
            self.threeAccountKey = accountFixture.threeSeed
            self.fourAccountKey = accountFixture.fourSeed

            let knownTxOutFixture = try KnownTxOut.Fixtures.RTHSeedableRng()
            let onesTxOuts = [
                knownTxOutFixture.one_to_two.change,
                knownTxOutFixture.one_to_three.change,
                knownTxOutFixture.one_to_four.change,
                knownTxOutFixture.four_to_one.output, ]
                .enumerated()
                .map({ OwnedTxOut(
                    $0.element,
                    receivedBlock: BlockMetadata(index: UInt64($0.offset), timestamp: nil),
                    spentBlock: BlockMetadata(index: UInt64($0.offset + 100), timestamp: nil))
                })

            self.onesTxOuts = Set(onesTxOuts)
            self.contacts = try Contact.Fixtures.OneToFour().contacts
            self.badContacts = try Contact.Fixtures.FiveToSeven().contacts
        }
    }
}
