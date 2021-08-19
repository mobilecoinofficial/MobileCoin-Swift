//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class FogBlockConnection:
    Connection<FogBlockGrpcConnection, FogBlockHttpConnection>, FogBlockService
{
    private let config: ConnectionConfig<FogUrl>
    private let channelManager: GrpcChannelManager
    private let targetQueue: DispatchQueue?

    init(
        config: ConnectionConfig<FogUrl>,
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
                        grpcService: FogBlockGrpcConnection(
                            config: config,
                            channelManager: channelManager,
                            targetQueue: targetQueue))
                case .http:
                    return .http(httpService: FogBlockHttpConnection())
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
    }
}
