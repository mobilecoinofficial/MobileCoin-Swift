//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

final class FogBlockConnection: Connection<
        HttpProtocolConnectionFactory.FogBlockServiceProvider
    >,
    FogBlockService
{
    private let httpFactory: HttpProtocolConnectionFactory
    private let config: NetworkConfig
    private let targetQueue: DispatchQueue?

    init(
        httpFactory: HttpProtocolConnectionFactory,
        config: NetworkConfig,
        targetQueue: DispatchQueue?
    ) {
        self.httpFactory = httpFactory
        self.config = config
        self.targetQueue = targetQueue

        super.init(
            serviceFactory: { _ in
                httpFactory.makeFogBlockService(
                    config: config.fogBlockConfig(),
                    targetQueue: targetQueue)
            },
            transportProtocolOption: config.fogBlockConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
        service.getBlocks(request: request, completion: rotateURLOnError(completion))
    }
}
