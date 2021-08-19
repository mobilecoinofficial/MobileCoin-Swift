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
                    return .http(httpService: BlockchainHttpConnection())
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
    }
}
