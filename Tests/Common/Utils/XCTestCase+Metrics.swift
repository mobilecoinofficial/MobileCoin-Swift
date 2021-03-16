//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

extension XCTestCase {

    static var manualStartStopOptions: XCTMeasureOptions.InvocationOptions {
        [.manuallyStart, .manuallyStop]
    }

    static var manualStartOptions: XCTMeasureOptions.InvocationOptions {
        .manuallyStart
    }

    static var manualStopOptions: XCTMeasureOptions.InvocationOptions {
        .manuallyStop
    }

}
