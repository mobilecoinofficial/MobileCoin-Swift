//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
import SwiftProtobuf

final class BlockchainConnection:
    Connection<BlockchainGrpcConnection, BlockchainHttpConnection>, BlockchainService
{
    private let config: ConnectionConfig<ConsensusUrl>
    private let channelManager: GrpcChannelManager
    private let targetQueue: DispatchQueue?

    init(
        config: ConnectionConfig<ConsensusUrl>,
        channelManager: GrpcChannelManager,
        httpRequester: HttpRequester?,
        targetQueue: DispatchQueue?
    ) {
        self.config = config
        self.channelManager = channelManager
        self.targetQueue = targetQueue

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService: BlockchainGrpcConnection(
                            config: config,
                            channelManager: channelManager,
                            targetQueue: targetQueue))
                case .http:
                    guard let requester = httpRequester else {
                        logger.fatalError("Transport Protocol is .http but no HttpRequester provided")
                    }
                    return .http(httpService: BlockchainHttpConnection(
                                    config: config,
                                    requester: RestApiRequester(requester: requester, baseUrl:config.url.httpBasedUrl),
                                    targetQueue: targetQueue))
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.getLastBlockInfo(completion: completion)
        case .http(let httpConnection):
            httpConnection.getLastBlockInfo(completion: completion)
        }
    }
}
