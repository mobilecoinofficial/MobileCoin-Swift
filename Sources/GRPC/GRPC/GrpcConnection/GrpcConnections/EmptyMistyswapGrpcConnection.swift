//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinCommon
import LibMobileCoinGRPC
#endif

final class EmptyMistyswapGrpcConnection: AttestedGrpcConnection, MistyswapService {
    private let client: MistyswapOfframp_MistyswapOfframpApiClient

    init(
        config: EmptyAttestedConnectionConfig,
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
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

    func getOfframpStatus(
        request: MistyswapOfframp_GetOfframpStatusRequest,
        completion: @escaping (
            Result<MistyswapOfframp_GetOfframpStatusResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

    func forgetOfframp(
        request: MistyswapOfframp_ForgetOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_ForgetOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

}

extension EmptyMistyswapGrpcConnection: MistyswapServiceConnection {}
