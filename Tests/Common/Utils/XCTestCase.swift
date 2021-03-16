//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Logging
import MobileCoin
import class XCTest.XCTestCase

class XCTestCase: XCTest.XCTestCase {

    private static let isLoggingInitialized: Bool = {
        MobileCoinLogging.logSensitiveData = true

        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .trace
            return handler
        }

        return true
    }()

    override class func setUp() {
        super.setUp()
        assert(isLoggingInitialized)
    }

}
