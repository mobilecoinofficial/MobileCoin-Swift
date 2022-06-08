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
