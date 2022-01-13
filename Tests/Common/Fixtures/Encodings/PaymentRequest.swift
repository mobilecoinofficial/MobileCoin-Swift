//
//  Copyright (c) 2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin

extension PaymentRequest {
    enum Fixtures {}
}

extension PaymentRequest.Fixtures {
    struct Default {
        let publicAddress: PublicAddress
        let externalPublicAddress: External_PublicAddress
        let paymentValue: UInt64 = 123
        let memo = "test memo"

        init() throws {
            self.publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress
            self.externalPublicAddress = External_PublicAddress(publicAddress)
        }
    }
}

extension TransferPayload.Fixtures.Default {
    fileprivate static let base64Entropy = "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQ="
    fileprivate static let base64Ristretto = "VECBlIdhtmTFaXtlWphlqELpDL04EKMbbPWu3CoJ2UE="
}
