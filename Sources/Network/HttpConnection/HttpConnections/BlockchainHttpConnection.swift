//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class BlockchainHttpConnection: ConnectionProtocol, BlockchainService {
    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
    }
    
    func setAuthorization(credentials: BasicCredentials) {
        
    }
}
