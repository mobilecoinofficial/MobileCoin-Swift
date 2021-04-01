//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end multiline_function_chains

@testable import MobileCoin
import NIOSSL
import XCTest

enum IntegrationTestFixtures {
    static let network: MobileCoinNetwork = .alpha
}

extension IntegrationTestFixtures {
    static let fee = McConstants.MINIMUM_FEE

    static func fogReportUrlTyped() throws -> FogUrl {
        try FogUrl.make(string: network.fogReportUrl).get()
    }

    static func createAccountKey(accountIndex: Int = 0) throws -> AccountKey {
        let (viewPrivateKey, spendPrivateKey) = network.accountPrivateKeys[accountIndex]
        let fogAuthoritySpki = try network.fogAuthoritySpki()
        return try AccountKey.make(
            viewPrivateKey: viewPrivateKey,
            spendPrivateKey: spendPrivateKey,
            fogReportUrl: network.fogReportUrl,
            fogReportId: network.fogReportId,
            fogAuthoritySpki: fogAuthoritySpki).get()
    }

    static func createPublicAddress(accountIndex: Int = 0) throws -> PublicAddress {
        try createAccountKey(accountIndex: accountIndex).publicAddress
    }

    static func createAccount(accountIndex: Int = 0) throws -> Account {
        try Account.make(accountKey: createAccountKey(accountIndex: accountIndex)).get()
    }

    static func createNetworkConfig() throws -> NetworkConfig {
        try network.networkConfig()
    }

    static func createNetworkConfig(trustRoots: [NIOSSLCertificate]) throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.consensusTrustRoots = trustRoots
        networkConfig.fogTrustRoots = trustRoots
        return networkConfig
    }

    static func createNetworkConfigWithInvalidCredentials() throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.consensusAuthorization = network.invalidCredentials
        networkConfig.fogAuthorization = network.invalidCredentials
        return networkConfig
    }

    static func createMobileCoinClientConfig() throws -> MobileCoinClient.Config {
        try MobileCoinClient.Config.make(
            consensusUrl: network.consensusUrl,
            consensusAttestation: network.consensusAttestation(),
            fogUrl: network.fogUrl,
            fogViewAttestation: network.fogViewAttestation(),
            fogKeyImageAttestation: network.fogLedgerAttestation(),
            fogMerkleProofAttestation: network.fogLedgerAttestation(),
            fogReportAttestation: network.fogReportAttestation()).get()
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
        if let consensusCredentials = network.consensusCredentials {
            client.setConsensusBasicAuthorization(
                username: consensusCredentials.username,
                password: consensusCredentials.password)
        }
        if let fogCredentials = network.fogCredentials {
            client.setFogBasicAuthorization(
                username: fogCredentials.username,
                password: fogCredentials.password)
        }
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
