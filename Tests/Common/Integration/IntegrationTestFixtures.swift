//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_default_parameter_at_end multiline_function_chains

@testable import MobileCoin
import XCTest

public enum IntegrationTestFixtures {
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
        return DefaultServiceProvider(
            networkConfig: networkConfig,
            targetQueue: DispatchQueue.main,
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
        return DefaultServiceProvider(
            networkConfig: networkConfig,
            targetQueue: DispatchQueue.main,
            httpConnectionFactory: httpFactory)
    }
}

extension IntegrationTestFixtures {
    static func createDynamicClient(
        transportProtocol: TransportProtocol,
        testName: String,
        purpose: String
    ) throws -> (AccountKey, MobileCoinClient) {
        let config = try createMobileCoinClientConfig(using: transportProtocol)
        return try createDynamicClient(
            transportProtocol: transportProtocol,
            testName: testName,
            purpose: purpose,
            config: config)
    }

    static func getTestAccountSeed() -> String? {
        guard let seed = ProcessInfo.processInfo.combined("testAccountSeed") else {
            fatalError("Unable to get b64Seed value")
        }
        return seed
    }
    static func createDynamicClient(
        transportProtocol: TransportProtocol,
        testName: String,
        purpose: String,
        config: MobileCoinClient.Config
    ) throws -> (AccountKey, MobileCoinClient) {
        guard let testAcountB64Seed = getTestAccountSeed() else {
            fatalError("Unable to get b64Seed value")
        }
        guard let seedData = Data(base64Encoded: testAcountB64Seed) else {
            fatalError("Unable to create seedData from b64Seed")
        }
        guard let seed32 = Data32(seedData) else {
            fatalError("Unable to create seed32 from seedData")
        }

        // The array position selects the account derived from the seed, so every
        // entry stays where it is. Only the HTTP rows are looked up.
        let clientNames = [
            "0_HTTP_transactionDoubleSubmissionFails_Client",
            "1_HTTP_transactionDoubleSubmissionFails_Recipient",
            "2_UNUSED_transactionDoubleSubmissionFails_Client",
            "3_UNUSED_transactionDoubleSubmissionFails_Recipient",
            "4_HTTP_transactionStatusFailsWhenInputIsAlreadySpent_Client",
            "5_HTTP_transactionStatusFailsWhenInputIsAlreadySpent_Recipient",
            "6_UNUSED_transactionStatusFailsWhenInputIsAlreadySpent_Client",
            "7_UNUSED_transactionStatusFailsWhenInputIsAlreadySpent_Recipient",
            "8_HTTP_submitTransaction_Client",
            "9_HTTP_submitTransaction_Recipient",
            "10_UNUSED_submitTransaction_Client",
            "11_UNUSED_submitTransaction_Recipient",
            "12_HTTP_submitMobUSDTransaction_Client",
            "13_HTTP_submitMobUSDTransaction_Recipient",
            "14_UNUSED_submitMobUSDTransaction_Client",
            "15_UNUSED_submitMobUSDTransaction_Recipient",
            "16_HTTP_cancelSignedContingentInput_Creator",
            "17_HTTP_cancelSignedContingentInput_Consumer",
            "18_UNUSED_cancelSignedContingentInput_Creator",
            "19_UNUSED_cancelSignedContingentInput_Consumer",
            "20_HTTP_submitSignedContingentInputTransaction_Creator",
            "21_HTTP_submitSignedContingentInputTransaction_Consumer",
            "22_UNUSED_submitSignedContingentInputTransaction_Creator",
            "23_UNUSED_submitSignedContingentInputTransaction_Consumer",
            "24_HTTP_selfPaymentBalanceChange_Client",
            "25_UNUSED_selfPaymentBalanceChange_Client",
            "26_HTTP_selfPaymentBalanceChangeFeeLevel_Client",
            "27_UNUSED_selfPaymentBalanceChangeFeeLevel_Client",
            "28_HTTP_transactionStatus_Client",
            "29_HTTP_transactionStatus_Recipient",
            "30_UNUSED_transactionStatus_Client",
            "31_UNUSED_transactionStatus_Recipient",
            "32_HTTP_transactionTxOutStatus_Client",
            "33_HTTP_transactionTxOutStatus_Recipient",
            "34_UNUSED_transactionTxOutStatus_Client",
            "35_UNUSED_transactionTxOutStatus_Recipient",
            "36_HTTP_receiptStatus_Client",
            "37_HTTP_receiptStatus_Recipient",
            "38_UNUSED_receiptStatus_Client",
            "39_UNUSED_receiptStatus_Recipient",
            "40_HTTP_consensusTrustRootWorks_Client",
            "41_HTTP_consensusTrustRootWorks_Recipient",
            "42_UNUSED_consensusTrustRootWorks_Client",
            "43_UNUSED_consensusTrustRootWorks_Recipient",
            "44_HTTP_extraConsensusTrustRootWorks_Client",
            "45_HTTP_extraConsensusTrustRootWorks_Recipient",
            "46_UNUSED_extraConsensusTrustRootWorks_Client",
            "47_UNUSED_extraConsensusTrustRootWorks_Recipient",
            "48_HTTP_wrongConsensusTrustRootReturnsError_Client",
            "49_HTTP_wrongConsensusTrustRootReturnsError_Recipient",
            "50_UNUSED_wrongConsensusTrustRootReturnsError_Client",
            "51_UNUSED_wrongConsensusTrustRootReturnsError_Recipient",
            "52_HTTP_idempotenceDoubleSubmissionFailure_Client",
            "53_HTTP_idempotenceDoubleSubmissionFailure_Recipient",
            "54_UNUSED_idempotenceDoubleSubmissionFailure_Client",
            "55_UNUSED_idempotenceDoubleSubmissionFailure_Recipient",
        ]

        let testNamePrefix = testName.components(separatedBy: "(")[0]

        // compose the search string
        let clientName = "_\(transportProtocol.description)_\(testNamePrefix)_\(purpose)"

        // get the index of the clientName that ends with the search string
        guard let index = clientNames.firstIndex(where: { $0.hasSuffix(clientName) }) else {
            fatalError("Can't find requested client named: \(clientName)")
        }

        let rng = MobileCoinChaCha20Rng(seed32: seed32)

        // skip to the right position (can possibly use setWordPos)
        for _ in 0..<index { for _ in 1...4 { _ = rng.next() } }

        // get 32 bytes of data from MobileCoinRng
        var entropyData = Data()
        for _ in 1...4 { entropyData.append(rng.next().data) }

        guard let entropy32 = Data32(entropyData) else {
            fatalError(".secRngGenBytes(32) should always create a valid Data32")
        }

        print("Account entropy for \(clientName): \(entropy32.base64EncodedString())")

        let acctKey = try AccountKey.make(
            rootEntropy: entropy32.data,
            fogReportUrl: network.fogReportUrl,
            fogReportId: network.fogReportId,
            fogAuthoritySpki: network.fogAuthoritySpki())
            .get()

        let client = try createMobileCoinClient(
            accountKey: acctKey,
            config: config,
            transportProtocol: transportProtocol)

        return (acctKey, client)
    }
}

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt64>.size)
    }
}

