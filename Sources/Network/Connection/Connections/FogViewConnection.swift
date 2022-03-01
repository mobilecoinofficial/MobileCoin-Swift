//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class FogViewConnection:
    Connection<GrpcProtocolConnectionFactory.FogViewServiceProvider, HttpProtocolConnectionFactory.FogViewServiceProvider>, FogViewService
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
                let rotatedConfig = config.fogViewConfig()
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService:
                            grpcFactory.makeFogViewService(
                                config: rotatedConfig,
                                targetQueue: targetQueue,
                                rng: rng,
                                rngContext: rngContext))
                case .http:
                    return .http(
                        httpService:
                            httpFactory.makeFogViewService(
                                config: rotatedConfig,
                                targetQueue: targetQueue,
                                rng: rng,
                                rngContext: rngContext))
                }
            },
            transportProtocolOption: config.fogViewConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }


    func completionResultIntercept(
        _ result: Result<FogView_QueryResponse, ConnectionError>,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        switch result {
        case .success:
            completion(result)
        case .failure:
            logger.debug("FogViewConnection - rotating config on error")
            super.rotateConnection()
            completion(result)
        }
    }
    
    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.query(requestAad: requestAad, request: request) { result in
                self.completionResultIntercept(result, completion: completion)
            }
        case .http(let httpConnection):
            httpConnection.query(requestAad: requestAad, request: request) { result in
                self.completionResultIntercept(result, completion: completion)
            }
        }
    }
}
