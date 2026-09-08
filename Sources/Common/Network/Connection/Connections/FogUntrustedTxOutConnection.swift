//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

final class FogUntrustedTxOutConnection: Connection<
        HttpProtocolConnectionFactory.FogUntrustedTxOutServiceProvider
    >,
    FogUntrustedTxOutService
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
                httpFactory.makeFogUntrustedTxOutService(
                    config: config.fogUntrustedTxOutConfig(),
                    targetQueue: targetQueue)
            },
            transportProtocolOption: config.fogUntrustedTxOutConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getTxOuts(
        request: FogLedger_TxOutRequest,
        completion: @escaping (Result<FogLedger_TxOutResponse, ConnectionError>) -> Void
    ) {
        service.getTxOuts(request: request, completion: rotateURLOnError(completion))
    }
}
