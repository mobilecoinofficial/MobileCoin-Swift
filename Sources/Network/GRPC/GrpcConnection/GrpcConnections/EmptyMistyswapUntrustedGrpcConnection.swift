//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class EmptyMistyswapUntrustedGrpcConnection: GrpcConnection, MistyswapUntrustedService {
    private let client: Mistyswap_MistyswapOfframpApiClient

    init(
        config: ConnectionConfigProtocol,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        let channel = channelManager.channel(for: config)
        self.client = Mistyswap_MistyswapOfframpApiClient(channel: channel)
        super.init(config: config, targetQueue: targetQueue)
    }

    func forgetOfframp(request: Mistyswap_ForgetOfframpRequest, completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void) {
        completion(.failure(.connectionFailure("Config used to intialize your client did not include URLs or Attestation info for Mistyswap.")))
    }
    
}

extension EmptyMistyswapUntrustedGrpcConnection: MistyswapUntrustedServiceConnection {}
