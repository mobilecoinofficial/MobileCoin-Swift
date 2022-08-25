//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class HttpProtocolConnectionFactory: ProtocolConnectionFactory {
    let requester: HttpRequester

    init(httpRequester: HttpRequester?) {
        self.requester = httpRequester ?? DefaultHttpRequester()
    }

    func makeConsensusService(
        config: AttestedConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> ConsensusHttpConnection {
        ConsensusHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeBlockchainService(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> BlockchainHttpConnection {
        BlockchainHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeFogViewService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogViewHttpConnection {
        FogViewHttpConnection(
                config: config,
                requester: RestApiRequester(requester: requester, baseUrl: config.url),
                targetQueue: targetQueue)
    }

    func makeFogMerkleProofService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogMerkleProofHttpConnection {
        FogMerkleProofHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeFogKeyImageService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogKeyImageHttpConnection {
        FogKeyImageHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeFogBlockService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogBlockHttpConnection {
        FogBlockHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeFogUntrustedTxOutService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogUntrustedTxOutHttpConnection {
        FogUntrustedTxOutHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url),
                        targetQueue: targetQueue)
    }

    func makeFogReportService(
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) -> FogReportHttpConnection {
        FogReportHttpConnection(
            url: url,
            requester: RestApiRequester(requester: requester, baseUrl: url),
            targetQueue: targetQueue)
    }
}
