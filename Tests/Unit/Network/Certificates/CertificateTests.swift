//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class CertificateTests: XCTestCase {

    func testValidTrustRoots() throws {
        let trustRoots = try NetworkPreset.trustRootsBytes()
        let certificates = try XCTUnwrap(try SecSSLCertificates(trustRootBytes: trustRoots))
        XCTAssertFalse(certificates.publicKeys.isEmpty)
    }

    func testInvalidRandomTrustRoots() throws {
        let randomData = try Array(repeating: 16, count: 100).map { try Data(randomOfLength: $0) }
        try XCTUnwrapFailure(SecSSLCertificates.make(trustRootBytes: randomData))
    }

    func testTestnetCertificateChain() throws {
        let fixture = try SecCertificateTests.Fixtures.TestNet()

        let pinnedKeys = [try fixture.validIntermediate.asPublicKey().get()]

        fixture.secTrust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            XCTAssertSuccess(result)
        }
    }

    func testAlphaNetCertificateChain() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()

        let pinnedKeys = [try fixture.validIntermediate.asPublicKey().get()]

        fixture.secTrust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            XCTAssertSuccess(result)
        }
    }

    func testInvalidIntermediateAgainstCertificateChain() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()

        let pinnedKeys = [try fixture.wrongIntermediate.asPublicKey().get()]

        fixture.secTrust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            XCTAssertFailure(result)
        }
    }

    // Pinning runs off the session delegate. Dropping `URLSessionDelegate` is a
    // build failure, because the session initializer demands it, but dropping
    // `URLSessionTaskDelegate` still compiles and silently sends every
    // task-level challenge to default handling.
    func testRequesterInstallsThePinningDelegate() {
        let delegate = DefaultHttpRequester().session.delegate

        XCTAssertTrue(delegate is CertificatePinningDelegate)
        XCTAssertTrue(delegate is URLSessionTaskDelegate)
    }

    // The test above asserts wiring. The four below drive a challenge through
    // the requester's own delegate, which is the only path a served request
    // takes, and each covers one of `handle`'s outcomes.

    func testServerTrustMatchingAPinnedKeyIsAccepted() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(try alphaNetCertificates(.valid))

        XCTAssertEqual(
            try disposition(of: requester, against: fixture.secTrust),
            .useCredential)
    }

    func testServerTrustMatchingNoPinnedKeyIsCancelled() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(try alphaNetCertificates(.wrong))

        XCTAssertEqual(
            try disposition(of: requester, against: fixture.secTrust),
            .cancelAuthenticationChallenge)
    }

    // With no roots set there is nothing to pin against, so the challenge goes
    // to the system rather than being refused.
    func testServerTrustWithoutPinnedKeysFallsThroughToDefaultHandling() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()

        XCTAssertEqual(
            try disposition(of: DefaultHttpRequester(), against: fixture.secTrust),
            .performDefaultHandling)
    }

    // A challenge carrying no server trust at all is refused outright.
    func testChallengeWithoutServerTrustIsCancelled() throws {
        XCTAssertEqual(
            try disposition(of: DefaultHttpRequester(), against: nil),
            .cancelAuthenticationChallenge)
    }

    // The two roots are separate fields, and `pinnedKeys` reads fog before
    // consensus. Distinct certificates and an ordered comparison are what make
    // a swap of the two setters visible.
    func testEachTrustRootSetterWritesItsOwnField() throws {
        let requester = DefaultHttpRequester()
        let delegate = try pinningDelegate(of: requester)
        let fog = try alphaNetCertificates(.valid)
        let consensus = try alphaNetCertificates(.wrong)

        XCTAssertTrue(delegate.pinnedKeys.isEmpty)

        requester.setFogTrustRoots(fog)
        XCTAssertEqual(delegate.pinnedKeys, fog.publicKeys)

        requester.setConsensusTrustRoots(consensus)
        XCTAssertEqual(delegate.pinnedKeys, fog.publicKeys + consensus.publicKeys)
    }

    private enum AlphaNetIntermediate {
        case valid
        case wrong
    }

    private func alphaNetCertificates(
        _ intermediate: AlphaNetIntermediate
    ) throws -> SecSSLCertificates {
        let base64: String
        switch intermediate {
        case .valid:
            base64 = SecCertificateTests.Fixtures.AlphaNet.intermediateCertificateBase64
        case .wrong:
            base64 = SecCertificateTests.Fixtures.AlphaNet.wrongIntermediateCertificateBase64
        }
        let bytes = try XCTUnwrap(Data(base64Encoded: base64))
        return try XCTUnwrap(try SecSSLCertificates(trustRootBytes: [bytes]))
    }

    private func pinningDelegate(
        of requester: DefaultHttpRequester
    ) throws -> CertificatePinningDelegate {
        try XCTUnwrap(requester.session.delegate as? CertificatePinningDelegate)
    }

    // `validateAgainst` calls back on the calling thread, so the disposition is
    // set by the time `handle` returns and no expectation is needed.
    private func disposition(
        of requester: DefaultHttpRequester,
        against trust: SecTrust?
    ) throws -> URLSession.AuthChallengeDisposition? {
        let space: URLProtectionSpace
        if let trust = trust {
            space = TrustingProtectionSpace(trust: trust)
        } else {
            space = URLProtectionSpace(
                host: "example.com",
                port: 443,
                protocol: NSURLProtectionSpaceHTTPS,
                realm: nil,
                authenticationMethod: NSURLAuthenticationMethodServerTrust)
        }
        let challenge = URLAuthenticationChallenge(
            protectionSpace: space,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: NullChallengeSender())

        var disposition: URLSession.AuthChallengeDisposition?
        try pinningDelegate(of: requester).handle(challenge: challenge) { result, _ in
            disposition = result
        }
        return disposition
    }
}

// `URLProtectionSpace` builds its own `serverTrust` from a live TLS handshake,
// so a fixture chain reaches the delegate only through an override.
private final class TrustingProtectionSpace: URLProtectionSpace {
    private let trust: SecTrust

    init(trust: SecTrust) {
        self.trust = trust
        super.init(
            host: "example.com",
            port: 443,
            protocol: NSURLProtectionSpaceHTTPS,
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("unused") }

    override var serverTrust: SecTrust? { trust }
}

// URLAuthenticationChallenge demands a sender. Nothing under test calls back
// into it.
private final class NullChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
