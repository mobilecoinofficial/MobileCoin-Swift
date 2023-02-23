//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end multiline_function_chains

@testable import MobileCoin
import XCTest

enum IntegrationTestFixtures {
    static let network: NetworkPreset = NetworkConfigFixtures.network
}

extension IntegrationTestFixtures {
    static let invalidConsensusUrl = NetworkConfigFixtures.invalidConsensusUrl
    static let invalidFogUrl = NetworkConfigFixtures.invalidFogUrl

    static let fee = McConstants.DEFAULT_MINIMUM_FEE

    static func fogReportUrlTyped() throws -> FogUrl {
        try FogUrl.make(string: network.fogReportUrl).get()
    }

    static var testAccountCount: Int {
        switch network {
        case .dynamic:
            return network.testAccountRootEntropies.count
        default:
            // the createAccountKey method will first try mnemonics, then private keys
            return max(network.testAccountsMnemonics.count, network.testAccountsPrivateKeys.count)
        }
    }

    static func createAccountKey(accountIndex: Int = 0) throws -> AccountKey {
        let fogAuthoritySpki = try network.fogAuthoritySpki()

        switch network {
        case .dynamic:
            let rootEntropies = network.testAccountRootEntropies
            if rootEntropies.count > accountIndex {
                let entropy = rootEntropies[accountIndex]
                return try AccountKey.make(
                    rootEntropy: entropy,
                    fogReportUrl: network.fogReportUrl,
                    fogReportId: network.fogReportId,
                    fogAuthoritySpki: fogAuthoritySpki).get()
            }

        default:
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
                let tuple = network.testAccountsPrivateKeys[accountIndex]
                let (viewPrivateKey, spendPrivateKey) = tuple
                return try AccountKey.make(
                    viewPrivateKey: viewPrivateKey,
                    spendPrivateKey: spendPrivateKey,
                    fogReportUrl: network.fogReportUrl,
                    fogReportId: network.fogReportId,
                    fogAuthoritySpki: fogAuthoritySpki).get()
            }
        }

