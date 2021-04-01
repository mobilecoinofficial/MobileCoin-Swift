//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension MobUri {
    enum Fixtures {}
}

extension MobUri.Fixtures {
    struct Default {
        let publicAddress: PublicAddress
        let uri = Self.uri

        init() throws {
            self.publicAddress = try PublicAddress.Fixtures.Default().publicAddress
        }
    }
}

extension MobUri.Fixtures.Default {

    fileprivate static let uri = """
        mob:///b58/DBRMnVBHSDx69nCKEP1VNWh7KSytVWvBwfrUKsyq3uTLaQbf5aCQBu4etpLfjaR2QmtS17gQfMGfty9n\
        x8zkLBTTNnS83fBd9sLhG8LzscPeJuz6LadgYAhrpCxJVBTJChgYnP9ktSjqEZ8oLjwYhp4b6aYGSW6F9LWsU9vnHwP\
        QsJmLpP3YMi5TRSfrtVQ6rw5uw4F7MAuJPc3VKQHSqjN5tWL1T9ve2s2smhrGijhP54a3uucz5TjUUg
        """

}
