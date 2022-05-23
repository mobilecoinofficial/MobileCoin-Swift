//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
@testable import MobileCoin

extension TransportProtocol {
    var testTimeoutInSeconds: Double {
        self.timeoutInSeconds + 2.0
    }
}
