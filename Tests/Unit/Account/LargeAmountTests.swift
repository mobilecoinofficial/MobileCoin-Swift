//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin


final class LargeAmountTests: XCTestCase {
        
    func testDenominatorFivePowDeci() {
        let value = UInt64.pow(x: .five, y: SIPrefix.deci.uint4)
        XCTAssertEqual(value, UInt64(5))
    }

    func testDenominatorFivePowCenti() {
        let value = UInt64.pow(x: .five, y: SIPrefix.centi.uint4)
        XCTAssertEqual(value, UInt64(25))
    }

    func testDenominatorFivePowMilli() {
        let value = UInt64.pow(x: .five, y: SIPrefix.milli.uint4)
        XCTAssertEqual(value, UInt64(125))
    }

    func testDenominatorFivePowMicro() {
        let value = UInt64.pow(x: .five, y: SIPrefix.micro.uint4)
        XCTAssertEqual(value, UInt64(15625))
    }

    func testDenominatorFivePowNano() {
        let value = UInt64.pow(x: .five, y: SIPrefix.nano.uint4)
        XCTAssertEqual(value, UInt64(1953125))
    }

    func testDenominatorFivePowPico() {
        let value = UInt64.pow(x: .five, y: SIPrefix.pico.uint4)
        XCTAssertEqual(value, UInt64(244140625))
    }
    
    func testDenominatorTenPowDeci() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.deci.uint4)
        XCTAssertEqual(value, UInt64(10))
    }

    func testDenominatorTenPowCenti() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.centi.uint4)
        XCTAssertEqual(value, UInt64(100))
    }

    func testDenominatorTenPowMilli() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.milli.uint4)
        XCTAssertEqual(value, UInt64(1000))
    }

    func testDenominatorTenPowMicro() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.micro.uint4)
        XCTAssertEqual(value, UInt64(1000000))
    }

    func testDenominatorTenPowNano() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.nano.uint4)
        XCTAssertEqual(value, UInt64(1000000000))
    }

    func testDenominatorTenPowPico() {
        let value = UInt64.pow(x: .ten, y: SIPrefix.pico.uint4)
        XCTAssertEqual(value, UInt64(1000000000000))
    }
}
