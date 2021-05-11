//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

final class BlockchainFeeFetcher {
    private let blockchainService: BlockchainService

    init(blockchainService: BlockchainService) {
        self.blockchainService = blockchainService
    }

    func feeStrategy(
        for feeLevel: FeeLevel,
        completion: @escaping (Result<FeeStrategy, ConnectionError>) -> Void
    ) {
        switch feeLevel {
        case .minimum:
            fetchMinimumFee {
                completion($0.map { fee in
                    FixedFeeStrategy(fee: fee)
                })
            }
        }
    }

    func fetchMinimumFee(completion: @escaping (Result<UInt64, ConnectionError>) -> Void) {
        blockchainService.getLastBlockInfo {
            completion($0.map { response in
                let reportedFee = response.minimumFee
                guard reportedFee != 0 else {
                    return McConstants.DEFAULT_MINIMUM_FEE
                }
                return reportedFee
            })
        }
    }
}
