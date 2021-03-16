//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class VersionedCryptoBoxPerfTests: PerformanceTestCase {

    func testPerformanceEncrypt() {
        measure {
            let fixture = VersionedCryptoBox.Fixtures.Default()
            let encrypted = try? XCTUnwrapSuccess(VersionedCryptoBox.encrypt(
                plaintext: fixture.plaintext,
                publicKey: fixture.publicKey,
                rng: fixture.rng,
                rngContext: fixture.rngContext))
            XCTAssertEqual(encrypted, fixture.ciphertext)
        }
    }

    func testPerformanceDecrypt() {
        measure {
            let fixture = VersionedCryptoBox.Fixtures.Default()
            let decrypted = try? XCTUnwrapSuccess(VersionedCryptoBox.decrypt(
                ciphertext: fixture.ciphertext,
                privateKey: fixture.privateKey))
            XCTAssertEqual(decrypted, fixture.plaintext)
        }
    }

}
