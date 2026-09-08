//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

final class ConsensusConnection: Connection<
        HttpProtocolConnectionFactory.ConsensusServiceProvider
    >,
    ConsensusService
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
                httpFactory.makeConsensusService(
                    config: config.consensusConfig(),
                    targetQueue: targetQueue,
                    rng: rng,
                    rngContext: rngContext)
            },
            transportProtocolOption: config.consensusConfig().transportProtocolOption,
            targetQueue: targetQueue)
    }

    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        service.proposeTx(tx, completion: rotateURLOnError(completion))
    }
}
