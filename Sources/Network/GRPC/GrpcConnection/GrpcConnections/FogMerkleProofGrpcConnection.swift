//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class FogMerkleProofGrpcConnection: AttestedGrpcConnection, FogMerkleProofService {
    private let client: FogLedger_FogMerkleProofAPIClient

    init(
        config: AttestedConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = FogLedger_FogMerkleProofAPIClient(channel: channel)
        super.init(
            client: self.client,
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func getOutputs(
        request: FogLedger_GetOutputsRequest,
        completion: @escaping (Result<FogLedger_GetOutputsResponse, ConnectionError>) -> Void
    ) {
        performAttestedCall(
            GetOutputsCall(client: client),
            request: request,
            completion: completion)
    }
}

extension FogMerkleProofGrpcConnection {
    private struct GetOutputsCall: AttestedGrpcCallable {
        typealias InnerRequest = FogLedger_GetOutputsRequest
        typealias InnerResponse = FogLedger_GetOutputsResponse

        let client: FogLedger_FogMerkleProofAPIClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (UnaryCallResult<Attest_Message>) -> Void
        ) {
            let unaryCall = client.getOutputs(request, callOptions: callOptions)
            unaryCall.callResult.whenSuccess(completion)
        }
    }
}

extension FogMerkleProofGrpcConnection: FogMerkleProofServiceConnection {}
extension FogLedger_FogMerkleProofAPIClient: AuthGrpcCallableClient {}
