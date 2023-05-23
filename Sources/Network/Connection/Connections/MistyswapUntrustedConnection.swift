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
                guard let rotatedConfig = config.mistyswapUntrustedConfig() else {
                    logger.fatalError(
                        "This should never happen, no config passed to create a mistyswap" +
                        " connection. Other checks should have caught this." +
                        " Fix this by using valid mistyswap URLs and attestation")
                }
                
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
        guard let _ = config.mistyswapUntrustedConfig() else {
            completion(
                .failure(
                    .connectionFailure(
                        "Config used to intialize your client " +
                        "did not include URLs or Attestation info for Mistyswap.")))
            return
        }
        
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
