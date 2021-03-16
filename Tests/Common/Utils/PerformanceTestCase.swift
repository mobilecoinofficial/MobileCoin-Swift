//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

class PerformanceTestCase: XCTestCase {

    class var defaultInvocationOptions: XCTMeasureOptions.InvocationOptions {
        []
    }

    override class var defaultMeasureOptions: XCTMeasureOptions {
        let options = XCTMeasureOptions.default
        options.invocationOptions = Self.defaultInvocationOptions
        return options
    }

    override func measure(_ block: () -> Void) {
        if #available(iOS 13.0, *) {
            self.measure(metrics: Self.defaultMetrics, block: block)
        } else {
            let manuallyStart = Self.defaultInvocationOptions.contains(.manuallyStart)
            self.measureMetrics(
                Self.defaultPerformanceMetrics,
                automaticallyStartMeasuring: !manuallyStart,
                for: block)
        }
    }

}
