//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
#endif

final class FogViewGrpcConnection: AttestedGrpcConnection, FogViewService {
    private let client: FogView_FogViewAPIClient

    init(
        config: AttestedConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = FogView_FogViewAPIClient(channel: channel)
        super.init(
            client: self.client,
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        performAttestedCall(
            EnclaveRequestCall(client: client),
            requestAad: requestAad,
            request: request,
            completion: completion)
    }
}

extension FogViewGrpcConnection {
    private struct EnclaveRequestCall: AttestedGrpcCallable {
        typealias InnerRequestAad = FogView_QueryRequestAAD
        typealias InnerRequest = FogView_QueryRequest
        typealias InnerResponse = FogView_QueryResponse

        let client: FogView_FogViewAPIClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (Result<UnaryCallResult<Attest_Message>, Error>) -> Void
        ) {
            let unaryCall = client.query(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension FogViewGrpcConnection: FogViewServiceConnection {}
extension FogView_FogViewAPIClient: AuthGrpcCallableClient {}