        throw TestingError(
            "accountIndex (\(accountIndex)) exceeds bounds of test account list")
    }

    static func createPublicAddress(accountIndex: Int = 0) throws -> PublicAddress {
        try createAccountKey(accountIndex: accountIndex).publicAddress
    }

    static func createAccount(
        accountIndex: Int = 0,
        syncChecker: FogSyncCheckable = FogSyncChecker()
    ) throws -> Account {
        try Account.make(
            accountKey: createAccountKey(accountIndex: accountIndex),
            syncChecker: syncChecker).get()
    }

    static func createMobileCoinClientConfig(using transportProtocol: TransportProtocol)
    throws -> MobileCoinClient.Config {
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

    static func createMobileCoinClientConfigWithPartialValidConsensusUrls(
        using transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient.Config {
        try MobileCoinClient.Config.make(
            consensusUrls: [invalidConsensusUrl, network.consensusUrl],
            consensusAttestation: network.consensusAttestation(),
            fogUrls: [network.fogUrl],
            fogViewAttestation: network.fogViewAttestation(),
            fogKeyImageAttestation: network.fogLedgerAttestation(),
            fogMerkleProofAttestation: network.fogLedgerAttestation(),
            fogReportAttestation: network.fogReportAttestation(),
            transportProtocol: transportProtocol).get()
    }

    static func createMobileCoinClientConfigWithPartialValidFogUrls(
        using transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient.Config {
        try MobileCoinClient.Config.make(
            consensusUrls: [network.consensusUrl],
            consensusAttestation: network.consensusAttestation(),
            fogUrls: [invalidFogUrl, network.fogUrl],
            fogViewAttestation: network.fogViewAttestation(),
            fogKeyImageAttestation: network.fogLedgerAttestation(),
            fogMerkleProofAttestation: network.fogLedgerAttestation(),
            fogReportAttestation: network.fogReportAttestation(),
            transportProtocol: transportProtocol).get()
    }

    static func createMobileCoinClientWithPartialValidConsensusUrls(
        using transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        let config = try createMobileCoinClientConfigWithPartialValidConsensusUrls(
            using: transportProtocol)
        return try createMobileCoinClient(config: config, transportProtocol: transportProtocol)
    }

    static func createMobileCoinClientWithPartialValidFogUrls(
        using transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        let config = try createMobileCoinClientConfigWithPartialValidFogUrls(
            using: transportProtocol)
        return try createMobileCoinClient(config: config, transportProtocol: transportProtocol)
    }

    static func createMobileCoinClient(
        accountIndex: Int = 0,
        fogSyncChecker: FogSyncCheckable = FogSyncChecker(),
        using transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        try createMobileCoinClient(
            accountKey: createAccountKey(accountIndex: accountIndex),
            fogSyncChecker: fogSyncChecker,
            transportProtocol: transportProtocol)
    }

    static func createMobileCoinClient(
        accountIndex: Int = 0,
        config: MobileCoinClient.Config,
        transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        let accountKey = try createAccountKey(accountIndex: accountIndex)
        return try createMobileCoinClient(
            accountKey: accountKey,
            config: config,
            transportProtocol: transportProtocol)
    }

    static func createMobileCoinClient(
        accountKey: AccountKey,
        fogSyncChecker: FogSyncCheckable = FogSyncChecker(),
        transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        var mutableConfig = try createMobileCoinClientConfig(using: transportProtocol)
        mutableConfig.fogSyncCheckable = fogSyncChecker
        return try createMobileCoinClient(
            accountKey: accountKey,
            config: mutableConfig,
            transportProtocol: transportProtocol)
    }

    static func createMobileCoinClient(
        accountKey: AccountKey,
        config: MobileCoinClient.Config,
        transportProtocol: TransportProtocol
    ) throws -> MobileCoinClient {
        var mutableConfig = config
        mutableConfig.httpRequester = DefaultHttpRequester()
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
        transportProtocol: TransportProtocol,
        completion: @escaping (MobileCoinClient) -> Void
    ) throws {
        let accountKey = try createAccountKey(accountIndex: accountIndex)
        return try createMobileCoinClientWithBalance(
            accountKey: accountKey,
            expectation: expectation,
            transportProtocol: transportProtocol,
            completion: completion)
    }

    static func createMobileCoinClientWithBalance(
        accountKey: AccountKey,
        expectation: XCTestExpectation,
        transportProtocol: TransportProtocol,
        completion: @escaping (MobileCoinClient) -> Void
    ) throws {
        let client =
            try createMobileCoinClient(accountKey: accountKey, transportProtocol: transportProtocol)
        client.updateBalances {
            guard let balances = $0.successOrFulfill(expectation: expectation) else { return }
            guard let picoMob = try? XCTUnwrap(balances.mobBalance.amount()) else
                { expectation.fulfill(); return }
            XCTAssertGreaterThan(picoMob, 0)
            guard picoMob > 0 else { expectation.fulfill(); return }

            completion(client)
        }
    }

    static func createServiceProvider(transportProtocol: TransportProtocol)
    throws -> ServiceProvider {
        let networkConfig = try NetworkConfigFixtures.create(using: transportProtocol)
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return DefaultServiceProvider(
            networkConfig: networkConfig,
            targetQueue: DispatchQueue.main,
            grpcConnectionFactory: grpcFactory,
            httpConnectionFactory: httpFactory)
    }

    static func createFogReportManager(transportProtocol: TransportProtocol)
    throws -> FogReportManager {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        return FogReportManager(serviceProvider: serviceProvider, targetQueue: DispatchQueue.main)
    }

    static func createFogResolverManager(transportProtocol: TransportProtocol)
    throws -> FogResolverManager {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        let reportAttestation =
            try NetworkConfigFixtures.create(using: transportProtocol).fogReportAttestation
        return FogResolverManager(
            fogReportAttestation: reportAttestation,
            serviceProvider: serviceProvider,
            targetQueue: DispatchQueue.main)
    }

    static func createFogViewKeyScanner(
        transportProtocol: TransportProtocol,
        accountKey: AccountKey
    ) throws -> FogViewKeyScanner {
        let serviceProvider = try createServiceProvider(transportProtocol: transportProtocol)
        return FogViewKeyScanner(
            accountKey: accountKey,
            fogBlockService: serviceProvider.fogBlockService)
    }

    static func createServiceProvider(
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    ) throws -> ServiceProvider {

        let networkConfig = try NetworkConfigFixtures.create(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return DefaultServiceProvider(
            networkConfig: networkConfig,
            targetQueue: DispatchQueue.main,
            grpcConnectionFactory: grpcFactory,
            httpConnectionFactory: httpFactory)
    }
}
