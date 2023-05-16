//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

// TODO - Could make a public wrapper around the proto with better type checking and
//        validations. For now, we will add extension to proto.

extension Mistyswap_ForgetOfframpRequest {
    
    static func make(offrampID: Data) -> Result<Self, InvalidInputError> {
        // Offramp ID should be 32 bytes
        guard let _ = Data32(offrampID) else {
            return .failure(InvalidInputError("offrampID should be 32 bytes"))
        }
        var proto = Mistyswap_ForgetOfframpRequest()
        proto.offrampID = offrampID
        return .success(proto)
    }
    
}

