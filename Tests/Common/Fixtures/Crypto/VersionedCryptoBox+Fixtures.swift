//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
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
        let accountKey: AccountKey
        let publicAddress: PublicAddress
        let rng: @convention(c) (UnsafeMutableRawPointer?) -> UInt64 = testRngCallback
        let rngContext = TestRng()

        init() {
            self.accountKey = AccountKey.Fixtures.DefaultWithoutFog().accountKey
            self.privateKey = accountKey.subaddressViewPrivateKey
            self.publicKey = accountKey.publicAddress.viewPublicKeyTyped
            self.publicAddress = accountKey.publicAddress
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
        qn+wYIuZ23oBhi1qDuJoFyCJmIzbo5krlvc/2uxIQJJrATP6i/ePWebVsxpyomJ+CqAGykjmmYCwE28YfKD9VlY/a1o\
        XAsr8aHKSv+0NE/+RuVsbaxNJRI7ExEiu1tR9Sx3zlI4glYr04udYndVQLn03Vsz3qVq7RvapMEhCn2x9M02I+17Sih\
        8BdA9+aN2C5JqZmMqxpV0rGMoscdpp1aSfPIoYbBJa3ZS4fYHZkp1Z2hyA2J5iVm87Uzt3oZq0m3Q0sn0crGtNAQA=
        """)!

}
