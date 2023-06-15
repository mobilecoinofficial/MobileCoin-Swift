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

final class ConsensusGrpcConnection: AttestedGrpcConnection, ConsensusService {
    private let client: ConsensusClient_ConsensusClientAPIClient

    init(
        config: AttestedConnectionConfig<ConsensusUrl>,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        let channel = channelManager.channel(for: config)
        self.client = ConsensusClient_ConsensusClientAPIClient(channel: channel)
        super.init(
            client: Attest_AttestedApiClient(channel: channel),
            config: config,
            targetQueue: targetQueue,
            rng: rng,
            rngContext: rngContext)
    }

    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        performAttestedCall(
            ProposeTxCall(client: client),
            request: tx,
            completion: completion)
    }
}

extension ConsensusGrpcConnection {
    private struct ProposeTxCall: AttestedGrpcCallable {
        typealias InnerRequest = External_Tx
        typealias InnerResponse = ConsensusCommon_ProposeTxResponse

        let client: ConsensusClient_ConsensusClientAPIClient

        func call(
            request: Attest_Message,
            callOptions: CallOptions?,
            completion: @escaping (
                Result<UnaryCallResult<ConsensusCommon_ProposeTxResponse>, Error>
            ) -> Void
        ) {
            let unaryCall = client.clientTxPropose(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}

extension ConsensusGrpcConnection: ConsensusServiceConnection {}

extension Attest_AttestedApiClient: AuthGrpcCallableClient {}
