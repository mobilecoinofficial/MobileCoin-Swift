//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class FogViewHttpConnection: AttestedHttpConnection, FogViewService {
    
    init(
        config: AttestedConnectionConfig<FogUrl>,
        client: HttpClientWrapper,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)? = securityRNG,
        rngContext: Any? = nil
    ) {
        super.init(client: client, config: config, targetQueue: targetQueue)
    }
    
    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        
    }

}
