//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

/// An attested channel to a Mistysign enclave whose transport is owned by the
/// caller.
///
/// The SDK's other attested services are reached through `MobileCoinClient`,
/// which opens the connection and attests over it in one step. Mistysign is
/// reached through a relay instead: the application's own backend forwards the
/// AKE handshake and the attested messages on the client's behalf, so the SDK
/// never holds the socket. This type performs the handshake and the message
/// encryption, and leaves every network call to the caller.
///
/// Usage:
/// 1. `authBeginRequestData(responderId:)`, relay the bytes to the enclave's
///    `Auth` RPC, and hand the response to `authEnd(authResponseData:attestation:)`.
/// 2. `encrypt(_:)` a serialized request proto, relay the resulting
///    `attest.Message`, and `decrypt(_:)` the reply.
///
/// The plaintext passed to `encrypt(_:)` is the serialized request proto itself
/// -- an `attest.Message` is the *output* of encryption, never a wrapper placed
/// around the plaintext beforehand. Wrapping first would leave the enclave
/// parsing an `attest.Message` where it expects the request. Not thread-safe:
/// the caller owning the transport must also serialize access to the session.
public final class MistysignAttestedSession {
    private let attestAke = AttestAke()

    public init() {}

    /// Whether `authEnd` has completed successfully, so that `encrypt(_:)` and
    /// `decrypt(_:)` can be used.
    public var isAttested: Bool {
        attestAke.isAttested
    }

    /// Begins the handshake and returns a serialized `attest.AuthMessage` to
    /// relay to the enclave's `Auth` RPC.
    ///
    /// `responderId` is used verbatim and must equal the value the enclave was
    /// launched with. It is bound into the handshake, so a mismatch surfaces as
    /// a failure in `authEnd`.
    public func authBeginRequestData(responderId: String) -> Data {
        attestAke.authBeginRequestData(responderId: responderId, rng: securityRNG)
    }

    /// Completes the handshake with the enclave's serialized `attest.AuthMessage`
    /// response, verifying its evidence against `attestation`.
    ///
    /// Throws `noTrustedIdentities` if `attestation` names none. Evidence is
    /// only accepted when it matches an identity the caller supplied, so an
    /// empty set can never succeed; rejecting it here fails at the boundary
    /// with a description of the mistake rather than deeper in verification.
    public func authEnd(authResponseData: Data, attestation: Attestation) throws {
        guard !attestation.mrEnclaves.isEmpty || !attestation.mrSigners.isEmpty else {
            throw MistysignAttestedSessionError.noTrustedIdentities
        }

        let verifier = AttestationVerifier(attestation: attestation)
        switch attestAke.authEnd(
            authResponseData: authResponseData,
            attestationVerifier: verifier)
        {
        case .success:
            break
        case .failure(let error):
            throw MistysignAttestedSessionError.attestationFailed("\(error)")
        }
    }

    /// Encrypts `plaintext` (a serialized request proto) and returns the
    /// serialized `attest.Message` to relay to the enclave.
    public func encrypt(_ plaintext: Data) throws -> Data {
        guard let cipher = attestAke.cipher else {
            throw MistysignAttestedSessionError.notAttested
        }

        switch cipher.encryptMessage(aad: Data(), plaintext: plaintext) {
        case .success(let message):
            do {
                return try message.serializedBytes()
            } catch {
                throw MistysignAttestedSessionError.encryptionFailed("\(error)")
            }
        case .failure(let error):
            throw MistysignAttestedSessionError.encryptionFailed("\(error)")
        }
    }

    /// Decrypts a serialized `attest.Message` reply and returns the plaintext,
    /// which is the serialized response proto.
    public func decrypt(_ messageData: Data) throws -> Data {
        guard let cipher = attestAke.cipher else {
            throw MistysignAttestedSessionError.notAttested
        }

        let message: Attest_Message
        do {
            message = try Attest_Message(serializedBytes: messageData)
        } catch {
            throw MistysignAttestedSessionError.decryptionFailed("\(error)")
        }

        switch cipher.decryptMessage(message) {
        case .success(let plaintext):
            return plaintext
        case .failure(let error):
            throw MistysignAttestedSessionError.decryptionFailed("\(error)")
        }
    }

    /// Discards the attested state so a fresh handshake can be started.
    public func deattest() {
        attestAke.deattest()
    }
}

public enum MistysignAttestedSessionError: Error {
    case notAttested
    case noTrustedIdentities
    case attestationFailed(String)
    case encryptionFailed(String)
    case decryptionFailed(String)
}

// LocalizedError, not just CustomStringConvertible: `Error.localizedDescription`
// ignores `description` and reports a generic bridged string unless the type
// conforms here, which would discard the reason at every call site that logs it.
extension MistysignAttestedSessionError: LocalizedError {
    public var errorDescription: String? { description }
}

extension MistysignAttestedSessionError: CustomStringConvertible {
    public var description: String {
        "Mistysign attested session error: " + {
            switch self {
            case .notAttested:
                return "Not attested. Complete authBeginRequestData/authEnd first."
            case .noTrustedIdentities:
                return "Attestation named no trusted identities to verify against."
            case .attestationFailed(let reason):
                return "Attestation failed: \(reason)"
            case .encryptionFailed(let reason):
                return "Encryption failed: \(reason)"
            case .decryptionFailed(let reason):
                return "Decryption failed: \(reason)"
            }
        }()
    }
}
