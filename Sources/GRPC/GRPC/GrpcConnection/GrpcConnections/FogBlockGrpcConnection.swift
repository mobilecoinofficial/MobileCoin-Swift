//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
#endif

final class FogBlockGrpcConnection: GrpcConnection, FogBlockService {
    private let client: FogLedger_FogBlockAPIClient

    init(
        config: ConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        let channel = channelManager.channel(for: config)
        self.client = FogLedger_FogBlockAPIClient(channel: channel)
        super.init(config: config, targetQueue: targetQueue)
    }

    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
        performCall(GetBlocksCall(client: client), request: request, completion: completion)
    }
}

extension FogBlockGrpcConnection {
    private struct GetBlocksCall: GrpcCallable {
        let client: FogLedger_FogBlockAPIClient

        func call(
            request: FogLedger_BlockRequest,
            callOptions: CallOptions?,
            completion: @escaping (Result<UnaryCallResult<FogLedger_BlockResponse>, Error>) -> Void
        ) {
            let unaryCall = client.getBlocks(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension FogBlockGrpcConnection: FogBlockServiceConnection {}
