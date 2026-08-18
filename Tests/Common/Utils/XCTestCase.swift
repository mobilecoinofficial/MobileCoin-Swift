//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import class XCTest.XCTestCase

class XCTestCase: XCTest.XCTestCase {

    private static let isLoggingInitialized: Bool = {
        MobileCoinLogging.logSensitiveData = true
        MobileCoinLogging.logLevel = .trace
        return true
    }()

    override class func setUp() {
        super.setUp()
        assert(isLoggingInitialized)
    }

}
