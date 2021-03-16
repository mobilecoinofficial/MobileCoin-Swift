//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

extension Result {
    func successOrFulfill(
        expectation: XCTestExpectation,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Success? {
        XCTAssertNoThrow(try self.get(), message(), file: file, line: line)

        switch self {
        case .success(let value):
            return value
        case .failure:
            expectation.fulfill()
            return nil
        }
    }

    func failureOrFulfill(
        expectation: XCTestExpectation,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Failure? {
        XCTAssertThrowsError(try self.get(), message(), file: file, line: line)

        switch self {
        case .success:
            expectation.fulfill()
            return nil
        case .failure(let error):
            return error
        }
    }
}