extension ProcessInfo {
    func combined(_ variable: String) -> String? {
        // Check environment first, then check "local environment" (secrets JSON file)
        guard let value = ProcessInfo.processInfo.environment[variable] else {
            switch variable {
            case "testAccountSeed":
                return ProcessInfoLocal.shared?.testAccountSeed
            default:
                return nil
            }
        }

        return value
    }
}

struct ProcessInfoLocal: Decodable {
    let testAccountSeed: String

    static let shared = try? Self.load()

    static func load() throws -> Self {
        // We're using SPM
        var processInfoFileUrl: URL?
        #if canImport(LibMobileCoinHTTP)
        processInfoFileUrl = Bundle.module.url(
            forResource: "process_info",
            withExtension: "json"
        )
        #else
        // We're using cocoapods
        processInfoFileUrl = try Bundle.url("process_info", "json")
        #endif

        guard
            let processInfoFileUrl = processInfoFileUrl,
            let processInfoFileData = try? Data(contentsOf: processInfoFileUrl)
        else {
            fatalError(
                "No `process_info.json` file found." +
                "initialize with `make init-secrets`" +
                "Or, make duplicate `process_info.json.sample` and remove the `.sample` extension."
            )
        }

        return try JSONDecoder().decode(Self.self, from: processInfoFileData)
    }
}
