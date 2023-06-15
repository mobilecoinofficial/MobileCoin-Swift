//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin

struct TestBlockchainService: BlockchainService {
    let result: Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>

    func getLastBlockInfo(
        completion: @escaping
            (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(self.result)
        }
    }
}

extension TestBlockchainService {
    static func makeWithSuccess() -> TestBlockchainService {
        var response = ConsensusCommon_LastBlockInfoResponse()
        response.index = 100
        response.networkBlockVersion = 0
        return TestBlockchainService(result: .success(response))
    }

    init(successWithMinimumFee minimumFee: UInt64) {
        var response = ConsensusCommon_LastBlockInfoResponse()
        response.index = 100
        response.mobMinimumFee = minimumFee
        self.init(result: .success(response))
    }

    init(successWithBlockVersion blockVersion: BlockVersion) {
        var response = ConsensusCommon_LastBlockInfoResponse()
        response.index = 100
        response.networkBlockVersion = blockVersion
        self.init(result: .success(response))
    }
}
