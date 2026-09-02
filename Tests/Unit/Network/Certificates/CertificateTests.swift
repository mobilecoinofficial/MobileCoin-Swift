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

    // The four below drive both delegate shims and each covers one of `handle`'s
    // outcomes.

    // The fixture chain is expired, and pinning accepts it anyway.
    func testServerTrustMatchingAPinnedKeyIsAccepted() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(try alphaNetCertificates(.valid))

        let result = try answer(of: requester, against: fixture.secTrust)

        XCTAssertEqual(result.disposition, .useCredential)
        XCTAssertNotNil(result.credential)
    }

    // The consensus root carries this one, so both roots take part in a
    // challenge.
    func testServerTrustMatchingNoPinnedKeyIsCancelled() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setConsensusTrustRoots(try alphaNetCertificates(.wrong))

        XCTAssertEqual(
            try answer(of: requester, against: fixture.secTrust).disposition,
            .cancelAuthenticationChallenge)
    }

    // With no roots set there is nothing to pin against, so the challenge goes
    // to the system rather than being refused.
    func testServerTrustWithoutPinnedKeysFallsThroughToDefaultHandling() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()

        XCTAssertEqual(
            try answer(of: DefaultHttpRequester(), against: fixture.secTrust).disposition,
            .performDefaultHandling)
    }

    func testChallengeWithoutServerTrustIsCancelled() throws {
        XCTAssertEqual(
            try answer(of: DefaultHttpRequester(), against: nil).disposition,
            .cancelAuthenticationChallenge)
    }

    // A URLSession holds its delegate until it is invalidated, so a requester
    // that goes out of scope without invalidating leaves its delegate behind.
    func testRequesterReleasesItsDelegateWhenItGoesOutOfScope() {
        weak var delegate: CertificatePinningDelegate?
        autoreleasepool {
            let requester = DefaultHttpRequester()
            delegate = requester.session.delegate as? CertificatePinningDelegate
            XCTAssertNotNil(delegate)
        }

        // Invalidation is asynchronous, so the release lands on the session's own
        // queue rather than on this one.
        let deadline = Date().addingTimeInterval(5)
        while delegate != nil && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTAssertNil(delegate)
    }

    // `pinnedKeys` reads fog before consensus, so distinct certificates and an
    // ordered comparison are what make a swap of the two setters visible.
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

        requester.setFogTrustRoots(nil)
        XCTAssertEqual(delegate.pinnedKeys, consensus.publicKeys)
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

    // Server trust is a session-level challenge. `validateAgainst` calls back on
    // the calling thread, so both shims answer before this returns.
    private func answer(
        of requester: DefaultHttpRequester,
        against trust: SecTrust?
    ) throws -> (disposition: URLSession.AuthChallengeDisposition?, credential: URLCredential?) {
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

        let delegate = try pinningDelegate(of: requester)
        let url = try XCTUnwrap(URL(string: "https://example.com"))
        let task = requester.session.dataTask(with: url)

        var sessionDisposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        delegate.urlSession(requester.session, didReceive: challenge) { result, resultCredential in
            sessionDisposition = result
            credential = resultCredential
        }

        var taskDisposition: URLSession.AuthChallengeDisposition?
        delegate.urlSession(requester.session, task: task, didReceive: challenge) { result, _ in
            taskDisposition = result
        }

        XCTAssertEqual(sessionDisposition, taskDisposition)
        return (sessionDisposition, credential)
    }
}

// `URLProtectionSpace` builds its own `serverTrust` from a live TLS handshake,
// so a fixture chain reaches the delegate only through an override.
private final class TrustingProtectionSpace: URLProtectionSpace, @unchecked Sendable {
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
