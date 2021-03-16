//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
@testable import MobileCoin

extension VersionedCryptoBox {
    enum Fixtures {}
}

extension VersionedCryptoBox.Fixtures {
    struct Default {
        let privateKey: RistrettoPrivate
        let publicKey: RistrettoPublic
        let plaintext = Self.plaintext
        let ciphertext = Self.ciphertext
        let rng: @convention(c) (UnsafeMutableRawPointer?) -> UInt64 = testRngCallback
        let rngContext = TestRng()

        init() {
            let accountKey = AccountKey.Fixtures.DefaultWithoutFog().accountKey
            self.privateKey = accountKey.subaddressViewPrivateKey
            self.publicKey = accountKey.publicAddress.viewPublicKeyTyped
        }
    }
}

extension VersionedCryptoBox.Fixtures.Default {

    fileprivate static let plaintext = Data(base64Encoded: """
        CncKLQoiCiBCZbFaAj0YA2NGk/2MEBtWpw7vtImvB82RA0BEyUx4MhGS8FtjcxAiAxIiCiDey62BbrNqR15xGoNRfuy\
        2WZf+gGg0sUMNT/lI8QVjFBoiCiAWZNmEKEE/nnYN7sPAYG5VFqPWbUWNVvqPETYRD8NKShGghgEAAAAAABkBAAAAAA\
        AAACH//////////y0CAAAA
        """)!
    fileprivate static let ciphertext = Data(base64Encoded: """
        cIBkDi1Juv3050d/GniqC+wZXmwEWAUdau4ORuGoLREjOyTnijygdOpfdgYrA/wiFIYoYKMCYX+M/ohta2O9PbI19DH\
        Vn4A+955T38Ah/AzkVabRA31YQkF2ZM1eTsvZHUkwwCaHrkXCXJvlrOLLnja8STH/AUzua1REshS63owhlDwxF0hoV/\
        k6T4AMNwxQadx53XoJOX6mGMoscdpp1aSfPIoYbBJa3ZS4fYHZkp1Z2hyA2J5iVm9YvYI8IOiHp3Wbqxmiv3QZAQA=
        """)!

}
