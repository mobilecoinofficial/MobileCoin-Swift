//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Base58Coder {
    enum Fixtures {}
}

extension Base58Coder.Fixtures {
    struct DefaultUsingPublicAddress {
        let publicAddress: PublicAddress
        let encoded = Self.encoded

        init() throws {
            self.publicAddress = try PublicAddress.Fixtures.Default().publicAddress
        }
    }
}

extension Base58Coder.Fixtures.DefaultUsingPublicAddress {

    static let encoded = """
        VbGaYEHbLrTUrDcj2HKVmtTSMJSqqkotszqABe8rZpco2bivKi3ppncedAr9vJbYrkSqGYLmkthNv24ae4g8iMZ7ppQ\
        nJBeHJQ2ybiabdLavENw5q3NBuHLTPnVoGRVzHE2bQfZEN6CxSHvCve3pHfLFTu4TAe3eEHwk41pJDtFNbuocguyDHb\
        UCTsgEQTFguMPnbG4HarSMeQNiDdqRRd6wbJzX4C5Dcg8uFzkvyZtocHtNYmtVVcBYwu
        """

}
