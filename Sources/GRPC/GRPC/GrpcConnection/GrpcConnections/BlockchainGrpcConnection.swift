//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
import LibMobileCoinCommon
#endif
import SwiftProtobuf

final class BlockchainGrpcConnection: GrpcConnection, BlockchainService {
    private let client: ConsensusCommon_BlockchainAPIClient

    init(
        config: ConnectionConfig<ConsensusUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        let channel = channelManager.channel(for: config)
        self.client = ConsensusCommon_BlockchainAPIClient(channel: channel)
        super.init(config: config, targetQueue: targetQueue)
    }

    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
        performCall(GetLastBlockInfoCall(client: client), completion: completion)
    }
}

extension BlockchainGrpcConnection {
    private struct GetLastBlockInfoCall: GrpcCallable {
        let client: ConsensusCommon_BlockchainAPIClient

        func call(
            request: (),
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<ConsensusCommon_LastBlockInfoResponse>, Error>
            ) -> Void
        ) {
            let unaryCall =
                client.getLastBlockInfo(Google_Protobuf_Empty(), callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension BlockchainGrpcConnection: BlockchainServiceConnection {}
