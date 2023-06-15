//
//  Copyright (c) 2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin

extension PaymentRequest {
    enum Fixtures {}
}

extension PaymentRequest.Fixtures {
    struct Default {
        let publicAddress: PublicAddress
        let externalPublicAddress: External_PublicAddress
        let paymentValue: UInt64 = 123
        let paymentID: UInt64 = 456
        let memo = "test memo"

        init() throws {
            self.publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress
            self.externalPublicAddress = External_PublicAddress(publicAddress)
        }
    }
}
