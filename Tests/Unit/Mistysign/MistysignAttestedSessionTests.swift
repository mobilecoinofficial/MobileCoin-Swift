//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class MistysignAttestedSessionTests: XCTestCase {

    func testStartsUnattested() {
        XCTAssertFalse(MistysignAttestedSession().isAttested)
    }

    func testEncryptBeforeAttestationThrowsNotAttested() {
        let session = MistysignAttestedSession()

        XCTAssertThrowsError(try session.encrypt(Data())) { error in
            guard case MistysignAttestedSessionError.notAttested = error else {
                XCTFail("Expected notAttested, got \(error)")
                return
            }
        }
    }

    func testDecryptBeforeAttestationThrowsNotAttested() {
        let session = MistysignAttestedSession()

        XCTAssertThrowsError(try session.decrypt(Data())) { error in
            guard case MistysignAttestedSessionError.notAttested = error else {
                XCTFail("Expected notAttested, got \(error)")
                return
            }
        }
    }

    func testAuthEndRejectsEmptyAttestation() {
        let session = MistysignAttestedSession()
        _ = session.authBeginRequestData(responderId: Self.responderId)

        XCTAssertThrowsError(
            try session.authEnd(authResponseData: Data(), attestation: Attestation())
        ) { error in
            guard case MistysignAttestedSessionError.noTrustedIdentities = error else {
                XCTFail("Expected noTrustedIdentities, got \(error)")
                return
            }
        }
        XCTAssertFalse(session.isAttested)
    }

    func testAuthEndWithoutAuthBeginThrowsAttestationFailed() throws {
        let session = MistysignAttestedSession()
        let attestation = try Attestation.Fixtures.MrEnclave().viewAttestation

        XCTAssertThrowsError(
            try session.authEnd(authResponseData: Data(), attestation: attestation)
        ) { error in
            guard case MistysignAttestedSessionError.attestationFailed(let reason) = error else {
                XCTFail("Expected attestationFailed, got \(error)")
                return
            }
            XCTAssertTrue(reason.contains("without a pending auth"))
        }
        XCTAssertFalse(session.isAttested)
    }

    func testAuthEndRejectsInvalidResponse() throws {
        let session = MistysignAttestedSession()
        _ = session.authBeginRequestData(responderId: Self.responderId)
        let attestation = try Attestation.Fixtures.MrEnclave().viewAttestation

        XCTAssertThrowsError(
            try session.authEnd(
                authResponseData: Data([0x00, 0x01, 0x02]),
                attestation: attestation)
        ) { error in
            guard case MistysignAttestedSessionError.attestationFailed(let reason) = error else {
                XCTFail("Expected attestationFailed, got \(error)")
                return
            }
            // A pending handshake must exist here, so the failure is the FFI
            // rejecting the response, not the missing-auth guard.
            XCTAssertFalse(reason.contains("without a pending auth"))
        }
        XCTAssertFalse(session.isAttested)
    }

    func testDeattestDiscardsPendingHandshake() throws {
        let session = MistysignAttestedSession()
        _ = session.authBeginRequestData(responderId: Self.responderId)
        let attestation = try Attestation.Fixtures.MrEnclave().viewAttestation

        session.deattest()

        XCTAssertThrowsError(
            try session.authEnd(authResponseData: Data(), attestation: attestation)
        ) { error in
            guard case MistysignAttestedSessionError.attestationFailed(let reason) = error else {
                XCTFail("Expected attestationFailed, got \(error)")
                return
            }
            // The missing-auth reason proves deattest discarded the handshake
            // rather than the FFI rejecting the empty response.
            XCTAssertTrue(reason.contains("without a pending auth"))
        }
    }

    private static let responderId = "mistysign.test.mobilecoin.com:443"

}
