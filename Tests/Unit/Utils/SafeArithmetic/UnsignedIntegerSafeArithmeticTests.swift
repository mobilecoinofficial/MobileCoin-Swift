//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_arguments

@testable import MobileCoin
import XCTest

class UnsignedIntegerSafeArithmeticTests: XCTestCase {

    func testSafeSum() {
        let testCases: [TestCaseSum] = [
            t([], 0),
            t([0], 0),
            t([0, 0], 0),
            t([0, 1], 1),
            t([1, 1, 2], 4),

            t([UInt64.max], UInt64.max),
            t([UInt64.max, 0], UInt64.max),
            t([UInt64.max - 1, 1], UInt64.max),

            t([UInt64.max, 1], nil),
            t([UInt64.max, UInt64.max, UInt64.max], nil),
            t([1, UInt64.max - 1, 1], nil),
        ]
        for (values, sum, file, line) in testCases {
            XCTAssertEqual(UInt64.safeSum(values: values), sum, file: file, line: line)
        }
    }

    private let testCases1: [TestCase1] = [
        t1(0, 0, 0),
        t1(1, 0, 1),
        t1(1, 1, 0),

        t1(UInt64.max, 0, UInt64.max),
        t1(UInt64.max, 1, UInt64.max - 1),
        t1(UInt64.max, UInt64.max, 0),
        t1(UInt64.max, UInt64.max - 1, 1),

        t1(0, 1, nil),
        t1(0, UInt64.max, nil),
        t1(UInt64.max - 1, UInt64.max, nil),
    ]

    func testSafeSubtractValueMinusValue() {
        for (leftSide, rightSide, difference, file, line) in testCases1 {
            XCTAssertEqual(
                UInt64.safeSubtract(value: leftSide, minusValue: rightSide),
                difference, file: file, line: line)
        }
    }

    private let testCases2: [TestCase2] = [
        t2([], 0, 0),
        t2([0, 0], 0, 0),
        t2([0, 1], 0, 1),
        t2([0, 1], 1, 0),
        t2([1, 1, 2], 0, 4),
        t2([1, 1, 2], 4, 0),

        t2([UInt64.max, 0], 0, UInt64.max),
        t2([UInt64.max, 0], UInt64.max, 0),
        t2([UInt64.max - 1], UInt64.max - 1, 0),
        t2([UInt64.max - 1], 1, UInt64.max - 2),
        t2([UInt64.max - 1], UInt64.max - 2, 1),
        t2([UInt64.max - 1, 1], 0, UInt64.max),
        t2([UInt64.max - 1, 1], UInt64.max, 0),
        t2([UInt64.max - 1, 1], 1, UInt64.max - 1),
        t2([UInt64.max - 1, 1], UInt64.max - 1, 1),
        t2([UInt64.max - 1, UInt64.max], UInt64.max - 1, UInt64.max),
        t2([UInt64.max - 1, UInt64.max], UInt64.max, UInt64.max - 1),
        t2([0, UInt64.max], 0, UInt64.max),
        t2([0, UInt64.max], UInt64.max, 0),
        t2([0, UInt64.max], 1, UInt64.max - 1),
        t2([0, UInt64.max], UInt64.max - 1, 1),
        t2([1, UInt64.max], 1, UInt64.max),
        t2([1, UInt64.max], UInt64.max, 1),
        t2([1, UInt64.max, 1], 2, UInt64.max),
        t2([1, UInt64.max, 1], UInt64.max, 2),
        t2([1, UInt64.max - 1, 1], 1, UInt64.max),
        t2([1, UInt64.max - 1, 1], UInt64.max, 1),

        // Negative
        t2([], 1, nil),
        t2([], UInt64.max, nil),
        t2([0, 0], 1, nil),
        t2([0, 0], UInt64.max, nil),
        t2([0, 1], 2, nil),
        t2([0, 1], UInt64.max, nil),
        t2([1, 1, 2], 5, nil),
        t2([1, 1, 2], UInt64.max, nil),
        t2([UInt64.max - 1, 0], UInt64.max, nil),

        // Overflow
        t2([UInt64.max, 1], 0, nil),
        t2([UInt64.max, UInt64.max], UInt64.max - 1, nil),
        t2([UInt64.max, UInt64.max, 1], UInt64.max, nil),
        t2([UInt64.max - 1, 2], 0, nil),
        t2([UInt64.max - 1, UInt64.max], UInt64.max - 2, nil),
        t2([1, UInt64.max], 0, nil),
        t2([1, UInt64.max, 1], 0, nil),
        t2([1, UInt64.max, 1], 1, nil),
        t2([1, UInt64.max - 1, 1], 0, nil),
        t2([1, UInt64.max, UInt64.max - 1], UInt64.max - 1, nil),
        t2([1, UInt64.max, UInt64.max], UInt64.max, nil),
        t2([2, UInt64.max, UInt64.max - 1], UInt64.max, nil),
        t2([UInt64.max, UInt64.max, UInt64.max], 0, nil),
        t2([UInt64.max, UInt64.max, UInt64.max], UInt64.max, nil),
    ]

    func testSafeSubtractSumMinusValue() {
        for (leftSide, rightSide, difference, file, line) in testCases1 {
            XCTAssertEqual(
                UInt64.safeSubtract(sumOfValues: [leftSide], minusValue: rightSide),
                difference, file: file, line: line)
        }
        for (leftSide, rightSide, difference, file, line) in testCases2 {
            XCTAssertEqual(
                UInt64.safeSubtract(sumOfValues: leftSide, minusValue: rightSide),
                difference, file: file, line: line)
        }
    }

