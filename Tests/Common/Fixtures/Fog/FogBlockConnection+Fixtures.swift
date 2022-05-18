//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

extension FogBlockConnection {
    enum Fixtures {}
}

extension FogBlockConnection.Fixtures {
    struct Default {
        let request: FogLedger_BlockRequest
        let range: Range<UInt64>
        
        init() {
            var request = FogLedger_BlockRequest()
            request.rangeValues = [Self.getNetworkRange()]
            self.request = request
            self.range = Self.getNetworkRange()
        }
        
        static func getNetworkRange() -> Range<UInt64> {
            switch IntegrationTestFixtures.network {
            case .mobiledev:
                return 10..<11
            case .testNet:
                return 1..<2
            default:
                return 1..<2
            }
        }
    }
}
