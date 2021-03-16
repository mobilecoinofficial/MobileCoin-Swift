//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments

@testable import MobileCoin
import XCTest

class UnsignedIntegerSafeComparisonTests: XCTestCase {

    func testSafeCompareSumWithValue() {
        let testCases: [TestCase1] = [
            t1([], 0, true, false),
            t1([], 1, false, true),

            t1([0], 0, true, false),
            t1([0], 1, false, true),

            t1([0, 0], 0, true, false),
            t1([0, 0], 1, false, true),
            t1([0, 1], 0, false, false),

            t1([1, 1, 2], 3, false, false),
            t1([1, 1, 2], 4, true, false),
            t1([1, 1, 2], 5, false, true),

            t1([UInt64.max], UInt64.max, true, false),
            t1([UInt64.max, 1], UInt64.max, false, false),

            t1([UInt64.max - 1, 1], UInt64.max, true, false),
            t1([UInt64.max - 1, 1], UInt64.max - 1, false, false),

            t1([UInt64.max, UInt64.max, UInt64.max], 0, false, false),
            t1([UInt64.max, UInt64.max, UInt64.max], UInt64.max, false, false),
        ]
        for (leftSide, rightSide, equals, lessThan, file, line) in testCases {
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isEqualToValue: rightSide),
                equals, "equal to", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isLessThanValue: rightSide),
                lessThan, "less than", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isLessThanOrEqualToValue: rightSide),
                lessThan || equals, "less than or equal to", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isGreaterThanValue: rightSide),
                !lessThan && !equals, "greater than", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isGreaterThanOrEqualToValue: rightSide),
                !lessThan, "greater than or equal to", file: file, line: line)
        }
    }

    func testSafeCompareSumWithSum() {
        let testCases: [TestCase2] = [
            t2([], [], true, false),

            t2([], [0], true, false),
            t2([], [1], false, true),
            t2([0], [], true, false),
            t2([1], [], false, false),

            t2([0], [0], true, false),
            t2([0], [1], false, true),

            t2([0, 0], [0], true, false),
            t2([0, 0], [1], false, true),
            t2([0, 1], [0], false, false),

            t2([0, 0], [0, 0], true, false),
            t2([0, 1], [1, 0], true, false),

            t2([1, 1, 2], [3], false, false),
            t2([1, 1, 2], [4], true, false),
            t2([1, 1, 2], [5], false, true),

            t2([UInt64.max], [UInt64.max], true, false),
            t2([UInt64.max], [UInt64.max, 1], false, true),
            t2([UInt64.max, 1], [UInt64.max], false, false),
            t2([UInt64.max, 1], [UInt64.max, 1], true, false),
            t2([UInt64.max, 1], [1, UInt64.max], true, false),

            t2([UInt64.max - 1], [UInt64.max - 1, 1], false, true),
            t2([UInt64.max - 1, 1], [UInt64.max], true, false),
            t2([UInt64.max - 1, 1], [UInt64.max - 1], false, false),

            t2([UInt64.max, UInt64.max], [UInt64.max, UInt64.max], true, false),
            t2([UInt64.max, UInt64.max], [UInt64.max, UInt64.max, 1], false, true),
            t2([UInt64.max, UInt64.max], [UInt64.max, UInt64.max, UInt64.max], false, true),
            t2([UInt64.max, UInt64.max - 1], [UInt64.max, UInt64.max], false, true),

            t2([UInt64.max, UInt64.max, UInt64.max], [0], false, false),
            t2([UInt64.max, UInt64.max, UInt64.max], [UInt64.max], false, false),
            t2([UInt64.max, UInt64.max, UInt64.max], [UInt64.max, UInt64.max], false, false),
        ]
        for (leftSide, rightSide, equals, lessThan, file, line) in testCases {
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isEqualToSumOfValues: rightSide),
                equals, "equal to", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isLessThanSumOfValues: rightSide),
                lessThan, "less than", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(
                    sumOfValues: leftSide,
                    isLessThanOrEqualToSumOfValues: rightSide),
                lessThan || equals, "less than or equal to", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(sumOfValues: leftSide, isGreaterThanSumOfValues: rightSide),
                !lessThan && !equals, "greater than", file: file, line: line)
            XCTAssertEqual(
                UInt64.safeCompare(
                    sumOfValues: leftSide,
                    isGreaterThanOrEqualToSumOfValues: rightSide),
                !lessThan, "greater than or equal to", file: file, line: line)
        }
    }

}

private typealias TestCase1 = (
    leftSide: [UInt64],
    rightSide: UInt64,
    equals: Bool,
    lessThan: Bool,
    file: StaticString,
    line: UInt
)

private func t1(
    _ leftSide: [UInt64],
    _ rightSide: UInt64,
    _ equals: Bool,
    _ lessThan: Bool,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase1 {
    (leftSide, rightSide, equals, lessThan, file, line)
}

private typealias TestCase2 = (
    leftSide: [UInt64],
    rightSide: [UInt64],
    equals: Bool,
    lessThan: Bool,
    file: StaticString,
    line: UInt
)

private func t2(
    _ leftSide: [UInt64],
    _ rightSide: [UInt64],
    _ equals: Bool,
    _ lessThan: Bool,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase2 {
    (leftSide, rightSide, equals, lessThan, file, line)
}
