//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

final class DefaultServiceProvider: ServiceProvider {
    private let inner: SerialDispatchLock<Inner>

    private let consensus: ConsensusConnection
    private let blockchain: BlockchainConnection
    private let view: FogViewConnection
    private let merkleProof: FogMerkleProofConnection
    private let keyImage: FogKeyImageConnection
    private let block: FogBlockConnection
    private let untrustedTxOut: FogUntrustedTxOutConnection
    private let grpcConnectionFactory: GrpcProtocolConnectionFactory
    private let httpConnectionFactory: HttpProtocolConnectionFactory

    init(
        networkConfig: NetworkConfig,
        targetQueue: DispatchQueue?,
        grpcConnectionFactory: GrpcProtocolConnectionFactory,
        httpConnectionFactory: HttpProtocolConnectionFactory
    ) {
        self.grpcConnectionFactory = grpcConnectionFactory
        self.httpConnectionFactory = httpConnectionFactory
        
        // TODO
        let channelManager = GrpcChannelManager()
        let inner = Inner(channelManager: channelManager, httpRequester: networkConfig.httpRequester, targetQueue: targetQueue)
        self.inner = .init(inner, targetQueue: targetQueue)
        // END TODO

        /**
         - Write EmptyConnection that implements ConnectionProtocol
         - Use DI & Factory Pattern & Extensions on TransportProtocol Option to create/return connectionOptionWrapperFactory function.
         - ConnectionFactory class,  default implementation returns
         */
        
        self.consensus = ConsensusConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.consensus,
            targetQueue: targetQueue)
        self.blockchain = BlockchainConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.blockchain,
            targetQueue: targetQueue)
            self.view = FogViewConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.fogView,
            targetQueue: targetQueue)
        self.merkleProof = FogMerkleProofConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.fogMerkleProof,
            targetQueue: targetQueue)
        self.keyImage = FogKeyImageConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.fogKeyImage,
            targetQueue: targetQueue)
        self.block = FogBlockConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.fogBlock,
            targetQueue: targetQueue)
        self.untrustedTxOut = FogUntrustedTxOutConnection(
            httpFactory: self.httpConnectionFactory,
            grpcFactory: self.grpcConnectionFactory,
            config: networkConfig.fogUntrustedTxOut,
            targetQueue: targetQueue)
    }

    var consensusService: ConsensusService { consensus }
    var blockchainService: BlockchainService { blockchain }
    var fogViewService: FogViewService { view }
    var fogMerkleProofService: FogMerkleProofService { merkleProof }
    var fogKeyImageService: FogKeyImageService { keyImage }
    var fogBlockService: FogBlockService { block }
    var fogUntrustedTxOutService: FogUntrustedTxOutService { untrustedTxOut }

    func fogReportService(
        for fogReportUrl: FogUrl,
        completion: @escaping (FogReportService) -> Void
    ) {
        inner.accessAsync { completion($0.fogReportService(for: fogReportUrl)) }
    }

    func setTransportProtocolOption(_ transportProtocolOption: TransportProtocol.Option) {
        inner.accessAsync {
            $0.setTransportProtocolOption(transportProtocolOption)
            self.consensus.setTransportProtocolOption(transportProtocolOption)
            self.blockchain.setTransportProtocolOption(transportProtocolOption)
            self.view.setTransportProtocolOption(transportProtocolOption)
            self.merkleProof.setTransportProtocolOption(transportProtocolOption)
            self.keyImage.setTransportProtocolOption(transportProtocolOption)
            self.block.setTransportProtocolOption(transportProtocolOption)
            self.untrustedTxOut.setTransportProtocolOption(transportProtocolOption)
        }
    }

    func setConsensusAuthorization(credentials: BasicCredentials) {
        consensus.setAuthorization(credentials: credentials)
        blockchain.setAuthorization(credentials: credentials)
    }

    func setFogUserAuthorization(credentials: BasicCredentials) {
        view.setAuthorization(credentials: credentials)
        merkleProof.setAuthorization(credentials: credentials)
        keyImage.setAuthorization(credentials: credentials)
        block.setAuthorization(credentials: credentials)
        untrustedTxOut.setAuthorization(credentials: credentials)
    }
}

// TODO
extension DefaultServiceProvider {
    private struct Inner {
        private let targetQueue: DispatchQueue?
        private let channelManager: GrpcChannelManager
        private let httpRequester: HttpRequester?

        private var reportUrlToReportConnection: [GrpcChannelConfig: FogReportConnection] = [:]
        private(set) var transportProtocolOption: TransportProtocol.Option

        init(channelManager: GrpcChannelManager, httpRequester: HttpRequester?, targetQueue: DispatchQueue?) {
            self.targetQueue = targetQueue
            self.httpRequester = httpRequester
            self.channelManager = channelManager
            self.transportProtocolOption = TransportProtocol.grpc.option
        }

        mutating func fogReportService(for fogReportUrl: FogUrl) -> FogReportService {
            let config = GrpcChannelConfig(url: fogReportUrl)
            guard let reportConnection = reportUrlToReportConnection[config] else {
                let reportConnection = FogReportConnection(
                    url: fogReportUrl,
                    transportProtocolOption: transportProtocolOption,
                    channelManager: channelManager,
                    httpRequester: httpRequester,
                    targetQueue: targetQueue)
                reportUrlToReportConnection[config] = reportConnection
                return reportConnection
            }
            return reportConnection
        }

        mutating func setTransportProtocolOption(
            _ transportProtocolOption: TransportProtocol.Option
        ) {
            self.transportProtocolOption = transportProtocolOption
            for reportConnection in reportUrlToReportConnection.values {
                reportConnection.setTransportProtocolOption(transportProtocolOption)
            }
        }
    }
}
