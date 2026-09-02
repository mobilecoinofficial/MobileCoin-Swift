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
    func makeConsensusService(
        config: AttestedConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyConsensusService {
        EmptyConsensusService()
    }

    func makeBlockchainService(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> EmptyBlockchainService {
        EmptyBlockchainService()
    }

    func makeFogViewService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyFogViewService {
        EmptyFogViewService()
    }

    func makeFogMerkleProofService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyFogMerkleProofService {
        EmptyFogMerkleProofService()
    }

    func makeFogKeyImageService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyFogKeyImageService {
        EmptyFogKeyImageService()
    }

    func makeFogBlockService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> EmptyFogBlockService {
        EmptyFogBlockService()
    }

    func makeFogUntrustedTxOutService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> EmptyFogUntrustedTxOutService {
        EmptyFogUntrustedTxOutService()
    }

    func makeFogReportService(
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) -> EmptyFogReportService {
        EmptyFogReportService()
    }

    func makeMistyswapService(
        config: AttestedConnectionConfig<MistyswapUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> EmptyMistyswapService {
        EmptyMistyswapService()
    }
}

// These stand-ins back the empty GrpcProtocolConnectionFactory in builds with
// no grpc transport. They used to call assertionFailure and return, which is a
// no-op in release, so the completion never fired and the caller hung forever.
private let kGrpcUnavailable = "GRPC transport is not compiled into this build"

class EmptyConsensusService: ConsensusService, ConnectionProtocol, ConsensusServiceConnection {
    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

typealias LastBlockInfoRespResult = Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>
class EmptyBlockchainService: BlockchainService, ConnectionProtocol, BlockchainServiceConnection {
    func getLastBlockInfo(
        completion: @escaping (LastBlockInfoRespResult) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogViewService: FogViewService, ConnectionProtocol, FogViewServiceConnection {
    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogMerkleProofService: FogMerkleProofService,
    ConnectionProtocol,
    FogMerkleProofServiceConnection
{
    func getOutputs(
        request: FogLedger_GetOutputsRequest,
        completion: @escaping (Result<FogLedger_GetOutputsResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogKeyImageService: FogKeyImageService,
    ConnectionProtocol,
    FogKeyImageServiceConnection
{
    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogBlockService: FogBlockService, ConnectionProtocol, FogBlockServiceConnection {
    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogUntrustedTxOutService: FogUntrustedTxOutService,
    ConnectionProtocol,
    FogUntrustedTxOutServiceConnection
{
    func getTxOuts(
        request: FogLedger_TxOutRequest,
        completion: @escaping (Result<FogLedger_TxOutResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyFogReportService: FogReportService {
    func getReports(
        request: Report_ReportRequest,
        completion: @escaping (Result<Report_ReportResponse, ConnectionError>) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyMistyswapService: MistyswapService {
    func forgetOfframp(
        request: MistyswapOfframp_ForgetOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_ForgetOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }

    func initiateOfframp(
        request: MistyswapOfframp_InitiateOfframpRequest,
        completion: @escaping (
            Result<MistyswapOfframp_InitiateOfframpResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }

    func getOfframpStatus(
        request: MistyswapOfframp_GetOfframpStatusRequest,
        completion: @escaping (
            Result<MistyswapOfframp_GetOfframpStatusResponse, ConnectionError>
        ) -> Void
    ) {
        completion(.failure(.connectionFailure(kGrpcUnavailable)))
    }
}

class EmptyProtocolConnectionFactory: ProtocolConnectionFactory { }