    private let testCases3: [TestCase3] = [
        t3([], [], 0),
        t3([0], [], 0),
        t3([0, 0], [], 0),
        t3([0, 1], [], 1),
        t3([1, 1, 2], [], 4),
        t3([0, 0], [0, 0], 0),
        t3([0, 1], [1, 0], 0),
        t3([1, 1, 2], [0, 0], 4),
        t3([1, 1, 2], [1, 1, 1], 1),
        t3([1, 1, 2], [1, 2, 1], 0),

        t3([UInt64.max], [], UInt64.max),
        t3([UInt64.max], [0, 0], UInt64.max),
        t3([UInt64.max], [UInt64.max, 0], 0),
        t3([UInt64.max, 0], [], UInt64.max),
        t3([UInt64.max, 0], [0, UInt64.max], 0),
        t3([UInt64.max - 1, 1], [], UInt64.max),
        t3([UInt64.max - 1, UInt64.max], [UInt64.max - 1, UInt64.max], 0),
        t3([UInt64.max - 1, UInt64.max], [UInt64.max - 1, UInt64.max - 1], 1),
        t3([UInt64.max - 1, UInt64.max, 1], [UInt64.max, UInt64.max - 1], 1),
        t3([UInt64.max, UInt64.max, UInt64.max], [UInt64.max, UInt64.max], UInt64.max),
        t3([UInt64.max, UInt64.max, UInt64.max], [UInt64.max, UInt64.max, UInt64.max], 0),

        // Negative
        t3([], [1, UInt64.max], nil),
        t3([], [UInt64.max, UInt64.max], nil),
        t3([1, 1, 2], [2, 3], nil),
        t3([1, 1, 2], [1, 1, 1, 2], nil),
        t3([1, 1, 2], [UInt64.max, UInt64.max, UInt64.max], nil),
        t3([UInt64.max - 1], [UInt64.max - 1, 1], nil),
        t3([UInt64.max - 1, 0], [UInt64.max, 0], nil),
        t3([UInt64.max, UInt64.max, UInt64.max - 1], [UInt64.max, UInt64.max, UInt64.max], nil),

        // Overflow
        t3([UInt64.max, 1], [], nil),
        t3([UInt64.max - 1, 2], [], nil),
        t3([UInt64.max, UInt64.max], [], nil),
        t3([UInt64.max, 1], [0, 0], nil),
        t3([UInt64.max, 2], [0, 1], nil),
        t3([UInt64.max, UInt64.max, 1], [UInt64.max - 1, 1], nil),
        t3([UInt64.max, UInt64.max, UInt64.max], [], nil),
        t3([1, UInt64.max - 1, 1], [], nil),
        t3([1, UInt64.max, UInt64.max - 1], [1, UInt64.max - 2], nil),
        t3([1, UInt64.max, UInt64.max], [UInt64.max], nil),
        t3([2, UInt64.max, UInt64.max - 1], [UInt64.max], nil),
        t3([UInt64.max, UInt64.max, UInt64.max], [UInt64.max, UInt64.max - 1], nil),
        t3([UInt64.max, UInt64.max, UInt64.max, UInt64.max], [UInt64.max, UInt64.max], nil),
    ]

    func testSafeSubtractSumMinusSum() {
        for (leftSide, rightSide, difference, file, line) in testCases1 {
            XCTAssertEqual(
                UInt64.safeSubtract(sumOfValues: [leftSide], minusSumOfValues: [rightSide]),
                difference, file: file, line: line)
        }
        for (leftSide, rightSide, difference, file, line) in testCases2 {
            XCTAssertEqual(
                UInt64.safeSubtract(sumOfValues: leftSide, minusSumOfValues: [rightSide]),
                difference, file: file, line: line)
        }
        for (leftSide, rightSide, difference, file, line) in testCases3 {
            XCTAssertEqual(
                UInt64.safeSubtract(sumOfValues: leftSide, minusSumOfValues: rightSide),
                difference, file: file, line: line)
        }
    }

}

private typealias TestCaseSum = (
    values: [UInt64],
    sum: UInt64?,
    file: StaticString,
    line: UInt
)

private func t(
    _ values: [UInt64],
    _ sum: UInt64?,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCaseSum {
    (values, sum, file, line)
}

private typealias TestCase1 = (
    leftSide: UInt64,
    rightSide: UInt64,
    difference: UInt64?,
    file: StaticString,
    line: UInt
)

private func t1(
    _ leftSide: UInt64,
    _ rightSide: UInt64,
    _ difference: UInt64?,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase1 {
    (leftSide, rightSide, difference, file, line)
}

private typealias TestCase2 = (
    leftSide: [UInt64],
    rightSide: UInt64,
    difference: UInt64?,
    file: StaticString,
    line: UInt
)

private func t2(
    _ leftSide: [UInt64],
    _ rightSide: UInt64,
    _ difference: UInt64?,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase2 {
    (leftSide, rightSide, difference, file, line)
}

private typealias TestCase3 = (
    leftSide: [UInt64],
    rightSide: [UInt64],
    difference: UInt64?,
    file: StaticString,
    line: UInt
)

private func t3(
    _ leftSide: [UInt64],
    _ rightSide: [UInt64],
    _ difference: UInt64?,
    file: StaticString = #file,
    line: UInt = #line
) -> TestCase3 {
    (leftSide, rightSide, difference, file, line)
}
