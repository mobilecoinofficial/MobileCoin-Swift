//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class FogKeyImageConnection:
    Connection<FogKeyImageGrpcConnection, FogKeyImageHttpConnection>, FogKeyImageService
{
    private let config: AttestedConnectionConfig<FogUrl>
    private let channelManager: GrpcChannelManager
    private let targetQueue: DispatchQueue?
    private let rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?
    private let rngContext: Any?

    init(
        config: AttestedConnectionConfig<FogUrl>,
        channelManager: GrpcChannelManager,
        httpRequester: HttpRequester?,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        self.config = config
        self.channelManager = channelManager
        self.targetQueue = targetQueue
        self.rng = rng
        self.rngContext = rngContext

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService: FogKeyImageGrpcConnection(
                            config: config,
                            channelManager: channelManager,
                            targetQueue: targetQueue,
                            rng: rng,
                            rngContext: rngContext))
                case .http:
                    guard let requester = httpRequester else {
                        logger.fatalError("Transport Protocol is .http but no HttpRequester provided")
                    }
                    return .http(httpService: FogKeyImageHttpConnection(
                                    config: config,
                                    requester: RestApiRequester(requester: requester, baseUrl:config.url.httpBasedUrl),
                                    targetQueue: targetQueue,
                                    rng: rng,
                                    rngContext: rngContext))
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.checkKeyImages(request: request, completion: completion)
        case .http(let httpConnection):
            httpConnection.checkKeyImages(request: request, completion: completion)
        }
    }
}
