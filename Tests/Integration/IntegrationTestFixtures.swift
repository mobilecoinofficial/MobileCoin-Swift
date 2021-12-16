//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end multiline_function_chains

@testable import MobileCoin
import XCTest

enum IntegrationTestFixtures {
    static let network: NetworkPreset = .testNet
}

extension IntegrationTestFixtures {
    static let fee = McConstants.DEFAULT_MINIMUM_FEE

    static func fogReportUrlTyped() throws -> FogUrl {
        try FogUrl.make(string: network.fogReportUrl).get()
    }

    static func createAccountKey(accountIndex: Int = 0) throws -> AccountKey {
        let fogAuthoritySpki = try network.fogAuthoritySpki()

        let mnemonics = network.testAccountsMnemonics
        if mnemonics.count > accountIndex {
            let mnemonic = mnemonics[accountIndex]
            return try AccountKey.make(
                mnemonic: mnemonic,
                fogReportUrl: network.fogReportUrl,
                fogReportId: network.fogReportId,
                fogAuthoritySpki: fogAuthoritySpki).get()
        }

        let testAccountsPrivateKeys = network.testAccountsPrivateKeys
        if testAccountsPrivateKeys.count > accountIndex {
            let (viewPrivateKey, spendPrivateKey) = network.testAccountsPrivateKeys[accountIndex]
            return try AccountKey.make(
                viewPrivateKey: viewPrivateKey,
                spendPrivateKey: spendPrivateKey,
                fogReportUrl: network.fogReportUrl,
                fogReportId: network.fogReportId,
                fogAuthoritySpki: fogAuthoritySpki).get()
        }

        throw TestingError(
            "accountIndex (\(accountIndex)) exceeds bounds of test account list")
    }

    static func createPublicAddress(accountIndex: Int = 0) throws -> PublicAddress {
        try createAccountKey(accountIndex: accountIndex).publicAddress
    }

    static func createAccount(accountIndex: Int = 0) throws -> Account {
        try Account.make(accountKey: createAccountKey(accountIndex: accountIndex)).get()
    }

    static func createNetworkConfig(transportProtocol: TransportProtocol = TransportProtocol.http) throws -> NetworkConfig {
        try network.networkConfig(transportProtocol:transportProtocol)
    }

    static func createNetworkConfig(transportProtocol: TransportProtocol = TransportProtocol.http, trustRoots: [Data]) throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.setConsensusTrustRoots(trustRoots)
        networkConfig.setFogTrustRoots(trustRoots)
        return networkConfig
    }

    static func createNetworkConfigWithInvalidCredentials(transportProtocol: TransportProtocol = TransportProtocol.http) throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.consensusAuthorization = network.invalidCredentials
        networkConfig.fogUserAuthorization = network.invalidCredentials
        return networkConfig
    }

    static func createMobileCoinClientConfig(transportProtocol: TransportProtocol = .http) throws -> MobileCoinClient.Config {
        try MobileCoinClient.Config.make(
            consensusUrl: network.consensusUrl,
            consensusAttestation: network.consensusAttestation(),
            fogUrl: network.fogUrl,
            fogViewAttestation: network.fogViewAttestation(),
            fogKeyImageAttestation: network.fogLedgerAttestation(),
            fogMerkleProofAttestation: network.fogLedgerAttestation(),
            fogReportAttestation: network.fogReportAttestation(),
            transportProtocol: transportProtocol).get()
    }

    static func createMobileCoinClient(
        accountIndex: Int = 0,
        transportProtocol: TransportProtocol = .http
    ) throws -> MobileCoinClient {
        try createMobileCoinClient(accountKey: createAccountKey(accountIndex: accountIndex))
    }

    static func createMobileCoinClient(
        accountIndex: Int = 0,
        config: MobileCoinClient.Config,
        transportProtocol: TransportProtocol = .http
    ) throws -> MobileCoinClient {
        let accountKey = try createAccountKey(accountIndex: accountIndex)
        return try createMobileCoinClient(accountKey: accountKey, config: config)
    }

    static func createMobileCoinClient(accountKey: AccountKey, transportProtocol: TransportProtocol = .http) throws -> MobileCoinClient {
        let config = try createMobileCoinClientConfig(transportProtocol: transportProtocol)
        return try createMobileCoinClient(accountKey: accountKey, config: config)
    }

    static func createMobileCoinClient(
        accountKey: AccountKey,
        config: MobileCoinClient.Config,
        transportProtocol: TransportProtocol = .http
    ) throws -> MobileCoinClient {
        var mutableConfig = config
        mutableConfig.httpRequester = TestHttpRequester()
        let client = try MobileCoinClient.make(accountKey: accountKey, config: mutableConfig).get()
        if let consensusCredentials = network.consensusCredentials {
            client.setConsensusBasicAuthorization(
                username: consensusCredentials.username,
                password: consensusCredentials.password)
        }
        if let fogUserCredentials = network.fogUserCredentials {
            client.setFogBasicAuthorization(
                username: fogUserCredentials.username,
                password: fogUserCredentials.password)
        }
        return client
    }

    static func createMobileCoinClientWithBalance(
        accountIndex: Int = 0,
        expectation: XCTestExpectation,
        transportProtocol: TransportProtocol = .http,
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
        transportProtocol: TransportProtocol = .http,
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

    static func createServiceProvider(transportProtocol: TransportProtocol) throws -> ServiceProvider {
        let networkConfig = try createNetworkConfig(transportProtocol: transportProtocol)
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester ?? TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return DefaultServiceProvider(networkConfig: networkConfig, targetQueue: DispatchQueue.main, grpcConnectionFactory: grpcFactory, httpConnectionFactory: httpFactory)
    }

    static func createFogReportManager(transportProtocol: TransportProtocol) throws -> FogReportManager {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        return FogReportManager(serviceProvider: serviceProvider, targetQueue: DispatchQueue.main)
    }

    static func createFogResolverManager(transportProtocol: TransportProtocol) throws -> FogResolverManager {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        let reportAttestation = try createNetworkConfig(transportProtocol: transportProtocol).fogReportAttestation
        return FogResolverManager(
            fogReportAttestation: reportAttestation,
            serviceProvider: serviceProvider,
            targetQueue: DispatchQueue.main)
    }

    static func createFogViewKeyScanner(transportProtocol: TransportProtocol, accountKey: AccountKey) throws -> FogViewKeyScanner {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        return FogViewKeyScanner(
            accountKey: accountKey,
            fogBlockService: serviceProvider.fogBlockService)
    }
}
