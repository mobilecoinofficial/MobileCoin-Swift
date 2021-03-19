//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

func XCTAssertNoThrow<T>(
    evaluating expression: () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertNoThrow(try expression(), message(), file: file, line: line)
}

func XCTAssertNoThrowOrFulfill<T>(
    expectation: XCTestExpectation,
    evaluating expression: () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    var caughtError: Error?
    let expressionWrapper = {
        do {
            _ = try expression()
        } catch {
            caughtError = error
            throw error
        }
    }
    XCTAssertNoThrow(evaluating: expressionWrapper, message(), file: file, line: line)

    if caughtError != nil {
        expectation.fulfill()
    }
}

func XCTAssertThrowsError<T>(
    evaluating expression: () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertThrowsError(try expression(), message(), file: file, line: line)
}
