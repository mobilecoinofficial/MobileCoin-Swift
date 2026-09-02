//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin

struct TestConsensusService: ConsensusService {
    let result: Result<ConsensusCommon_ProposeTxResponse, ConnectionError>

    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        // `ConsensusService` declares its completion without `@Sendable`, so it
        // cannot cross onto the main queue on its own.
        nonisolated(unsafe) let completion = completion
        let result = self.result
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

extension TestConsensusService {
    static func makeWithSuccess() -> TestConsensusService {
        let response = ConsensusCommon_ProposeTxResponse()
        return TestConsensusService(result: .success(response))
    }

    init(failureWithResult result: ConsensusCommon_ProposeTxResult, blockVersion: BlockVersion) {
        var response = ConsensusCommon_ProposeTxResponse()
        response.blockVersion = blockVersion
        response.result = result
        self.init(result: .success(response))
    }

    init(successWithBlockVersion blockVersion: BlockVersion) {
        var response = ConsensusCommon_ProposeTxResponse()
        response.blockVersion = blockVersion
        self.init(result: .success(response))
    }
}
