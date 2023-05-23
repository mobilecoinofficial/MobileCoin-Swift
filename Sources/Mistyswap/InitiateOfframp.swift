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
            proto.srcAssetID = srcAssetID
            proto.srcExpectedAmount = srcExpectedAmount
            proto.dstAssetID = dstAssetID
            proto.dstAddress = dstAddress
            proto.dstAddressTag = dstAddressTag
            proto.minDstReceivedAmount = minDstReceivedAmount
            proto.maxFeeAmountInDstTokens = maxFeeAmountInDstTokens
            return proto
        })
    }
}

public struct InitiateOfframpResponse {
    public let offrampResult: OfframpResult
   
    public var offrampID: Data {
        response.offrampID
    }
    
    public var srcAssetID: String {
        response.srcAssetID
    }
    
    public var dstAssetID: String {
        response.dstAssetID
    }
    
    private let response: Mistyswap_InitiateOfframpResponse
}

extension InitiateOfframpResponse {
    init(response: Mistyswap_InitiateOfframpResponse) {
        self.offrampResult = OfframpResult(result: response.result)
        self.response = response
    }
}

public struct OfframpResult {
    public var code: Int {
        result.code.rawValue
    }
        
    public var codeDescription: String {
        "\(String(describing: result.code).camelCaseToWords()) - \(code)"
    }
    
    public var message: String {
        result.message
    }
    
    public var offrampID: Data {
        result.offrampID
    }
        
    private let result: Mistyswap_OfframpResult
    
    init(result: Mistyswap_OfframpResult) {
        self.result = result
    }
}
