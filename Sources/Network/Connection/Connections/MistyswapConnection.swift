//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class MistyswapConnection: Connection<
        GrpcProtocolConnectionFactory.MistyswapServiceProvider,
        HttpProtocolConnectionFactory.MistyswapServiceProvider
    >,
    MistyswapService
{
    private let httpFactory: HttpProtocolConnectionFactory
    private let grpcFactory: GrpcProtocolConnectionFactory
    private let config: NetworkConfig
    private let targetQueue: DispatchQueue?
    private let rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?
    private let rngContext: Any?

    init(
        httpFactory: HttpProtocolConnectionFactory,
        grpcFactory: GrpcProtocolConnectionFactory,
        config: NetworkConfig,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        self.httpFactory = httpFactory
        self.grpcFactory = grpcFactory
        self.config = config
        self.targetQueue = targetQueue
        self.rng = rng
        self.rngContext = rngContext

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                let rotatedConfig = config.mistyswapConfig()
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService:
                            grpcFactory.makeMistyswapService(
                                config: rotatedConfig,
                                targetQueue: targetQueue,
                                rng: rng,
                                rngContext: rngContext))
                case .http:
                    return .http(
                        httpService:
                            httpFactory.makeMistyswapService(
                                config: rotatedConfig,
                                targetQueue: targetQueue,
                                rng: rng,
                                rngContext: rngContext))
                }
            },
            transportProtocolOption: config.fogViewConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func initiateOfframp(request: Mistyswap_InitiateOfframpRequest, completion: @escaping (Result<Mistyswap_InitiateOfframpResponse, ConnectionError>) -> Void) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.initiateOfframp(
                request: request,
                completion: rotateURLOnError(completion))
        case .http(let httpConnection):
            httpConnection.initiateOfframp(
                request: request,
                completion: rotateURLOnError(completion))
        }
    }
    
    func forgetOfframp(request: LibMobileCoin.Mistyswap_ForgetOfframpRequest, completion: @escaping (Result<LibMobileCoin.Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void) {
//        switch connectionOptionWrapper {
//        case .grpc(let grpcConnection):
//            grpcConnection.query(
//                    requestAad: requestAad,
//                    request: request,
//                    completion: rotateURLOnError(completion))
//        case .http(let httpConnection):
//            httpConnection.query(
//                    requestAad: requestAad,
//                    request: request,
//                    completion: rotateURLOnError(completion))
//        }
    }
    
    func getOfframpStatus(request: LibMobileCoin.Mistyswap_GetOfframpStatusRequest, completion: @escaping (Result<LibMobileCoin.Mistyswap_GetOfframpStatusResponse, ConnectionError>) -> Void) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.getOfframpStatus(
                    request: request,
                    completion: rotateURLOnError(completion))
        case .http(let httpConnection):
            httpConnection.getOfframpStatus(
                    request: request,
                    completion: rotateURLOnError(completion))
        }
    }
    
}

extension EmptyMistyswapService: ConnectionProtocol {
    
}
