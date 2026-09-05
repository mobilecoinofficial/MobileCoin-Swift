//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

final class FogKeyImageConnection: Connection<
        HttpProtocolConnectionFactory.FogKeyImageServiceProvider
    >,
    FogKeyImageService
{
    private let httpFactory: HttpProtocolConnectionFactory
    private let config: NetworkConfig
    private let targetQueue: DispatchQueue?
    private let rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?
    private let rngContext: Any?

    init(
        httpFactory: HttpProtocolConnectionFactory,
        config: NetworkConfig,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        self.httpFactory = httpFactory
        self.config = config
        self.targetQueue = targetQueue
        self.rng = rng
        self.rngContext = rngContext

        super.init(
            serviceFactory: { _ in
                httpFactory.makeFogKeyImageService(
                    config: config.fogKeyImageConfig(),
                    targetQueue: targetQueue,
                    rng: rng,
                    rngContext: rngContext)
            },
            transportProtocolOption: config.fogKeyImageConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
        service.checkKeyImages(request: request, completion: rotateURLOnError(completion))
    }
}
