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
        let request: Mistyswap_ForgetOfframpRequest

        init() throws {
            self.offrampID = try XCTUnwrap(Data32(Data.init(randomOfLength: 32)))
            
            var request = Mistyswap_ForgetOfframpRequest()
            request.offrampID = offrampID.data
            self.request = request
        }
    }
}

