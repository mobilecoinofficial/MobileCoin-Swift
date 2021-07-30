//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class FogBlockHttpConnection: ConnectionProtocol, FogBlockService {
    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
    }
    
    func setAuthorization(credentials: BasicCredentials) {
        
    }
}
