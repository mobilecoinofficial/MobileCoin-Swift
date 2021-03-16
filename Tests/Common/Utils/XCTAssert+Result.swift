//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments vertical_parameter_alignment_on_call

import XCTest

func XCTAssertSuccess<Success, Failure: Error>(
    _ expression: @autoclosure () throws -> Result<Success, Failure>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let value = try expression()
        if case .success = value {
            return
        } else {
            XCTFail("XCTAssertSuccess failed: \"\(value)\" - \(message())", file: file, line: line)
        }
    } catch {
        XCTFail("XCTAssertSuccess threw error \"\(error)\" - \(message())", file: file, line: line)
    }
}

func XCTAssertFailure<Success, Failure: Error>(
    _ expression: @autoclosure () throws -> Result<Success, Failure>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let value = try expression()
        if case .failure = value {
            return
        } else {
            XCTFail("XCTAssertFailure failed: \"\(value)\" - \(message())", file: file, line: line)
        }
    } catch {
        XCTFail("XCTAssertFailure threw error \"\(error)\" - \(message())", file: file, line: line)
    }
}

func XCTAssertSuccessEqual<T: Equatable, Failure: Error>(
    _ expression1: @autoclosure () throws -> Result<T, Failure>,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let value1 = try expression1()
        let value2 = try expression2()
        if case .success(let value1) = value1 {
            if value1 != value2 {
                XCTFail(
                    "XCTAssertSuccessEqual failed: \"\(value1)\" != \"\(value2)\" - \(message())",
                    file: file,
                    line: line)
            }
            return
        } else {
            XCTFail("XCTAssertSuccessEqual failed: \"\(value1)\" - \(message())",
                file: file, line: line)
        }
    } catch {
        XCTFail(
            "XCTAssertSuccessEqual threw error \"\(error)\" - \(message())", file: file, line: line)
    }
}

func XCTUnwrapSuccess<Success, Failure: Error>(
    _ expression: @autoclosure () throws -> Result<Success, Failure>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) throws -> Success {
    let caughtError: Error
    do {
        let value = try expression()
        switch value {
        case .success(let success):
            return success
        case .failure(let error):
            XCTFail("XCTUnwrapSuccess failed: \"\(value)\" - \(message())", file: file, line: line)
            caughtError = error
        }
    } catch {
        XCTFail("XCTUnwrapSuccess threw error \"\(error)\" - \(message())", file: file, line: line)
        caughtError = error
    }
    throw caughtError
}

func XCTUnwrapFailure<Success, Failure: Error>(
    _ expression: @autoclosure () throws -> Result<Success, Failure>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) throws -> Failure {
    let caughtError: Error
    do {
        let value = try expression()
        switch value {
        case .success:
            let failMessage = "XCTUnwrapFailure failed: \"\(value)\" - \(message())"
            XCTFail(failMessage, file: file, line: line)
            caughtError = TestingError(failMessage)
        case .failure(let error):
            return error
        }
    } catch {
        XCTFail("XCTUnwrapFailure threw error \"\(error)\" - \(message())", file: file, line: line)
        caughtError = error
    }
    throw caughtError
}
