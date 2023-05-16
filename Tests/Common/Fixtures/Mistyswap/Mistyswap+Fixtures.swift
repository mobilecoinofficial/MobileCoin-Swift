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
        let srcAssetID: String = "67e55044-10b1-426f-9247-bb680e5fe0c8"
        let srcExpectedAmount: String = "111222333444.666777888"
        let dstAssetID: String = "67e55044-10b1-426f-9247-bb680e5fe0c8"
        let dstAddress: String = ""
        let dstAddressTag: String = ""
        let minDstReceivedAmount: String = "111222333444.111222333444"
        let maxFeeAmountInDstTokens: String = "11222.333"

        init() throws {
            var request = Mistyswap_InitiateOfframpRequest()
            self.request = request
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
