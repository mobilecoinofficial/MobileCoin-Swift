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

    init(networkConfig: NetworkConfig, targetQueue: DispatchQueue?) {
        let channelManager = GrpcChannelManager()

        let inner = Inner(channelManager: channelManager, httpRequester: networkConfig.httpRequester, targetQueue: targetQueue)
        self.inner = .init(inner, targetQueue: targetQueue)

        self.consensus = ConsensusConnection(
            config: networkConfig.consensus,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.blockchain = BlockchainConnection(
            config: networkConfig.blockchain,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.view = FogViewConnection(
            config: networkConfig.fogView,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.merkleProof = FogMerkleProofConnection(
            config: networkConfig.fogMerkleProof,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.keyImage = FogKeyImageConnection(
            config: networkConfig.fogKeyImage,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.block = FogBlockConnection(
            config: networkConfig.fogBlock,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
            targetQueue: targetQueue)
        self.untrustedTxOut = FogUntrustedTxOutConnection(
            config: networkConfig.fogUntrustedTxOut,
            channelManager: channelManager,
            httpRequester: networkConfig.httpRequester,
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
