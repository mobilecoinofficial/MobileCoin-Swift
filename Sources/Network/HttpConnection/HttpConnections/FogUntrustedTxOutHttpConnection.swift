//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class FogUntrustedTxOutHttpConnection: ConnectionProtocol, FogUntrustedTxOutService {
    func getTxOuts(
        request: FogLedger_TxOutRequest,
        completion: @escaping (Result<FogLedger_TxOutResponse, ConnectionError>) -> Void
    ) {
    }
    
    func setAuthorization(credentials: BasicCredentials) {
        
    }
}
