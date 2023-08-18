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

final class MistyswapGrpcConnection: AttestedGrpcConnection, MistyswapService {
    private let client: MistyswapOfframp_MistyswapOfframpApiClient

    init(
        config: AttestedConnectionConfig<MistyswapUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = MistyswapOfframp_MistyswapOfframpApiClient(channel: channel)
        super.init(
            client: Attest_AttestedApiClient(channel: channel),
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func initiateOfframp(
        request: MistyswapOfframp_InitiateOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_InitiateOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        performAttestedCall(
            InitiateOfframp(client: client),
            request: request,
            completion: completion)
    }

    func getOfframpStatus(
        request: MistyswapOfframp_GetOfframpStatusRequest,
        completion: @escaping (
            Result<MistyswapOfframp_GetOfframpStatusResponse, ConnectionError>
        ) -> Void
    ) {
        performAttestedCall(
            GetOfframpStatus(client: client),
            request: request,
            completion: completion)
    }

    func forgetOfframp(
        request: MistyswapOfframp_ForgetOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_ForgetOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        performAttestedCall(
            ForgetOfframp(client: client),
            request: request,
            completion: completion)
    }

}

extension MistyswapGrpcConnection {
    private struct InitiateOfframp: AttestedGrpcCallable {
        typealias InnerRequest = MistyswapOfframp_InitiateOfframpRequest
        typealias InnerResponse = MistyswapOfframp_InitiateOfframpResponse

        let client: MistyswapOfframp_MistyswapOfframpApiClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<Attest_Message>, Error>
            ) -> Void
        ) {
            let unaryCall = client.initiateOfframp(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension MistyswapGrpcConnection {
    private struct GetOfframpStatus: AttestedGrpcCallable {
        typealias InnerRequest = MistyswapOfframp_GetOfframpStatusRequest
        typealias InnerResponse = MistyswapOfframp_GetOfframpStatusResponse

        let client: MistyswapOfframp_MistyswapOfframpApiClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<Attest_Message>, Error>
            ) -> Void
        ) {
            let unaryCall = client.getOfframpStatus(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension MistyswapGrpcConnection {
    private struct ForgetOfframp: AttestedGrpcCallable {
        typealias InnerRequest = MistyswapOfframp_ForgetOfframpRequest
        typealias InnerResponse = MistyswapOfframp_ForgetOfframpResponse

        let client: MistyswapOfframp_MistyswapOfframpApiClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<Attest_Message>, Error>
            ) -> Void
        ) {
            let unaryCall = client.forgetOfframp(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension MistyswapGrpcConnection: MistyswapServiceConnection {}
