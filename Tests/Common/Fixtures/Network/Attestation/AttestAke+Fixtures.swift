//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

extension AttestAke {
    enum Fixtures {}
}

extension AttestAke.Fixtures {
    struct Default {
        let attestAke = AttestAke()

        let rng: @convention(c) (UnsafeMutableRawPointer?) -> UInt64 = testRngCallback
        let rngContext = TestRng()
        let authRequestData: Data
        let responderId = Self.responderId
        let attestationVerifier: AttestationVerifier

        init() throws {
            self.authRequestData = try XCTUnwrap(Data(base64Encoded: Self.authRequestDataBase64))
            self.attestationVerifier = try Self.attestationVerifier()
        }
    }
}

extension AttestAke.Fixtures {
    struct DefaultWithAuthBegin {
        let attestAke: AttestAke

        let authResponseData: Data
        let attestationVerifier: AttestationVerifier

        init() throws {
            self.authResponseData = try XCTUnwrap(
                Data(base64Encoded: Default.authResponseDataBase64))
            let defaultFixture = try Default()
            self.attestAke = defaultFixture.attestAke
            let authRequestData = attestAke.authBeginRequestData(
                responderId: defaultFixture.responderId,
                rng: defaultFixture.rng,
                rngContext: defaultFixture.rngContext)
            XCTAssertEqual(
                authRequestData.base64EncodedString(),
                Default.authRequestDataBase64)
            self.attestationVerifier = defaultFixture.attestationVerifier
        }
    }
}

extension AttestAke.Fixtures {
    struct DefaultAttested {
        let attestAkeCipher: AttestAke.Cipher

        init() throws {
            let authResponseData = try XCTUnwrap(
                Data(base64Encoded: Default.authResponseDataBase64))
            let attestAke = try DefaultWithAuthBegin().attestAke
            let verifier = try Default.attestationVerifier()
            self.attestAkeCipher = try attestAke.authEnd(
                authResponseData: authResponseData,
                attestationVerifier: verifier).get()
            XCTAssertTrue(attestAke.isAttested)
        }
    }
}

extension AttestAke.Fixtures {
    struct BlankFirstMessage {
        let attestAkeCipher: AttestAke.Cipher

        let aad = Data()
        let plaintext = Data()
        let encryptedData: Data

        init() throws {
            self.encryptedData = try XCTUnwrap(Data(base64Encoded: "17Bp8OpC6wynH0988QdRpg=="))
            self.attestAkeCipher = try AttestAke.Fixtures.DefaultAttested().attestAkeCipher
        }
    }
}

extension AttestAke.Fixtures.Default {

    fileprivate static let responderId = "fog.test.mobilecoin.com:443"

    fileprivate static func attestation() throws -> Attestation {
        try Attestation.Fixtures.MrEnclave().viewAttestation
    }

    fileprivate static func attestationVerifier() throws -> AttestationVerifier {
        AttestationVerifier(attestation: try attestation())
    }

    fileprivate static let authRequestDataBase64 =
        "RirBiNYMxQ+67j/DCQxwrFSnQ56n2SFsouqfDh7wciA="
    fileprivate static let authResponseDataBase64 = "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"

}

extension AttestAke.Fixtures.BlankFirstMessage {

    static let bindingBase64 =
        "Q0dvxKdcBLRw9jrtV7wfVITzM6grsxSp/rYDnUKHoTsE3ymGH9JTn85CtwUoYkVSBjFtGvPw/bpDqRwW7DQwKw=="

}
