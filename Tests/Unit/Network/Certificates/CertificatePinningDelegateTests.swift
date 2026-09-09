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

class CertificatePinningDelegateTests: XCTestCase {

    // The cases below drive both delegate shims across `handle`'s outcomes.

    func testServerTrustMatchingAPinnedKeyIsAccepted() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(
            try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid),
            hosts: [TestHost.pinned])

        let result = try answer(of: requester, against: fixture.secTrust)

        XCTAssertEqual(result.disposition, .useCredential)
        XCTAssertNotNil(result.credential)
    }

    // The consensus roots pin this host and don't carry the fixture chain, so
    // the challenge will be refused.
    func testServerTrustMatchingNoPinnedKeyIsCancelled() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setConsensusTrustRoots(
            try SecCertificateTests.Fixtures.AlphaNet.certificates(.wrong),
            hosts: [TestHost.pinned])

        XCTAssertEqual(
            try answer(of: requester, against: fixture.secTrust).disposition,
            .cancelAuthenticationChallenge)
    }

    // The fog roots carry this fixture chain and the consensus roots don't, so
    // the consensus host will be refused while the fog host is accepted.
    func testTheRootsOfOneHostDoNotPinAnother() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(
            try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid), hosts: [TestHost.fog])
        requester.setConsensusTrustRoots(
            try SecCertificateTests.Fixtures.AlphaNet.certificates(.wrong),
            hosts: [TestHost.consensus])

        let refused = try answer(
            of: requester, against: fixture.secTrust, host: TestHost.consensus)
        XCTAssertEqual(refused.disposition, .cancelAuthenticationChallenge)
        let accepted = try answer(of: requester, against: fixture.secTrust, host: TestHost.fog)
        XCTAssertEqual(accepted.disposition, .useCredential)
    }

    // Neither setter names the challenged host, so every pinned root takes part
    // in its challenge.
    func testAHostNoSetterNamedIsJudgedAgainstEveryPinnedRoot() throws {
        let fixture = try SecCertificateTests.Fixtures.AlphaNet()
        let requester = DefaultHttpRequester()
        requester.setFogTrustRoots(
            try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid), hosts: [TestHost.fog])
        let judged = try answer(of: requester, against: fixture.secTrust, host: TestHost.consensus)
        XCTAssertEqual(judged.disposition, .useCredential)
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

    // Distinct fog and consensus roots let each lookup below name the set or
    // sets that answered it.
    func testTheSetThatNamesAHostAnswersForIt() throws {
        let requester = DefaultHttpRequester()
        let delegate = try pinningDelegate(of: requester)
        let fog = try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid)
        let consensus = try SecCertificateTests.Fixtures.AlphaNet.certificates(.wrong)
        XCTAssertNotEqual(fog.publicKeys, consensus.publicKeys)

        requester.setFogTrustRoots(fog, hosts: [TestHost.fog.uppercased()])
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.consensus), fog.publicKeys)

        requester.setConsensusTrustRoots(consensus, hosts: [TestHost.consensus + "."])
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.fog), fog.publicKeys)
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.consensus + ".."), consensus.publicKeys)

        let noKeys = try XCTUnwrap(SecSSLCertificates(trustRootBytes: []))
        requester.setFogTrustRoots(noKeys, hosts: [TestHost.fog])
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.fog), consensus.publicKeys)

        requester.setFogTrustRoots(nil, hosts: [])
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.fog), consensus.publicKeys)

        requester.setFogTrustRoots(fog, hosts: [TestHost.consensus])
        XCTAssertEqual(
            delegate.pinnedKeys(for: TestHost.consensus),
            fog.publicKeys + consensus.publicKeys)
        XCTAssertEqual(
            delegate.pinnedKeys(for: TestHost.pinned),
            fog.publicKeys + consensus.publicKeys)

        // An empty or all-dots host name pins nothing, so fog still answers
        // as part of the union for the empty host.
        requester.setFogTrustRoots(fog, hosts: ["", "."])
        XCTAssertEqual(
            delegate.pinnedKeys(for: ""),
            fog.publicKeys + consensus.publicKeys)
    }

    // A Unicode host and its punycode form parse to the same host string, so
    // a set built from either one pins the same challenge host.
    func testAUnicodeHostAndItsPunycodeFormShareTheSamePin() throws {
        let requester = DefaultHttpRequester()
        let delegate = try pinningDelegate(of: requester)
        let fog = try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid)

        let unicodeResult = MobileCoinUrl<FogScheme>.make(string: "fog://\u{4f8b}\u{3048}.jp")
        let unicodeHost = try unicodeResult.get().host
        let punycodeResult = MobileCoinUrl<FogScheme>.make(string: "fog://xn--r8jz45g.jp")
        let punycodeHost = try punycodeResult.get().host
        XCTAssertEqual(unicodeHost, punycodeHost)

        requester.setFogTrustRoots(fog, hosts: [punycodeHost])
        XCTAssertEqual(delegate.pinnedKeys(for: unicodeHost), fog.publicKeys)
    }

    // A nil field leaves the requester's own root in place, while a named
    // field replaces it.
    func testSetAllTrustRootsLeavesAnUnnamedFieldInPlace() throws {
        let requester = DefaultHttpRequester()
        let delegate = try pinningDelegate(of: requester)
        let fog = try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid)
        let consensus = try SecCertificateTests.Fixtures.AlphaNet.certificates(.wrong)
        XCTAssertNotEqual(fog.publicKeys, consensus.publicKeys)

        requester.setConsensusTrustRoots(consensus, hosts: [TestHost.consensus])
        requester.setAllTrustRoots(
            fog: (certificates: fog, hosts: [TestHost.fog]),
            consensus: nil,
            mistyswap: nil)

        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.fog), fog.publicKeys)
        XCTAssertEqual(delegate.pinnedKeys(for: TestHost.consensus), consensus.publicKeys)
    }

    private func answer(
        of requester: DefaultHttpRequester,
        against trust: SecTrust?,
        host: String = TestHost.pinned
    ) throws -> (disposition: URLSession.AuthChallengeDisposition?, credential: URLCredential?) {
        let space: URLProtectionSpace
        if let trust = trust {
            space = TrustingProtectionSpace(trust: trust, host: host)
        } else {
            space = URLProtectionSpace(
                host: host,
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
