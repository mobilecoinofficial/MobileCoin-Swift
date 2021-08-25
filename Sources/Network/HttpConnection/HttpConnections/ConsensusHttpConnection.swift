//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class ConsensusHttpConnection: ConnectionProtocol, ConsensusService {
    func proposeTx(
        _ tx: External_Tx,
        completion: @escaping (Result<ConsensusCommon_ProposeTxResponse, ConnectionError>) -> Void
    ) {
        
    }
    
    func setAuthorization(credentials: BasicCredentials) {
        
    }
}
