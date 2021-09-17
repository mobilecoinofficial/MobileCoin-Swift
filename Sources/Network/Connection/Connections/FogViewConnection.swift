//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class FogViewConnection:
    Connection<FogViewGrpcConnection, FogViewHttpConnection>, FogViewService
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
                        grpcService: FogViewGrpcConnection(
                            config: config,
                            channelManager: channelManager,
                            targetQueue: targetQueue,
                            rng: rng,
                            rngContext: rngContext))
                case .http:
                    guard let requester = httpRequester else {
                        logger.fatalError("Transport Protocol is .http but no HttpRequester provided")
                    }
                    return .http(
                        httpService: FogViewHttpConnection(
                            config: config,
                            requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                            targetQueue: targetQueue,
                            rng: rng,
                            rngContext: rngContext))
                }
            },
            transportProtocolOption: config.transportProtocolOption,
            targetQueue: targetQueue)
    }

    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        switch connectionOptionWrapper {
        case .grpc(let grpcConnection):
            grpcConnection.query(requestAad: requestAad, request: request, completion: completion)
        case .http(let httpConnection):
            httpConnection.query(requestAad: requestAad, request: request, completion: completion)
        }
    }
}
