//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class MistyswapUntrustedConnection: Connection<
        GrpcProtocolConnectionFactory.MistyswapUntrustedServiceProvider,
        HttpProtocolConnectionFactory.MistyswapUntrustedServiceProvider
    >,
    MistyswapUntrustedService
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
                let rotatedConfig = config.mistyswapUntrustedConfig()
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService:
                            grpcFactory.makeMistyswapUntrustedService(
                                config: rotatedConfig,
                                targetQueue: targetQueue
                            )
                    )
                case .http:
                    return .http(
                        httpService:
                            httpFactory.makeMistyswapUntrustedService(
                                config: rotatedConfig,
                                targetQueue: targetQueue
                            )
                    )
                }
            },
            transportProtocolOption: config.fogViewConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func forgetOfframp(request: Mistyswap_ForgetOfframpRequest, completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>) -> Void) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.forgetOfframp(
                    request: request,
                    completion: rotateURLOnError(completion))
        case .http(let httpConnection):
            httpConnection.forgetOfframp(
                    request: request,
                    completion: rotateURLOnError(completion))
        }
    }
    
}
extension EmptyMistyswapUntrustedService: ConnectionProtocol { }
