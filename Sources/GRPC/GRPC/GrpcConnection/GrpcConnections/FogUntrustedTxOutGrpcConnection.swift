//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinCommon
import LibMobileCoinGRPC
#endif

final class FogUntrustedTxOutGrpcConnection: GrpcConnection, FogUntrustedTxOutService {
    private let client: FogLedger_FogUntrustedTxOutApiClient

    init(
        config: ConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        let channel = channelManager.channel(for: config)
        self.client = FogLedger_FogUntrustedTxOutApiClient(channel: channel)
        super.init(config: config, targetQueue: targetQueue)
    }

    func getTxOuts(
        request: FogLedger_TxOutRequest,
        completion: @escaping (Result<FogLedger_TxOutResponse, ConnectionError>) -> Void
    ) {
        performCall(GetTxOutsCall(client: client), request: request, completion: completion)
    }
}

extension FogUntrustedTxOutGrpcConnection {
    private struct GetTxOutsCall: GrpcCallable {
        let client: FogLedger_FogUntrustedTxOutApiClient

        func call(
            request: FogLedger_TxOutRequest,
            callOptions: CallOptions?,
            completion: @escaping (Result<UnaryCallResult<FogLedger_TxOutResponse>, Error>) -> Void
        ) {
            let unaryCall = client.getTxOuts(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension FogUntrustedTxOutGrpcConnection: FogUntrustedTxOutServiceConnection {}
