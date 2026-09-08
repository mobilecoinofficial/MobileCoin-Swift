//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
import SwiftProtobuf

final class BlockchainConnection: Connection<
        HttpProtocolConnectionFactory.BlockchainServiceProvider
    >,
    BlockchainService
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
                httpFactory.makeBlockchainService(
                    config: config.blockchainConfig(),
                    targetQueue: targetQueue)
            },
            transportProtocolOption: config.blockchainConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
        service.getLastBlockInfo(completion: rotateURLOnError(completion))
    }
}
