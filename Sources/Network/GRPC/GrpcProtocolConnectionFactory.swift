//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {

    let channelManager = GrpcChannelManager()

    func makeConsensusService(
        config: AttestedConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> ConsensusGrpcConnection {
        ConsensusGrpcConnection(
                config: config,
                channelManager: channelManager,
                targetQueue: targetQueue)
    }

    func makeBlockchainService(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> BlockchainGrpcConnection {
        BlockchainGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogViewService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogViewGrpcConnection {
        FogViewGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogMerkleProofService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogMerkleProofGrpcConnection {
        FogMerkleProofGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogKeyImageService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogKeyImageGrpcConnection {
        FogKeyImageGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogBlockService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogBlockGrpcConnection {
        FogBlockGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogUntrustedTxOutService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogUntrustedTxOutGrpcConnection {
        FogUntrustedTxOutGrpcConnection(
            config: config,
            channelManager: channelManager,
            targetQueue: targetQueue)
    }

    func makeFogReportService(
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) -> FogReportGrpcConnection {
        FogReportGrpcConnection(url: url, channelManager: channelManager, targetQueue: targetQueue)
    }
}
