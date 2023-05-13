//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class MistyswapUntrustedGrpcConnection: GrpcConnection, MistyswapUntrustedService {
    private let client: Mistyswap_MistyswapOfframpApiClient

    init(
        config: ConnectionConfig<MistyswapUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        let channel = channelManager.channel(for: config)
        self.client = Mistyswap_MistyswapOfframpApiClient(channel: channel)
        super.init(config: config, targetQueue: targetQueue)
    }

    func forgetOfframp(request: Mistyswap_ForgetOfframpRequest, completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void) {
        performCall(ForgetOfframp(client: client), request: request, completion: completion)
    }
    
}

extension MistyswapUntrustedGrpcConnection {
    private struct ForgetOfframp: GrpcCallable {
        let client: Mistyswap_MistyswapOfframpApiClient

        func call(
            request: Mistyswap_ForgetOfframpRequest,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<Mistyswap_ForgetOfframpResponse>, Error>
            ) -> Void
        ) {
            let unaryCall = client.forgetOfframp(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension MistyswapUntrustedGrpcConnection: MistyswapUntrustedServiceConnection {}
