//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
import XCTest

extension XCTestCase {
    /// Serialize the execution of tests for each supported protocol
    func testSupportedProtocols(
                description: String,
                timeout: Double = 40.0,
                interval: UInt32 = 10,
                _ testCase: (TransportProtocol, XCTestExpectation) throws -> Void
    ) rethrows {
        let supportedProtocols = [TransportProtocol.http]// TransportProtocol.supportedProtocols
        let last = supportedProtocols.last
        try supportedProtocols.forEach { transportProtocol in
            let description = "[\(transportProtocol.description)]:\(description)"
            print("Testing ... \(description)")
            let expect = expectation(description: description)
            try testCase(transportProtocol, expect)
            waitForExpectations(timeout: timeout)
            sleep(transportProtocol == last ? 0 : interval)
        }
    }

#if swift(>=5.5)
// swiftlint:disable superfluous_disable_command
// swiftlint:disable multiline_parameters

    @available(iOS 13.0, *)
    func testSupportedProtocols(
                description: String,
                timeout: Double = 80.0,
                interval: UInt64 = 10,
                _ testCase: @escaping (TransportProtocol) async throws -> Void
    ) async throws {
        let supportedProtocols = TransportProtocol.supportedProtocols
        let last = supportedProtocols.last
        for transportProtocol in supportedProtocols {
            let description = "[\(transportProtocol.description)]:\(description)"
            print("Testing ... \(description)")
            try await withTimeout(seconds: timeout) {
                try await testCase(transportProtocol)
            }
            try await Task.sleep(
                nanoseconds: UInt64(transportProtocol == last ? 0 : interval * 1_000_000_000)
            )
        }
    }

#endif

}
