//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end let_var_whitespace multiline_function_chains

@testable import MobileCoin
import NIOSSL
import XCTest

enum IntegrationTestFixtures {
    static let mobileCoinNetwork: MobileCoinNetwork = .mobiledev
}

extension IntegrationTestFixtures {
    static let isTestNet = mobileCoinNetwork.isTestNet

    static let consensusRequiresCredentials = mobileCoinNetwork.consensusRequiresCredentials
    static let fogRequiresCredentials = mobileCoinNetwork.fogRequiresCredentials
    static let isConsensusBehindLoadBalancer = mobileCoinNetwork.isConsensusBehindLoadBalancer

    static let consensusUrl = mobileCoinNetwork.consensusUrl
    static let fogUrl = mobileCoinNetwork.fogUrl

    static let fogReportUrl = mobileCoinNetwork.fogReportUrl
    static let fogReportId = mobileCoinNetwork.fogReportId
    static func fogAuthoritySpki() throws -> Data { try mobileCoinNetwork.fogAuthoritySpki() }

    static let attestationConfig = mobileCoinNetwork.attestationConfig

    static func trustRootsBytes() throws -> Data { try mobileCoinNetwork.trustRootsBytes() }
    static func consensusTrustRoots() throws -> [NIOSSLCertificate]
    { try mobileCoinNetwork.consensusTrustRoots() }
    static func fogTrustRoots() throws -> [NIOSSLCertificate]
    { try mobileCoinNetwork.fogTrustRoots() }

    static let consensusCredentials = mobileCoinNetwork.consensusCredentials
    static let fogCredentials = mobileCoinNetwork.fogCredentials
    static let invalidCredentials = mobileCoinNetwork.invalidCredentials

    static let fee = McConstants.MINIMUM_FEE

    static let rootEntropies = mobileCoinNetwork.rootEntropies

    static func fogReportUrlTyped() throws -> FogUrl {
        try FogUrl.make(string: fogReportUrl).get()
    }

    static func createAccountKey(accountIndex: Int = 0) throws -> AccountKey {
        let fogAuthoritySpki = try self.fogAuthoritySpki()
        return try AccountKey.make(
            rootEntropy: rootEntropies[accountIndex],
            fogReportUrl: fogReportUrl,
            fogReportId: fogReportId,
            fogAuthoritySpki: fogAuthoritySpki).get()
    }

    static func createPublicAddress(accountIndex: Int = 0) throws -> PublicAddress {
        try createAccountKey(accountIndex: accountIndex).publicAddress
    }

    static func createAccount(accountIndex: Int = 0) throws -> Account {
        try Account.make(accountKey: createAccountKey(accountIndex: accountIndex)).get()
    }

    static func createNetworkConfig() throws -> NetworkConfig {
        var networkConfig = try NetworkConfig.make(
            consensusUrl: consensusUrl,
            fogUrl: fogUrl,
            attestation: attestationConfig).get()
        networkConfig.consensusTrustRoots = try self.consensusTrustRoots()
        networkConfig.fogTrustRoots = try self.fogTrustRoots()
        networkConfig.consensusAuthorization = consensusCredentials
        networkConfig.fogAuthorization = fogCredentials
        return networkConfig
    }

    static func createNetworkConfig(trustRoots: [NIOSSLCertificate]) throws -> NetworkConfig {
        var networkConfig = try createNetworkConfig()
        networkConfig.consensusTrustRoots = trustRoots
        networkConfig.fogTrustRoots = trustRoots
        return networkConfig
    }

    static func createNetworkConfigWithInvalidCredentials() throws -> NetworkConfig {
        var networkConfig = try createNetworkConfig()
        networkConfig.consensusAuthorization = invalidCredentials
        networkConfig.fogAuthorization = invalidCredentials
        return networkConfig
    }

    static func createMobileCoinClientConfig() throws -> MobileCoinClient.Config {
        try MobileCoinClient.Config.make(
            consensusUrl: consensusUrl,
            consensusAttestation: attestationConfig.consensus,
            fogUrl: fogUrl,
            fogViewAttestation: attestationConfig.fogView,
            fogKeyImageAttestation: attestationConfig.fogKeyImage,
            fogMerkleProofAttestation: attestationConfig.fogMerkleProof,
            fogReportAttestation: attestationConfig.fogReport).get()
    }

    static func createMobileCoinClient(accountIndex: Int = 0) throws -> MobileCoinClient {
        try createMobileCoinClient(accountKey: createAccountKey(accountIndex: accountIndex))
    }

    static func createMobileCoinClient(
        accountIndex: Int = 0,
        config: MobileCoinClient.Config
    ) throws -> MobileCoinClient {
        let accountKey = try createAccountKey(accountIndex: accountIndex)
        return try createMobileCoinClient(accountKey: accountKey, config: config)
    }

    static func createMobileCoinClient(accountKey: AccountKey) throws -> MobileCoinClient {
        let config = try createMobileCoinClientConfig()
        return try createMobileCoinClient(accountKey: accountKey, config: config)
    }

    static func createMobileCoinClient(
        accountKey: AccountKey,
        config: MobileCoinClient.Config
    ) throws -> MobileCoinClient {
        let client = try MobileCoinClient.make(accountKey: accountKey, config: config).get()
        client.setConsensusBasicAuthorization(
            username: consensusCredentials.username,
            password: consensusCredentials.password)
        client.setFogBasicAuthorization(
            username: fogCredentials.username,
            password: fogCredentials.password)
        return client
    }

    static func createMobileCoinClientWithBalance(
        accountIndex: Int = 0,
        expectation: XCTestExpectation,
        completion: @escaping (MobileCoinClient) -> Void
    ) throws {
        let accountKey = try createAccountKey(accountIndex: accountIndex)
        return try createMobileCoinClientWithBalance(
            accountKey: accountKey,
            expectation: expectation,
            completion: completion)
    }

    static func createMobileCoinClientWithBalance(
        accountKey: AccountKey,
        expectation: XCTestExpectation,
        completion: @escaping (MobileCoinClient) -> Void
    ) throws {
        let client = try createMobileCoinClient(accountKey: accountKey)
        client.updateBalance {
            guard let balance = $0.successOrFulfill(expectation: expectation) else { return }
            guard let picoMob = try? XCTUnwrap(balance.amountPicoMob()) else
                { expectation.fulfill(); return }
            XCTAssertGreaterThan(picoMob, 0)
            guard picoMob > 0 else { expectation.fulfill(); return }

            completion(client)
        }
    }

    static func createServiceProvider() throws -> ServiceProvider {
        let networkConfig = try createNetworkConfig()
        return DefaultServiceProvider(networkConfig: networkConfig, targetQueue: DispatchQueue.main)
    }

    static func createFogReportManager() throws -> FogReportManager {
        let serviceProvider = try createServiceProvider()
        return FogReportManager(serviceProvider: serviceProvider, targetQueue: DispatchQueue.main)
    }

    static func createFogResolverManager() throws -> FogResolverManager {
        let serviceProvider = try createServiceProvider()
        let reportAttestation = try createNetworkConfig().fogReportAttestation
        return FogResolverManager(
            fogReportAttestation: reportAttestation,
            serviceProvider: serviceProvider,
            targetQueue: DispatchQueue.main)
    }

    static func createFogViewKeyScanner(accountKey: AccountKey) throws -> FogViewKeyScanner {
        let serviceProvider = try createServiceProvider()
        return FogViewKeyScanner(
            accountKey: accountKey,
            fogBlockService: serviceProvider.fogBlockService)
    }
}
