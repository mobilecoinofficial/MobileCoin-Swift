//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class MistyswapGrpcConnection: AttestedGrpcConnection, MistyswapService {
    private let client: Mistyswap_MistyswapOfframpApiClient

    init(
        config: AttestedConnectionConfig<MistyswapUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = Mistyswap_MistyswapOfframpApiClient(channel: channel)
        super.init(
            client: Attest_AttestedApiClient(channel: channel),
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func initiateOfframp(request: Mistyswap_InitiateOfframpRequest, completion: @escaping (Result<Mistyswap_InitiateOfframpResponse, ConnectionError>) -> Void) {
        performAttestedCall(
            InitiateOfframp(client: client),
            request: request,
            completion: completion)
    }
    
    func forgetOfframp(request: Mistyswap_ForgetOfframpRequest, completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void) {
//        performAttestedCall(
//            ForgetOfframp(client: client),
//            request: tx,
//            completion: completion)
    }
    
    func getOfframpStatus(request: Mistyswap_GetOfframpStatusRequest, completion: @escaping (Result<Attest_Message, ConnectionError>) -> Void) {
//        performAttestedCall(
//            GetOfframpStatus(client: client),
//            request: tx,
//            completion: completion)
    }
    
}

extension MistyswapGrpcConnection {
    private struct InitiateOfframp: AttestedGrpcCallable {
        typealias InnerRequest = Mistyswap_InitiateOfframpRequest
        typealias InnerResponse = Mistyswap_InitiateOfframpResponse

        let client: Mistyswap_MistyswapOfframpApiClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<Mistyswap_InitiateOfframpResponse>, Error>
            ) -> Void
        ) {
            let unaryCall = client.initiateOfframp(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension MistyswapGrpcConnection: MistyswapServiceConnection {}
