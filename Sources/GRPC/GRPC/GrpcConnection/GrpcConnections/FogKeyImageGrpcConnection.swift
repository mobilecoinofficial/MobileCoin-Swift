//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
#endif

final class FogKeyImageGrpcConnection: AttestedGrpcConnection, FogKeyImageService {
    private let client: FogLedger_FogKeyImageAPIClient

    init(
        config: AttestedConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = FogLedger_FogKeyImageAPIClient(channel: channel)
        super.init(
            client: self.client,
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
        performAttestedCall(
            CheckKeyImagesCall(client: client),
            request: request,
            completion: completion)
    }
}

extension FogKeyImageGrpcConnection {
    private struct CheckKeyImagesCall: AttestedGrpcCallable {
        typealias InnerRequest = FogLedger_CheckKeyImagesRequest
        typealias InnerResponse = FogLedger_CheckKeyImagesResponse

        let client: FogLedger_FogKeyImageAPIClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (Result<UnaryCallResult<Attest_Message>, Error>) -> Void
        ) {
            let unaryCall = client.checkKeyImages(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension FogKeyImageGrpcConnection: FogKeyImageServiceConnection {}
extension FogLedger_FogKeyImageAPIClient: AuthGrpcCallableClient {}
