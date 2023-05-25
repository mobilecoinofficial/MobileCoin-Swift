//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

// TODO - Could make a public wrapper around the proto with better type checking and
//        validations. For now, we will add extension to proto.

extension Mistyswap_InitiateOfframpRequest {
    static func make(
        mixinCredentialsJSON: String,
        srcAssetID: String,
        srcExpectedAmount: String,
        dstAssetID: String,
        dstAddress: String,
        dstAddressTag: String,
        minDstReceivedAmount: String,
        maxFeeAmountInDstTokens: String
    ) -> Result<Self, InvalidInputError> {
        JSONSerialization.verify(jsonString: mixinCredentialsJSON).map({ () in
            var proto = Mistyswap_InitiateOfframpRequest()
            proto.mixinCredentialsJson = mixinCredentialsJSON

            var params = Mistyswap_OfframpParams()
            params.srcAssetID = srcAssetID
            params.srcExpectedAmount = srcExpectedAmount
            params.dstAssetID = dstAssetID
            params.dstAddress = dstAddress
            params.dstAddressTag = dstAddressTag
            params.minDstReceivedAmount = minDstReceivedAmount
            params.maxFeeAmountInDstTokens = maxFeeAmountInDstTokens

            proto.params = params
            return proto
        })
    }
}
