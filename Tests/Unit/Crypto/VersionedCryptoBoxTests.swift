//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class VersionedCryptoBoxTests: XCTestCase {

    func testEncrypt() throws {
        let fixture = VersionedCryptoBox.Fixtures.Default()
        let encrypted = try XCTUnwrapSuccess(VersionedCryptoBox.encrypt(
            plaintext: fixture.plaintext,
            publicKey: fixture.publicKey,
            rng: fixture.rng,
            rngContext: fixture.rngContext))
        XCTAssertEqual(encrypted, fixture.ciphertext)
    }

    func testDecrypt() throws {
        let fixture = VersionedCryptoBox.Fixtures.Default()
        let decrypted = try XCTUnwrapSuccess(VersionedCryptoBox.decrypt(
            ciphertext: fixture.ciphertext,
            privateKey: fixture.privateKey))
        XCTAssertEqual(decrypted, fixture.plaintext)
    }

    func testDefaultBoxEncryption() throws {
        let fixture = VersionedCryptoBox.Fixtures.Default()
        let ciphertext = try XCTUnwrapSuccess(DefaultCryptoBox.encrypt(
            plaintext: fixture.plaintext,
            publicAddress: fixture.publicAddress))

        let decrypted = try XCTUnwrapSuccess(DefaultCryptoBox.decrypt(
            ciphertext: ciphertext,
            accountKey: fixture.accountKey))
        XCTAssertEqual(decrypted, fixture.plaintext)
    }
}
