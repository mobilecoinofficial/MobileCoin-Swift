//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class ConsensusConnection:
    Connection<ConsensusGrpcConnection, ConsensusHttpConnection>, ConsensusService
{
    private let config: AttestedConnectionConfig<ConsensusUrl>
    private let channelManager: GrpcChannelManager
    private let targetQueue: DispatchQueue?
    private let rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?
    private let rngContext: Any?

    init(
        config: AttestedConnectionConfig<ConsensusUrl>,
        channelManager: GrpcChannelManager,
        httpRequester: HttpRequester?,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        self.config = config
        self.channelManager = channelManager
        self.targetQueue = targetQueue
        self.rng = rng
        self.rngContext = rngContext

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService: ConsensusGrpcConnection(
                            config: config,
                            channelManager: channelManager,
                            targetQueue: targetQueue,
                            rng: rng,
                            rngContext: rngContext))
                case .http:
                    guard let requester = httpRequester else {
                        logger.fatalError("Transport Protocol is .http but no HttpRequester provided")
                    }
                    return .http(httpService: ConsensusHttpConnection(
                                    config: config,
                                    requester: RestApiRequester(requester: requester, baseUrl:config.url.httpBasedUrl),
                                    targetQueue: targetQueue,
                                    rng: rng,
                                    rngContext: rngContext))
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.proposeTx(tx, completion: completion)
        case .http(let httpConnection):
            httpConnection.proposeTx(tx, completion: completion)
        }
    }
}
