//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
import XCTest

//class SupportedProtocolsTestCase: XCTestCase {
//
//    /// Serialize the execution of tests for each supported protocol
//    func testSupportedProtocols(
//                description: String,
//                timeout: Double = 40.0,
//                interval: UInt32 = 10,
//                _ testCase: (TransportProtocol, XCTestExpectation) throws -> Void
//    ) rethrows {
//        let supportedProtocols = TransportProtocol.supportedProtocols
//        let last = supportedProtocols.last
//        try supportedProtocols.forEach { transportProtocol in
//            let description = "[\(transportProtocol.description)]:\(description)"
//            print("Testing ... \(description)")
//            let expect = expectation(description: description)
//            try testCase(transportProtocol, expect)
//            waitForExpectations(timeout: timeout)
//            sleep(transportProtocol == last ? 0 : interval)
//        }
//    }
//}
