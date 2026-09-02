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

    // The test above asserts wiring. These three assert that the wiring pins,
    // because each of the regressions below leaves the wiring intact.

    // Flipping this constant turns pinning off everywhere.
    func testCertificatePinningIsEnabled() {
        XCTAssertTrue(DefaultHttpRequester.certPinningEnabled)
    }

    // The trust root setters are the seam this branch introduced. A setter that
    // reverts to a no-op leaves the delegate holding no keys, and `handle` then
    // falls through to default handling with nothing to show for it.
    func testTrustRootsReachThePinnedKeys() throws {
        let trustRoots = try NetworkPreset.trustRootsBytes()
        let certificates = try XCTUnwrap(try SecSSLCertificates(trustRootBytes: trustRoots))
        let delegate = CertificatePinningDelegate()

        XCTAssertTrue(delegate.pinnedKeys.isEmpty)

        delegate.setFogTrustRoots(certificates)
        let afterFog = delegate.pinnedKeys.count
        XCTAssertGreaterThan(afterFog, 0)

        delegate.setConsensusTrustRoots(certificates)
        XCTAssertGreaterThan(delegate.pinnedKeys.count, afterFog)
    }

    // A challenge carrying no server trust must be cancelled. Gutting `handle`
    // to plain default handling passes every other test in this file.
    func testChallengeWithoutServerTrustIsCancelled() {
        let space = URLProtectionSpace(
            host: "example.com",
            port: 443,
            protocol: NSURLProtectionSpaceHTTPS,
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = URLAuthenticationChallenge(
            protectionSpace: space,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: NullChallengeSender())

        var disposition: URLSession.AuthChallengeDisposition?
        CertificatePinningDelegate().handle(challenge: challenge) { result, _ in
            disposition = result
        }

        XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
    }
}

// URLAuthenticationChallenge demands a sender. Nothing under test calls back
// into it.
private final class NullChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
