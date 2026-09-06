//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
import LibMobileCoinHTTP
#endif
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

    // The fixture chains carry expired leaves, so evaluating one at the current
    // date is what separates a matching key from an acceptable connection.
    func testExpiredChainIsRefusedWhenAPinnedKeyMatches() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let pinnedKeys = [try fixture.validIntermediate.asPublicKey().get()]

        let atTheCurrentDate = try SecCertificateTests.createSecTrust(
            fixture.certificateChain,
            verifyDate: nil)

        XCTAssertTrue(
            try refusal(of: atTheCurrentDate, against: pinnedKeys)
                .hasPrefix(SecTrust.systemEvaluationFailure))
    }

    // The pinned key is an intermediate CA key, so it matches every certificate
    // that CA issues. Only the host in the policy separates the two evaluations.
    func testChainIssuedForAnotherHostIsRefusedWhenAPinnedKeyMatches() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let pinnedKeys = [try fixture.validIntermediate.asPublicKey().get()]

        let forItsOwnHost = try SecCertificateTests.createSecTrust(
            fixture.certificateChain,
            host: "fog.alpha.development.mobilecoin.com")

        forItsOwnHost.validateAgainst(pinnedKeys: pinnedKeys) { result in
            XCTAssertSuccess(result)
        }

        let forAnotherHost = try SecCertificateTests.createSecTrust(
            fixture.certificateChain,
            host: "fog.prod.mobilecoin.com")

        XCTAssertTrue(
            try refusal(of: forAnotherHost, against: pinnedKeys)
                .hasPrefix(SecTrust.systemEvaluationFailure))
    }

    // Anchoring on another chain's top certificate leaves this chain with no
    // path to a trusted anchor, which is what an untrusted root looks like.
    func testChainOnAnUntrustedRootIsRefusedWhenAPinnedKeyMatches() throws {
        let alphaNet = try SecCertificateTests.Fixtures.AlphaNet()
        let testNet = try SecCertificateTests.Fixtures.TestNet()
        let pinnedKeys = [try alphaNet.validIntermediate.asPublicKey().get()]

        let onAForeignAnchor = try SecCertificateTests.createSecTrust(
            alphaNet.certificateChain,
            anchorOverride: try XCTUnwrap(testNet.certificateChain.last))

        XCTAssertTrue(
            try refusal(of: onAForeignAnchor, against: pinnedKeys)
                .hasPrefix(SecTrust.systemEvaluationFailure))
    }

    func testInvalidIntermediateAgainstCertificateChain() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()

        let pinnedKeys = [try fixture.wrongIntermediate.asPublicKey().get()]

        XCTAssertEqual(
            try refusal(of: fixture.secTrust, against: pinnedKeys),
            SecTrust.noPinnedKeyMatched)
    }

    // The system quotes the server's own common name in its error description,
    // so a refusal that repeats it lets the server write the client's log.
    func testARefusalCarriesTheCodeAndNotTheServersCommonName() throws {
        let fixture = try SecCertificateTests.Fixtures.ForgedCommonName()

        var systemError: CFError?
        XCTAssertFalse(SecTrustEvaluateWithError(fixture.secTrust, &systemError))
        let systemDescription = CFErrorCopyDescription(try XCTUnwrap(systemError)) as String
        XCTAssertTrue(
            systemDescription.contains(SecCertificateTests.Fixtures.ForgedCommonName.commonName))

        let reason = try refusal(of: fixture.secTrust, against: [])

        XCTAssertEqual(
            reason,
            SecTrust.systemEvaluationFailure + "\(CFErrorGetCode(try XCTUnwrap(systemError)))")
        XCTAssertEqual(reason.components(separatedBy: "\n").count, 1)
    }

    // Exact equality is what proves the message carries no key material, rather
    // than a search for one encoding of the key.
    func testAMatchIsReportedByIndexAndNotByKey() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let pinnedKeys = [try fixture.validIntermediate.asPublicKey().get()]

        var message: String?
        fixture.secTrust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            message = try? result.get()
        }

        let index = try XCTUnwrap(
            fixture.secTrust.certificateTrustChain.firstIndex {
                $0.data == fixture.validIntermediate.data
            })
        XCTAssertEqual(message, SecTrust.pinnedKeyMatched + "[\(index)]")
    }

    // A requester that stores no trust roots takes the protocol's own setters,
    // and a caller that reads success there believes roots are pinned.
    func testARequesterWithoutTrustRootStorageReportsAFailure() {
        let requester = RequestOnlyHttpRequester()

        XCTAssertFailure(requester.setFogTrustRoots(nil))
        XCTAssertFailure(requester.setConsensusTrustRoots(nil))
    }

    // Roots that fail to parse leave the pinned roots in place, because a config
    // with no roots falls through to the system's own handling.
    func testAFailedParseKeepsTheTrustRootsAlreadySet() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()

        XCTAssertSuccess(config.setConsensusTrustRoots(fixture.trustRootsBytes))
        let pinned = try XCTUnwrap(config.consensusTrustRoots[.http] as? SecSSLCertificates)

        XCTAssertFailure(config.setConsensusTrustRoots([fixture.invalidTrustRootBytes]))

        XCTAssertEqual(
            (config.consensusTrustRoots[.http] as? SecSSLCertificates)?.publicKeys,
            pinned.publicKeys)
    }

    // The four below drive both delegate shims and each covers one of `handle`'s
    // outcomes.

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

    // `validateAgainst` calls back on the calling thread, so the reason is set
    // before this returns.
    private func refusal(of trust: SecTrust, against pinnedKeys: [SecKey]) throws -> String {
        var reason: String?
        trust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            if case .failure(let error) = result {
                reason = error.reason
            }
        }
        return try XCTUnwrap(reason)
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

// A requester that implements only `request` takes the protocol's default
// trust-root setters.
private struct RequestOnlyHttpRequester: HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        completion(.failure(ConnectionError.invalidServerResponse("unused")))
    }
}

// URLAuthenticationChallenge demands a sender. Nothing under test calls back
// into it.
private final class NullChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
