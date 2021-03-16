//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

func XCTSkip(
    _ message: @autoclosure () -> String? = nil,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    #if swift(>=5.2)
    try XCTSkipIf(true)
    #endif
}

/// Evaluates a boolean expression and, if it is false, throws an error which
/// causes the current test to cease executing and be marked as skipped.
func XCTSkipUnless(
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String? = nil,
    file: StaticString = #file,
    line: UInt = #line
) throws {
    #if swift(>=5.2)
    try XCTSkipIf(!expression())
    #endif
}
