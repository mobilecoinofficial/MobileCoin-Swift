//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
import MobileCoin

final class BigUIntTests: XCTestCase {
    
    func testBigUIntInitializer() {
        let values = Array(repeating: UInt64.max, count: 5)
        guard let amount = BigUInt(values: values) else {
            XCTFail("BigUInt initialization failed when it should have succeeded.")
            return
        }
        
        XCTAssertEqual(amount.high, 4)
        
        // UInt64.max - 4 (number of wrap arounds)
        XCTAssertEqual(amount.low, 18446744073709551611)
    }
    
    func testAddingReportingOverflowHighByOne() {
        let bigUIntMax = BigUInt(low: UInt64.max, high: UInt64.max)
        let enoughToOverflow = BigUInt(low: 1, high: 0)
        
        let (partialValue, overflow) = bigUIntMax.addingReportingOverflow(enoughToOverflow)
        
        // Overflow (wrap-around) is expected
        XCTAssertEqual(overflow, true)
        
        XCTAssertEqual(partialValue.high, 0)
        
        // low == 0 is expected
        XCTAssertEqual(partialValue.low, 0)
    }
    
    func testAddingReportingOverflowHighByAlot() {
        let bigUIntMax = BigUInt(low: UInt64.max, high: UInt64.max)
        let enoughToOverflow = BigUInt(low: 1_000_000_000_000_001, high: 0)
        
        let (partialValue, overflow) = bigUIntMax.addingReportingOverflow(enoughToOverflow)
        
        // Overflow (wrap-around) is expected
        XCTAssertEqual(overflow, true)
        
        XCTAssertEqual(partialValue.high, 0)
        
        // low == (1_000_000_000_000_001 - 1) is expected
        XCTAssertEqual(partialValue.low, 1_000_000_000_000_000)
    }
    
    func testAddingReportingOverflowLowWrap() {
        let amount = BigUInt(low: UInt64.max, high: 100)
        let enoughToLowOverflow = BigUInt(low: 3, high: 100)
        
        let (partialValue, overflow) = amount.addingReportingOverflow(enoughToLowOverflow)
        
        // Overflow (wrap-around) is not expected
        XCTAssertEqual(overflow, false)
        
        XCTAssertEqual(partialValue.high, 201)
        
        // adding 3 to UInt64.max wraps so new low == (3 - 1)
        XCTAssertEqual(partialValue.low, 2)
    }
    
    func testAddingReportingOverflowNoWrap() {
        let amount = BigUInt(low: 3, high: 100)
        let anotherAmount = BigUInt(low: 3, high: 100)
        
        let (partialValue, overflow) = amount.addingReportingOverflow(anotherAmount)
        
        // Overflow (wrap-around) is not expected
        XCTAssertEqual(overflow, false)
        
        XCTAssertEqual(partialValue.high, 200)
        XCTAssertEqual(partialValue.low, 6)
    }
    
    func testSubtractingReportingOverflowLowByOne() {
        let zero = BigUInt(low: 0, high: 0)
        let enoughToOverflow = BigUInt(low: 1, high: 0)
        
        let (partialValue, overflow) = zero.subtractingReportingOverflow(enoughToOverflow)
        
        // Overflow (wrap-around) is expected
        XCTAssertEqual(overflow, true)
        
        XCTAssertEqual(partialValue.high, UInt64.max)
        XCTAssertEqual(partialValue.low, UInt64.max)
    }
    
    func testSubtractingReportingOverflowHighByAlot() {
        let amount = BigUInt(low: 1_000_000_000_000_001, high: 0)
        let enoughToOverflow = BigUInt(low: UInt64.max, high: UInt64.max)
        
        let (partialValue, overflow) = amount.subtractingReportingOverflow(enoughToOverflow)
        
        // Overflow (wrap-around/negative) is expected
        XCTAssertEqual(overflow, true)
        
        XCTAssertEqual(partialValue.high, UInt64.max)
        
        // low == (1_000_000_000_000_001 + 1) is expected
        XCTAssertEqual(partialValue.low, 1_000_000_000_000_002)
    }
    
    func testSubtractingReportingOverflowLowWrap() {
        let amount = BigUInt(low: 0, high: 300)
        let enoughToLowOverflow = BigUInt(low: 3, high: 100)
        
        let (partialValue, overflow) = amount.subtractingReportingOverflow(enoughToLowOverflow)
        
        // Overflow (wrap-around) is not expected
        XCTAssertEqual(overflow, false)
        
        XCTAssertEqual(partialValue.high, 199)
        
        // subtracting 3 to UInt64.max wraps so new low == (3 - 1)
        XCTAssertEqual(partialValue.low, UInt64.max - 2)
    }
    
    func testSubtractingReportingOverflowNoWrap() {
        let amount = BigUInt(low: 3, high: 100)
        let smallerAmount = BigUInt(low: 1, high: 100)
        
        let (partialValue, overflow) = amount.subtractingReportingOverflow(smallerAmount)
        
        // Overflow (wrap-around) is not expected
        XCTAssertEqual(overflow, false)
        
        XCTAssertEqual(partialValue.high, 0)
        XCTAssertEqual(partialValue.low, 2)
    }
    
    func testSubtractingSameAmountIsZero() {
        let amount = BigUInt(low: 3, high: 100)
        let sameAmount = BigUInt(low: 3, high: 100)
        
        let (partialValue, overflow) = amount.subtractingReportingOverflow(sameAmount)
        
        // Overflow (wrap-around) is not expected
        XCTAssertEqual(overflow, false)
        
        XCTAssertEqual(partialValue.high, 0)
        XCTAssertEqual(partialValue.low, 0)
    }
}
