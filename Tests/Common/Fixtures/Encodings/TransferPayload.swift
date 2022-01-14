//
//  Copyright (c) 2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin

extension TransferPayload {
    enum Fixtures {}
}

extension TransferPayload.Fixtures {
    struct Default {
        let entropyData: Data
        let entropyData32: Data32
        let ristretto: RistrettoPublic
        let ristrettoCompressed: External_CompressedRistretto
        let memo = "test memo"

        init() throws {
            guard let entropyData = Data(base64Encoded: Self.base64Entropy) else {
                throw TestInitializationError("TransferPayload.Fixture: entropyData is nil,"
                                              + " likely an invalid base64Entropy value")
            }
            self.entropyData = entropyData

            guard let entropyData32 = Data32(entropyData) else {
                throw TestInitializationError("TransferPayload.Fixture: entropyData32 is nil,"
                                              + " likely an invalid base64Entropy value")
            }
            self.entropyData32 = entropyData32

            guard let ristretto = RistrettoPublic(base64Encoded: Self.base64Ristretto) else {
                throw TestInitializationError("TransferPayload.Fixture: ristretto is nil,"
                                              + " likely an invalid base64Ristretto value")
            }
            self.ristretto = ristretto

            self.ristrettoCompressed = External_CompressedRistretto(ristretto)
        }
    }
}

extension TransferPayload.Fixtures.Default {
    fileprivate static let base64Entropy = "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQ="
    fileprivate static let base64Ristretto = "VECBlIdhtmTFaXtlWphlqELpDL04EKMbbPWu3CoJ2UE="
}
