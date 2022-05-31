//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable function_parameter_count multiline_arguments multiline_function_chains

import Foundation

public final class MobileCoinClient {
    /// - Returns: `InvalidInputError` when `accountKey` isn't configured to use Fog.
    public static func make(accountKey: AccountKey, config: Config)
        -> Result<MobileCoinClient, InvalidInputError>
    {
        guard let accountKey = AccountKeyWithFog(accountKey: accountKey) else {
            let errorMessage = "Accounts without fog URLs are not currently supported."
            logger.error(errorMessage, logFunction: false)
            return .failure(InvalidInputError(errorMessage))
        }

        return .success(MobileCoinClient(accountKey: accountKey, config: config))
    }

    private let accountLock: ReadWriteDispatchLock<Account>
    private let serialQueue: DispatchQueue
    private let callbackQueue: DispatchQueue

    private let txOutSelectionStrategy: TxOutSelectionStrategy
    private let mixinSelectionStrategy: MixinSelectionStrategy
    private let fogQueryScalingStrategy: FogQueryScalingStrategy

    private let serviceProvider: ServiceProvider
    private let fogResolverManager: FogResolverManager
    private let metaFetcher: BlockchainMetaFetcher

    private let fogSyncChecker: FogSyncCheckable

    static let latestBlockVersion = BlockVersion.legacy

    init(accountKey: AccountKeyWithFog, config: Config) {
        logger.info("""
            Initializing \(Self.self):
            \(Self.configDescription(accountKey: accountKey, config: config))
            """, logFunction: false)

        self.serialQueue = DispatchQueue(label: "com.mobilecoin.\(Self.self)")
        self.callbackQueue = config.callbackQueue ?? DispatchQueue.main
        self.fogSyncChecker = config.fogSyncCheckable
        self.accountLock = .init(Account(accountKey: accountKey, syncChecker: fogSyncChecker))
        self.txOutSelectionStrategy = config.txOutSelectionStrategy
        self.mixinSelectionStrategy = config.mixinSelectionStrategy
        self.fogQueryScalingStrategy = config.fogQueryScalingStrategy

        let grpcFactory = GrpcProtocolConnectionFactory()
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: config.networkConfig.httpRequester)

        self.serviceProvider = DefaultServiceProvider(
            networkConfig: config.networkConfig,
            targetQueue: serialQueue,
            grpcConnectionFactory: grpcFactory,
            httpConnectionFactory: httpFactory)

        self.fogResolverManager = FogResolverManager(
            fogReportAttestation: config.networkConfig.fogReportAttestation,
            serviceProvider: serviceProvider,
            targetQueue: serialQueue)

