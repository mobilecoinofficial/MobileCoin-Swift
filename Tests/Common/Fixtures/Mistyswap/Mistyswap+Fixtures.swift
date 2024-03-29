//
//  Copyright (c) 2023-2024 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin
import XCTest

enum Mistyswap {}

extension Mistyswap {
    enum Fixtures { }
}

extension Mistyswap.Fixtures {
    struct ForgetOfframp {
        let offrampID: Data32
        let badOfframpID: Data
        let request: MistyswapOfframp_ForgetOfframpRequest

        init() throws {
            self.offrampID = try XCTUnwrap(Data32(Data(randomOfLength: 32)))
            self.badOfframpID = try XCTUnwrap(Data(randomOfLength: 16))

            var request = MistyswapOfframp_ForgetOfframpRequest()
            request.offrampID = offrampID.data
            self.request = request
        }
    }
}

extension Mistyswap.Fixtures {
    struct InitiateOfframp {
        let request: MistyswapOfframp_InitiateOfframpRequest
        let goodJSON: String
        let badJSON: String
        let srcAssetID: String = MixinAssetID.MOB.rawValue
        let srcExpectedAmount: String = "111222333.666777888"
        let dstAssetID: String = MixinAssetID.EUSD.rawValue
        let dstAddress: String = ""
        let dstAddressTag: String = ""
        let minDstReceivedAmount: String = "111.222"
        let maxFeeAmountInDstTokens: String = "4.333"

        init() throws {
            let goodJSON = try Self.goodJSON()

            let result = MistyswapOfframp_InitiateOfframpRequest.make(
                mixinCredentialsJSON: goodJSON,
                srcAssetID: srcAssetID,
                srcExpectedAmount: srcExpectedAmount,
                dstAssetID: dstAssetID,
                dstAddress: dstAddress,
                dstAddressTag: dstAddressTag,
                minDstReceivedAmount: minDstReceivedAmount,
                maxFeeAmountInDstTokens: maxFeeAmountInDstTokens
            )

            switch result {
            case .success(let offrampRequest):
                self.request = offrampRequest
            case .failure(let error):
                throw error
            }

            self.goodJSON = goodJSON
            self.badJSON = Self.badJSON()
        }
    }
}

extension Mistyswap.Fixtures.InitiateOfframp {
    static func goodJSON() throws -> String {
        """
        {
            "client_id": "\(try Data(randomOfLength: 16).hexEncodedString())",
            "session_id": "\(try Data(randomOfLength: 16).hexEncodedString())",
            "private_key": "\(try Data(randomOfLength: 32).hexEncodedString())",
            "pin_token": "\(try Data(randomOfLength: 32).hexEncodedString())",
            "scope": "FULL",
            "pin": "\(try Data(randomOfLength: 32).hexEncodedString())"
        }
        """
    }

    static func badJSON() -> String {
        """
        {
            `invalid_surrounds`=`invalid`
        }
        """
    }
}

extension Mistyswap.Fixtures {
    struct GetOfframpStatus {
        let offrampID: Data32
        let badOfframpID: Data
        let request: MistyswapOfframp_GetOfframpStatusRequest

        init() throws {
            self.offrampID = try XCTUnwrap(Data32(Data(randomOfLength: 32)))
            self.badOfframpID = try XCTUnwrap(Data(randomOfLength: 16))

            var request = MistyswapOfframp_GetOfframpStatusRequest()
            request.offrampID = offrampID.data
            self.request = request
        }
    }
}
