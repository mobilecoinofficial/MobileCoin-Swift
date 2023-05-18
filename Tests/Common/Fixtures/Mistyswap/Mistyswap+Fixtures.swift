//
//  Copyright (c) 2023-2024 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import Foundation
@testable import MobileCoin
@testable import LibMobileCoin
import XCTest

enum Mistyswap {}

extension Mistyswap {
    enum Fixtures { }
}

extension Mistyswap.Fixtures {
    struct ForgetOfframp {
        let offrampID: Data32
        let badOfframpID: Data
        let request: Mistyswap_ForgetOfframpRequest

        init() throws {
            self.offrampID = try XCTUnwrap(Data32(Data.init(randomOfLength: 32)))
            self.badOfframpID = try XCTUnwrap(Data.init(randomOfLength: 16))
            
            
            var request = Mistyswap_ForgetOfframpRequest()
            request.offrampID = offrampID.data
            self.request = request
        }
    }
}

extension Mistyswap.Fixtures {
    struct InitiateOfframp {
        let request: Mistyswap_InitiateOfframpRequest
        let goodJSON: String
        let badJSON: String
        let srcAssetID: String = "eea900a8-b327-488c-8d8d-1428702fe240"
        let srcExpectedAmount: String = "111222333.666777888"
        let dstAssetID: String = "659c407a-0489-30bf-9e6f-84ef25c971c9"
        let dstAddress: String = ""
        let dstAddressTag: String = ""
        let minDstReceivedAmount: String = "111.222"
        let maxFeeAmountInDstTokens: String = "4.333"

        init() throws {
            self.request = try XCTUnwrapSuccess(Mistyswap_InitiateOfframpRequest.make(
                mixinCredentialsJSON: Self.goodJSON(),
                srcAssetID: srcAssetID,
                srcExpectedAmount: srcExpectedAmount,
                dstAssetID: dstAssetID,
                dstAddress: dstAddress,
                dstAddressTag: dstAddressTag,
                minDstReceivedAmount: minDstReceivedAmount,
                maxFeeAmountInDstTokens: maxFeeAmountInDstTokens
            ))
            self.goodJSON = try Self.goodJSON()
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
        let request: Mistyswap_GetOfframpStatusRequest

        init() throws {
            self.offrampID = try XCTUnwrap(Data32(Data.init(randomOfLength: 32)))
            self.badOfframpID = try XCTUnwrap(Data.init(randomOfLength: 16))
            
            var request = Mistyswap_GetOfframpStatusRequest()
            request.offrampID = offrampID.data
            self.request = request
        }
    }
}
