//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class AttestAkeTests: XCTestCase {

    func testInit() throws {
        _ = AttestAke()
    }

    func testAuthBegin() throws {
        let fixture = try AttestAke.Fixtures.Default()
        let attestAke = fixture.attestAke

        let authRequestData = attestAke.authBeginRequestData(
            responderId: fixture.responderId,
            rng: fixture.rng,
            rngContext: fixture.rngContext)
        XCTAssertEqual(
            authRequestData.base64EncodedString(),
            fixture.authRequestData.base64EncodedString())
    }

    func testAuthEnd() throws {
        let fixture = try AttestAke.Fixtures.DefaultWithAuthBegin()
        let attestAke = fixture.attestAke

        XCTAssertSuccess(attestAke.authEnd(
            authResponseData: fixture.authResponseData,
            attestationVerifier: fixture.attestationVerifier))
    }

    func testBinding() throws {
        let fixture = try AttestAke.Fixtures.BlankFirstMessage()
        let attestAkeCipher = fixture.attestAkeCipher

        let binding = attestAkeCipher.binding
        XCTAssertEqual(binding.base64EncodedString(), fixture.binding.base64EncodedString())
    }

    func testEncrypt() throws {
        let fixture = try AttestAke.Fixtures.BlankFirstMessage()
        let attestAkeCipher = fixture.attestAkeCipher

        let encryptedData = try XCTUnwrapSuccess(
            attestAkeCipher.encrypt(aad: fixture.aad, plaintext: fixture.plaintext))
        XCTAssertEqual(
            encryptedData.base64EncodedString(),
            fixture.encryptedData.base64EncodedString())
    }

}
