//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

protocol ProtocolConnectionFactory {
    associatedtype ConsensusServiceProvider: ConsensusServiceConnection
    associatedtype BlockchainServiceProvider: BlockchainServiceConnection
    associatedtype FogViewServiceProvider: FogViewServiceConnection
    associatedtype FogMerkleProofServiceProvider: FogMerkleProofServiceConnection
    associatedtype FogKeyImageServiceProvider: FogKeyImageServiceConnection
    associatedtype FogBlockServiceProvider: FogBlockServiceConnection
    associatedtype FogUntrustedTxOutServiceProvider: FogUntrustedTxOutServiceConnection
    associatedtype FogReportServiceProvider: FogReportService
    associatedtype MistyswapServiceProvider: MistyswapService

    func makeConsensusService(
        config: AttestedConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> ConsensusServiceProvider

    func makeBlockchainService(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> BlockchainServiceProvider

    func makeFogViewService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogViewServiceProvider

    func makeFogMerkleProofService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogMerkleProofServiceProvider

    func makeFogKeyImageService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogKeyImageServiceProvider

    func makeFogBlockService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogBlockServiceProvider

    func makeFogUntrustedTxOutService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogUntrustedTxOutServiceProvider

    func makeFogReportService(
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) -> FogReportServiceProvider

    func makeMistyswapService(
        config: AttestedConnectionConfig<MistyswapUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> MistyswapServiceProvider
}

extension ProtocolConnectionFactory {
    // The stand-in for a conformer that declares no Mistyswap service. Every call
    // fails, so the completion always fires.
    func makeMistyswapService(
        config: AttestedConnectionConfig<MistyswapUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyMistyswapService {
        EmptyMistyswapService()
    }
}

private let kMistyswapUnavailable = "Mistyswap is not implemented over HTTP"

class EmptyMistyswapService: MistyswapService {
    func forgetOfframp(
        request: MistyswapOfframp_ForgetOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_ForgetOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kMistyswapUnavailable)))
    }

    func initiateOfframp(
        request: MistyswapOfframp_InitiateOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_InitiateOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kMistyswapUnavailable)))
    }

    func getOfframpStatus(
        request: MistyswapOfframp_GetOfframpStatusRequest,
        completion: @escaping (
            Result<MistyswapOfframp_GetOfframpStatusResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kMistyswapUnavailable)))
    }
}