        self.metaFetcher = BlockchainMetaFetcher(
            blockchainService: serviceProvider.blockchainService,
            metaCacheTTL: config.metaCacheTTL,
            targetQueue: serialQueue)
    }

    @available(*, deprecated, message:
        """
        Deprecated in favor of `balance(for:TokenId)` which accepts a TokenId.
        `balance` will assume the default TokenId == .MOB // UInt64(0)

        Get a set of all tokenIds that are in TxOuts owned by this account with:

        `MobileCoinClient(...).accountTokenIds // Set<TokenId>`
        """)
    public var balance: Balance {
        balance(for: .MOB)
    }

    public var balances: Balances {
        accountLock.readSync { $0.cachedBalances }
    }

    public var accountTokenIds: Set<TokenId> {
        accountLock.readSync { $0.cachedTxOutTokenIds }
    }

    public var accountActivity: AccountActivity {
        accountLock.readSync { $0.cachedAccountActivity }
    }

    public func balance(for tokenId: TokenId = .MOB) -> Balance {
        accountLock.readSync { $0.cachedBalance(for: tokenId) }
    }

    public func setTransportProtocol(_ transportProtocol: TransportProtocol) {
        serviceProvider.setTransportProtocolOption(transportProtocol.option)
    }

    public func setConsensusBasicAuthorization(username: String, password: String) {
        let credentials = BasicCredentials(username: username, password: password)
        serviceProvider.setConsensusAuthorization(credentials: credentials)
    }

    public func setFogBasicAuthorization(username: String, password: String) {
        let credentials = BasicCredentials(username: username, password: password)
        serviceProvider.setFogUserAuthorization(credentials: credentials)
    }

    @available(*, deprecated, message:
        """
        Use the new `updateBalances(...)` that passes `Balances` into the completion closure. `Balances`
            is a new structure that holds multiple `Balance` structs for each known tokenId.

        ```
        public func updateBalances(completion: @escaping (Result<Balances, BalanceUpdateError>) -> Void)
        ```

        this function will return the `Balance` struct for the default TokenId == .MOB
        """)
    public func updateBalance(completion: @escaping (Result<Balance, ConnectionError>) -> Void) {
        updateBalances {
            completion($0.map({
                $0.mobBalance
            }).mapError({
                switch $0 {
                case .connectionError(let error):
                    return error
                case .fogSyncError(let error):
                    return ConnectionError.invalidServerResponse(error.description)
                }
            }))
        }
    }

    public func updateBalances(completion: @escaping (Result<Balances, BalanceUpdateError>) -> Void) {
        Account.BalanceUpdater(
            account: accountLock,
            fogViewService: serviceProvider.fogViewService,
            fogKeyImageService: serviceProvider.fogKeyImageService,
            fogBlockService: serviceProvider.fogBlockService,
            fogQueryScalingStrategy: fogQueryScalingStrategy,
            targetQueue: serialQueue
        ).updateBalances { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    @available(*, deprecated, message:
        """
        Use the new `amountTransferable(...)` that accepts a `TokenId` as an input parameter.

        ```
        public func amountTransferable(
            tokenId: TokenId = .MOB
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
        )
        ```

        this function will return the amount transferable for the default TokenId == .MOB
        """)
    public func amountTransferable(
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
    ) {
        amountTransferable(tokenId: .MOB, feeLevel: feeLevel, completion: completion)
    }

    public func amountTransferable(
        tokenId: TokenId,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
    ) {
        Account.TransactionEstimator(
            account: accountLock,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            targetQueue: serialQueue
        ).amountTransferable(tokenId: tokenId, feeLevel: feeLevel, completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `estimateTotalFee(...)` that accepts an `Amount` as an input parameter.

        ```
        public func estimateTotalFee(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
        )
        ```

        this function will estimate the total fee assuming the default TokenId == .MOB
        """)
    public func estimateTotalFee(
        toSendAmount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
    ) {
        estimateTotalFee(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel,
            completion: completion)
    }

    public func estimateTotalFee(
        toSendAmount amount: Amount,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
    ) {
        Account.TransactionEstimator(
            account: accountLock,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            targetQueue: serialQueue
        ).estimateTotalFee(toSendAmount: amount, feeLevel: feeLevel, completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `requiresDefragmentation(...)` that accepts an `Amount` as an input parameter.

        ```
        public func requiresDefragmentation(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
        )
        ```

        this function returns a Bool to the completion() assuming the default TokenId == .MOB
        """)
    public func requiresDefragmentation(
        toSendAmount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
    ) {
        requiresDefragmentation(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel,
            completion: completion)
    }

    public func requiresDefragmentation(
        toSendAmount amount: Amount,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
    ) {
        Account.TransactionEstimator(
            account: accountLock,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            targetQueue: serialQueue
        ).requiresDefragmentation(toSendAmount: amount, feeLevel: feeLevel, completion: completion)
    }

    @available(*, deprecated, message:
        """
        Use the new `prepareTransaction(...)` that accepts an `Amount` as an input parameter.

        ```
        public func prepareTransaction(
            to recipient: PublicAddress,
            memoType: MemoType = .unused,
            amount: Amount,
            fee: UInt64,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        )
        ```

        this function prepares a transaction assuming assuming the default TokenId == .MOB
        """)
    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .unused,
        amount value: UInt64,
        fee: UInt64,
        completion: @escaping (
            Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
        ) -> Void
    ) {
        prepareTransaction(
            to: recipient,
            memoType: memoType,
            amount: Amount(value: value, tokenId: .MOB),
            fee: fee) {
                completion($0.map({ ($0.transaction, $0.receipt) }))
        }

    }

    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .recoverable,
        amount: Amount,
        fee: UInt64,
        completion: @escaping (
            Result<PendingSinglePayloadTransaction, TransactionPreparationError>
        ) -> Void
    ) {
        Account.TransactionOperations(
            account: accountLock,
            fogMerkleProofService: serviceProvider.fogMerkleProofService,
            fogResolverManager: fogResolverManager,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            mixinSelectionStrategy: mixinSelectionStrategy,
            targetQueue: serialQueue
        ).prepareTransaction(to: recipient, memoType: memoType, amount: amount, fee: fee) { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    @available(*, deprecated, message:
        """
        Use the new `prepareTransaction(...)` that accepts an `Amount` as an input parameter.

        ```
        public func prepareTransaction(
            to recipient: PublicAddress,
            memoType: MemoType = .unused,
            amount: Amount,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (
                Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
            ) -> Void
        )
        ```

        this function prepares a transaction assuming assuming the default TokenId == .MOB
        """)
    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .unused,
        amount value: UInt64,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (
            Result<(transaction: Transaction, receipt: Receipt), TransactionPreparationError>
        ) -> Void
    ) {
        prepareTransaction(
            to: recipient,
            memoType: memoType,
            amount: Amount(value: value, tokenId: .MOB),
            feeLevel: feeLevel) {
                completion($0.map { pending in
                    (pending.transaction, pending.receipt)
                })
        }
    }

    public func prepareTransaction(
        to recipient: PublicAddress,
        memoType: MemoType = .recoverable,
        amount: Amount,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (
            Result<PendingSinglePayloadTransaction, TransactionPreparationError>
        ) -> Void
    ) {
        Account.TransactionOperations(
            account: accountLock,
            fogMerkleProofService: serviceProvider.fogMerkleProofService,
            fogResolverManager: fogResolverManager,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            mixinSelectionStrategy: mixinSelectionStrategy,
            targetQueue: serialQueue
        ).prepareTransaction(to: recipient, memoType: memoType, amount: amount, feeLevel: feeLevel) { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    @available(*, deprecated, message:
        """
        Use the new `prepareDefragmentationStepTransactions(...)` that accepts an `Amount` as an input parameter.

        ```
        public func prepareDefragmentationStepTransactions(
            toSendAmount amount: Amount,
            recoverableMemo: Bool = false,
            feeLevel: FeeLevel = .minimum,
            completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
        )
        ```

        this function prepares transactions assuming assuming the default TokenId == .MOB
        """)
    public func prepareDefragmentationStepTransactions(
        toSendAmount value: UInt64,
        recoverableMemo: Bool = false,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
    ) {
        prepareDefragmentationStepTransactions(
            toSendAmount: Amount(value: value, tokenId: .MOB),
            recoverableMemo: false,
            feeLevel: feeLevel,
            completion: completion)
    }

    public func prepareDefragmentationStepTransactions(
        toSendAmount amount: Amount,
        recoverableMemo: Bool = false,
        feeLevel: FeeLevel = .minimum,
        completion: @escaping (Result<[Transaction], DefragTransactionPreparationError>) -> Void
    ) {
        Account.TransactionOperations(
            account: accountLock,
            fogMerkleProofService: serviceProvider.fogMerkleProofService,
            fogResolverManager: fogResolverManager,
            metaFetcher: metaFetcher,
            txOutSelectionStrategy: txOutSelectionStrategy,
            mixinSelectionStrategy: mixinSelectionStrategy,
            targetQueue: serialQueue
        ).prepareDefragmentationStepTransactions(
            toSendAmount: amount,
            recoverableMemo: recoverableMemo,
            feeLevel: feeLevel) { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    public func submitTransaction(
        _ transaction: Transaction,
        completion: @escaping (Result<(), TransactionSubmissionError>) -> Void
    ) {
        TransactionSubmitter(
            consensusService: serviceProvider.consensusService,
            metaFetcher: metaFetcher,
            syncChecker: accountLock.accessWithoutLocking.syncCheckerLock
        ).submitTransaction(transaction) { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    public func status(
        of transaction: Transaction,
        completion: @escaping (Result<TransactionStatus, ConnectionError>) -> Void
    ) {
        TransactionStatusChecker(
            account: accountLock,
            fogUntrustedTxOutService: serviceProvider.fogUntrustedTxOutService,
            fogKeyImageService: serviceProvider.fogKeyImageService,
            targetQueue: serialQueue
        ).checkStatus(transaction) { result in
            self.callbackQueue.async {
                completion(result)
            }
        }
    }

    public func status(of receipt: Receipt) -> Result<ReceiptStatus, InvalidInputError> {
        ReceiptStatusChecker(account: accountLock).status(receipt)
    }
}

extension MobileCoinClient {
    private static func configDescription(accountKey: AccountKeyWithFog, config: Config) -> String {
        let fogInfo = accountKey.fogInfo

        return """
            Consensus urls: \(config.networkConfig.consensusUrls)
            Fog urls: \(config.networkConfig.fogUrls)
            AccountKey PublicAddress: \
            \(redacting: Base58Coder.encode(accountKey.accountKey.publicAddress))
            AccountKey Fog Report url: \(fogInfo.reportUrl.url)
            AccountKey Fog Report id: \(String(reflecting: fogInfo.reportId))
            AccountKey Fog Report authority sPKI: 0x\(fogInfo.authoritySpki.hexEncodedString())
            Consensus attestation: \(config.networkConfig.consensusConfig().attestation)
            Fog View attestation: \(config.networkConfig.fogViewConfig().attestation)
            Fog KeyImage attestation: \(config.networkConfig.fogKeyImageConfig().attestation)
            Fog MerkleProof attestation: \(config.networkConfig.fogMerkleProofConfig().attestation)
            Fog Report attestation: \(config.networkConfig.fogReportAttestation)
            """
    }
}

extension MobileCoinClient {
    public struct Config {
        /// - Returns: `InvalidInputError` when `consensusUrl` or `fogUrl` are not well-formed URLs
        ///     with the appropriate schemes.
        public static func make(
            consensusUrl: String,
            consensusAttestation: Attestation,
            fogUrl: String,
            fogViewAttestation: Attestation,
            fogKeyImageAttestation: Attestation,
            fogMerkleProofAttestation: Attestation,
            fogReportAttestation: Attestation,
            transportProtocol: TransportProtocol
        ) -> Result<Config, InvalidInputError> {
            Self.make(consensusUrls: [consensusUrl],
                      consensusAttestation: consensusAttestation,
                      fogUrls: [fogUrl],
                      fogViewAttestation: fogViewAttestation,
                      fogKeyImageAttestation: fogKeyImageAttestation,
                      fogMerkleProofAttestation: fogMerkleProofAttestation,
                      fogReportAttestation: fogReportAttestation,
                      transportProtocol: transportProtocol)
        }

        /// - Returns: `InvalidInputError` when `consensusUrl` or `fogUrl` are not well-formed URLs
        ///     with the appropriate schemes.
        public static func make(
            consensusUrls: [String],
            consensusAttestation: Attestation,
            fogUrls: [String],
            fogViewAttestation: Attestation,
            fogKeyImageAttestation: Attestation,
            fogMerkleProofAttestation: Attestation,
            fogReportAttestation: Attestation,
            transportProtocol: TransportProtocol
        ) -> Result<Config, InvalidInputError> {

            ConsensusUrl.make(strings: consensusUrls).flatMap { consensusUrls in
                RandomUrlLoadBalancer<ConsensusUrl>.make(urls: consensusUrls).flatMap { consensusUrlLoadBalancer in
                    FogUrl.make(strings: fogUrls).flatMap { fogUrls in
                        RandomUrlLoadBalancer<FogUrl>.make(urls: fogUrls).map { fogUrlLoadBalancer in

                            let attestationConfig = NetworkConfig.AttestationConfig(
                                consensus: consensusAttestation,
                                fogView: fogViewAttestation,
                                fogKeyImage: fogKeyImageAttestation,
                                fogMerkleProof: fogMerkleProofAttestation,
                                fogReport: fogReportAttestation)

                            let networkConfig = NetworkConfig(
                                consensusUrlLoadBalancer: consensusUrlLoadBalancer,
                                fogUrlLoadBalancer: fogUrlLoadBalancer,
                                attestation: attestationConfig,
                                transportProtocol: transportProtocol)
                            return Config(networkConfig: networkConfig)
                        }
                    }
                }
            }
        }

        fileprivate var networkConfig: NetworkConfig

        // default minimum fee cache TTL is 30 minutes
        public var metaCacheTTL: TimeInterval = 30 * 60

        public var cacheStorageAdapter: StorageAdapter?

        /// The `DispatchQueue` on which all `MobileCoinClient` completion handlers will be called.
        /// If `nil`, `DispatchQueue.main` will be used.
        public var callbackQueue: DispatchQueue?

        var txOutSelectionStrategy: TxOutSelectionStrategy = DefaultTxOutSelectionStrategy()
        var mixinSelectionStrategy: MixinSelectionStrategy = DefaultMixinSelectionStrategy()
        var fogQueryScalingStrategy: FogQueryScalingStrategy = DefaultFogQueryScalingStrategy()
        var fogSyncCheckable: FogSyncCheckable = FogSyncChecker()

        init(networkConfig: NetworkConfig) {
            self.networkConfig = networkConfig
        }

        public var transportProtocol: TransportProtocol {
            get { networkConfig.transportProtocol }
            set { networkConfig.transportProtocol = newValue }
        }

        public mutating func setConsensusTrustRoots(_ trustRoots: [Data])
            -> Result<(), InvalidInputError>
        {
            networkConfig.setConsensusTrustRoots(trustRoots)
        }

        public mutating func setFogTrustRoots(_ trustRoots: [Data]) -> Result<(), InvalidInputError>
        {
            networkConfig.setFogTrustRoots(trustRoots)
        }

        public mutating func setConsensusBasicAuthorization(username: String, password: String) {
            networkConfig.consensusAuthorization =
                BasicCredentials(username: username, password: password)
        }

        public mutating func setFogBasicAuthorization(username: String, password: String) {
            networkConfig.fogUserAuthorization =
                BasicCredentials(username: username, password: password)
        }

        public var httpRequester: HttpRequester? {
            get { networkConfig.httpRequester }
            set { networkConfig.httpRequester = newValue }
        }
    }
}

extension MobileCoinClient {

    public func blockVersion(
        _ completion: @escaping (Result<BlockVersion, ConnectionError>
    ) -> Void) {
        metaFetcher.blockVersion {
            completion($0)
        }
    }

}
