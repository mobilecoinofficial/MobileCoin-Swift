//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import MobileCoin

struct Contact {
    let name: String
    let username: String
    let publicAddress: PublicAddress
}

extension Contact: PublicAddressProvider {}
extension Contact: Hashable, Equatable {}

extension Contact {
    enum Fixtures {}
}

extension Contact.Fixtures {
    struct DefaultValidSet {
        let contacts: Set<Contact>

        init() throws {
            self.contacts = Set([try Self.matchingContact()])
        }
    }
}

extension Contact.Fixtures.DefaultValidSet {
    static func matchingContact() throws -> Contact {
        let accountFixture = try AccountKey.Fixtures.KnownTxOut()
        return Contact(
            name: "John Doe",
            username: "johndoe-sender",
            publicAddress: accountFixture.senderAccountKey.publicAddress)

    }
}

extension Contact.Fixtures {
    struct OneToFour {
        let contacts: Set<Contact>

        init() throws {
            let accountFixture = try AccountKey.Fixtures.SeedableRng()
            let oneAccountKey = accountFixture.oneSeed
            let twoAccountKey = accountFixture.twoSeed
            let threeAccountKey = accountFixture.threeSeed
            let fourAccountKey = accountFixture.fourSeed

            self.contacts = Set([
                accountFixture.oneSeed,
                accountFixture.twoSeed,
                accountFixture.threeSeed,
                accountFixture.fourSeed, ]
                .enumerated()
                .map({
                    Contact(
                        name: "\($0.offset + 1)",
                        username: "johndoe-\($0.offset + 1)",
                        publicAddress: $0.element.publicAddress)
                }))
        }
    }

    struct FiveToSeven {
        let contacts: Set<Contact>

        init() throws {
            let accountFixture = try AccountKey.Fixtures.SeedableRng()

            self.contacts = Set([
                accountFixture.fiveSeed,
                accountFixture.sixSeed,
                accountFixture.sevenSeed, ]
                .enumerated()
                .map({
                    Contact(
                        name: "\($0.offset + 5)",
                        username: "johndoe-\($0.offset + 5)",
                        publicAddress: $0.element.publicAddress)
                }))
        }
    }
}

extension Contact.Fixtures.DefaultValidSet {
//    static func matchingContact() throws -> Contact {
//        let accountFixture = try AccountKey.Fixtures.KnownTxOut()
//        return
//
//    }
}
