//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

/// This class is returend by the GRPCProtocolConnection Factory when we cannot get a valid mistyswap Config
/// Under normal circumstances it should never be returned because we check for valid config higher-up in
/// the call-stack but if the code changes this is a fallback for consumers.
final class EmptyMistyswapGrpcConnection: AttestedGrpcConnection, MistyswapService {
    private let client: Mistyswap_MistyswapOfframpApiClient

    init(
        config: EmptyAttestedConnectionConfig,
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

    func initiateOfframp(
        request: Mistyswap_InitiateOfframpRequest,
        completion: @escaping (Result<Mistyswap_InitiateOfframpResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

    func getOfframpStatus(
        request: Mistyswap_GetOfframpStatusRequest,
        completion: @escaping (Result<Mistyswap_GetOfframpStatusResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

    func forgetOfframp(
        request: Mistyswap_ForgetOfframpRequest,
        completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(
            "Config used to intialize your client " +
            "did not include URLs or Attestation info for Mistyswap."
        )))
    }

}

extension EmptyMistyswapGrpcConnection: MistyswapServiceConnection {}
