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
        mob:///b58/VbGaYEHbLrTUrDcj2HKVmtTSMJSqqkotszqABe8rZpco2bivKi3ppncedAr9vJbYrkSqGYLmkthNv24a\
        e4g8iMZ7ppQnJBeHJQ2ybiabdLavENw5q3NBuHLTPnVoGRVzHE2bQfZEN6CxSHvCve3pHfLFTu4TAe3eEHwk41pJDtF\
        NbuocguyDHbUCTsgEQTFguMPnbG4HarSMeQNiDdqRRd6wbJzX4C5Dcg8uFzkvyZtocHtNYmtVVcBYwu
        """

}
