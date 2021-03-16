//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest

extension Result {
    func successOrLeaveGroup(
        _ group: DispatchGroup,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Success? {
        XCTAssertNoThrow(try self.get(), message(), file: file, line: line)

        switch self {
        case .success(let value):
            return value
        case .failure:
            group.leave()
            return nil
        }
    }

    func failureOrLeaveGropu(
        _ group: DispatchGroup,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        XCTAssertThrowsError(try self.get(), message(), file: file, line: line)

        switch self {
        case .success:
            group.leave()
            return nil
        case .failure(let error):
            return error
        }
    }
}
