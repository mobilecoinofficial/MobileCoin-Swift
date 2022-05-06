//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Account {
    enum Fixtures {}
}

extension Account.Fixtures {
    struct Default {
        let account: Account
        let syncChecker = FogSyncChecker()

        let accountKey: AccountKey

        init(accountIndex: UInt8 = 0) throws {
            try self.init(
                accountKey: AccountKey.Fixtures.Default(accountIndex: accountIndex).accountKey)
        }

        init(accountKey: AccountKey) throws {
            self.accountKey = accountKey
            self.account = try Account.make(accountKey: accountKey, syncChecker: syncChecker).get()
        }
    }
}
