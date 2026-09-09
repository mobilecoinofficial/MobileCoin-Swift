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

// The hosts a test pins against. `pinned` covers a case where one host is
// enough, and `fog` and `consensus` separate the two setters' roots.
enum TestHost {
    static let pinned = "example.com"
    static let fog = "fog.example.com"
    static let consensus = "consensus.example.com"
}

func pinningDelegate(
    of requester: DefaultHttpRequester
) throws -> CertificatePinningDelegate {
    try XCTUnwrap(requester.session.delegate as? CertificatePinningDelegate)
}

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

    // Exact equality proves the message carries the index alone.
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

    // Roots the config stored with no requester present reach the first
    // requester it is given, each in the field its own setter names.
    func testTrustRootsSetBeforeTheRequesterReachIt() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()
        config.httpRequester = nil
        XCTAssertSuccess(config.setConsensusTrustRoots(fixture.trustRootsBytes))
        XCTAssertSuccess(config.setFogTrustRoots([fixture.wrongTrustRootBytes]))

        let requester = MockFailingHttpRequester()
        config.httpRequester = requester

        let consensus = try XCTUnwrap(config.consensusTrustRoots[.http] as? SecSSLCertificates)
        let fog = try XCTUnwrap(config.fogTrustRoots[.http] as? SecSSLCertificates)
        XCTAssertNotEqual(consensus.publicKeys, fog.publicKeys)
        XCTAssertEqual(requester.consensusTrustRoots?.publicKeys, consensus.publicKeys)
        XCTAssertEqual(requester.fogTrustRoots?.publicKeys, fog.publicKeys)
        XCTAssertEqual(requester.consensusHosts, config.consensusUrls.map(\.host))
        XCTAssertEqual(requester.fogHosts, config.fogUrls.map(\.host))
    }

    // The config's setters and the requester's share their names, so distinct
    // roots are what will catch a swapped pair once a requester is present.
    func testEachConfigSetterPushesToItsOwnRequesterField() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()
        let requester = MockFailingHttpRequester()
        config.httpRequester = requester

        XCTAssertSuccess(config.setConsensusTrustRoots(fixture.trustRootsBytes))
        XCTAssertSuccess(config.setFogTrustRoots([fixture.wrongTrustRootBytes]))

        let consensus = try XCTUnwrap(config.consensusTrustRoots[.http] as? SecSSLCertificates)
        let fog = try XCTUnwrap(config.fogTrustRoots[.http] as? SecSSLCertificates)
        XCTAssertNotEqual(consensus.publicKeys, fog.publicKeys)
        XCTAssertEqual(requester.consensusTrustRoots?.publicKeys, consensus.publicKeys)
        XCTAssertEqual(requester.fogTrustRoots?.publicKeys, fog.publicKeys)
        XCTAssertEqual(requester.consensusHosts, config.consensusUrls.map(\.host))
        XCTAssertEqual(requester.fogHosts, config.fogUrls.map(\.host))
    }

    // The config's fog and consensus URLs name different hosts, so each host
    // will answer with the keys its own setter pushed.
    func testAConfigWithNoRequesterFillsInOneThatTakesItsRoots() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()
        config.httpRequester = nil
        XCTAssertSuccess(config.setConsensusTrustRoots(fixture.trustRootsBytes))
        XCTAssertSuccess(config.setFogTrustRoots([fixture.wrongTrustRootBytes]))

        let requester = try XCTUnwrap(config.filledHttpRequester() as? DefaultHttpRequester)

        let fog = try XCTUnwrap(config.fogTrustRoots[.http] as? SecSSLCertificates)
        let consensus = try XCTUnwrap(config.consensusTrustRoots[.http] as? SecSSLCertificates)
        XCTAssertNotEqual(fog.publicKeys, consensus.publicKeys)
        let delegate = try pinningDelegate(of: requester)
        let fogUrlHost = try XCTUnwrap(config.fogUrls.first).host
        let consensusUrlHost = try XCTUnwrap(config.consensusUrls.first).host
        XCTAssertNotEqual(fogUrlHost, consensusUrlHost)
        XCTAssertEqual(delegate.pinnedKeys(for: fogUrlHost), fog.publicKeys)
        XCTAssertEqual(delegate.pinnedKeys(for: consensusUrlHost), consensus.publicKeys)
    }

    // A consumer's own requester decides how the connections handle TLS, so the
    // fill answers with that one and keeps it in the config.
    func testAConfigKeepsTheRequesterItAlreadyHolds() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let requester = MockFailingHttpRequester()
        config.httpRequester = requester

        XCTAssertTrue((config.filledHttpRequester() as? MockFailingHttpRequester) === requester)
        XCTAssertTrue((config.httpRequester as? MockFailingHttpRequester) === requester)
    }

    // Roots the config doesn't hold leave the requester's own in place, so a
    // requester that arrives with keys keeps pinning against them.
    func testAConfigWithNoRootsLeavesTheRequestersOwnInPlace() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        config.consensusTrustRoots[.http] = nil
        config.fogTrustRoots[.http] = nil
        let requester = DefaultHttpRequester()
        let roots = try SecCertificateTests.Fixtures.AlphaNet.certificates(.valid)
        requester.setFogTrustRoots(roots, hosts: [TestHost.fog])

        config.httpRequester = requester

        XCTAssertEqual(
            try pinningDelegate(of: requester).pinnedKeys(for: TestHost.fog),
            roots.publicKeys)
    }

    // A client built from a config carrying its own requester reaches the
    // connection factory holding that exact instance.
    func testTheClientReachesTheConfigsOwnRequester() throws {
        var networkConfig = try NetworkConfigFixtures.create(using: .http)
        let requester = MockFailingHttpRequester()
        networkConfig.httpRequester = requester
        let config = MobileCoinClient.Config(networkConfig: networkConfig)
        let accountKey = try AccountKey.Fixtures.TestNet().accountKey

        let client = try MobileCoinClient.make(accountKey: accountKey, config: config).get()
        let serviceProvider = try XCTUnwrap(client.serviceProvider as? DefaultServiceProvider)

        XCTAssertTrue(
            (serviceProvider.httpConnectionFactory.requester as? MockFailingHttpRequester)
                === requester)
    }

    // A refused set keeps the pinned http roots the call before it stored, so a
    // failure won't replace them with roots nothing accepted.
    func testRefusedTrustRootsLeaveThePinnedRootsInPlace() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()
        XCTAssertSuccess(config.setConsensusTrustRoots(fixture.trustRootsBytes))
        let pinned = try XCTUnwrap(config.consensusTrustRoots[.http] as? SecSSLCertificates)

        config.httpRequester = RefusingHttpRequester()

        XCTAssertFailure(config.setConsensusTrustRoots([fixture.wrongTrustRootBytes]))
        XCTAssertEqual(
            (config.consensusTrustRoots[.http] as? SecSSLCertificates)?.publicKeys,
            pinned.publicKeys)
    }

    // A refused fog set keeps the pinned fog roots the call before it stored, so
    // a failure won't replace them with roots nothing accepted.
    func testRefusedFogTrustRootsLeaveThePinnedRootsInPlace() throws {
        var config = try NetworkConfigFixtures.create(using: .http)
        let fixture = try NetworkConfig.Fixtures.TrustRoots()
        XCTAssertSuccess(config.setFogTrustRoots(fixture.trustRootsBytes))
        let pinned = try XCTUnwrap(config.fogTrustRoots[.http] as? SecSSLCertificates)

        config.httpRequester = RefusingHttpRequester()

        XCTAssertFailure(config.setFogTrustRoots([fixture.wrongTrustRootBytes]))
        XCTAssertEqual(
            (config.fogTrustRoots[.http] as? SecSSLCertificates)?.publicKeys,
            pinned.publicKeys)
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
}
