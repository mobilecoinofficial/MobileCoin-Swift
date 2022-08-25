//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class ConsensusConnection: Connection<
        GrpcProtocolConnectionFactory.ConsensusServiceProvider,
        HttpProtocolConnectionFactory.ConsensusServiceProvider
    >,
    ConsensusService
{
    private let httpFactory: HttpProtocolConnectionFactory
    private let grpcFactory: GrpcProtocolConnectionFactory
    private let config: NetworkConfig
    private let targetQueue: DispatchQueue?

    init(
        httpFactory: HttpProtocolConnectionFactory,
        grpcFactory: GrpcProtocolConnectionFactory,
        config: NetworkConfig,
        targetQueue: DispatchQueue?
    ) {
        self.httpFactory = httpFactory
        self.grpcFactory = grpcFactory
        self.config = config
        self.targetQueue = targetQueue

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                let rotatedConfig = config.consensusConfig()
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService: grpcFactory.makeConsensusService(
                            config: rotatedConfig,
                            targetQueue: targetQueue))
                case .http:
                    return .http(httpService: httpFactory.makeConsensusService(
                            config: rotatedConfig,
                            targetQueue: targetQueue))
                }
            },
            transportProtocolOption: config.consensusConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.proposeTx(tx, completion: rotateURLOnError(completion))
        case .http(let httpConnection):
            httpConnection.proposeTx(tx, completion: rotateURLOnError(completion))
        }
    }
}
