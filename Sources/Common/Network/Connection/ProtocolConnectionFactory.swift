//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
import LibMobileCoinCommon

protocol ProtocolConnectionFactory {
    associatedtype ConsensusServiceProvider: ConsensusServiceConnection
    associatedtype BlockchainServiceProvider: BlockchainServiceConnection
    associatedtype FogViewServiceProvider: FogViewServiceConnection
    associatedtype FogMerkleProofServiceProvider: FogMerkleProofServiceConnection
    associatedtype FogKeyImageServiceProvider: FogKeyImageServiceConnection
    associatedtype FogBlockServiceProvider: FogBlockServiceConnection
    associatedtype FogUntrustedTxOutServiceProvider: FogUntrustedTxOutServiceConnection
    associatedtype FogReportServiceProvider: FogReportService
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
}
