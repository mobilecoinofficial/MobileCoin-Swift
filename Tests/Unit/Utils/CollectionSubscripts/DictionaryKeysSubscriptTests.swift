//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class DictionaryKeysSubscriptTests: XCTestCase {

    func testWorks() {
        let sut = [
            "a": "1",
            "b": "2",
            "c": "3",
        ]
        XCTAssertEqual(sut[[]], [])
        XCTAssertEqual(sut[["b"]], ["2"])
        XCTAssertEqual(sut[["c", "a"]], ["3", "1"])
        XCTAssertNil(sut[["1"]])
        XCTAssertNil(sut[["d", "a"]])
        XCTAssertNil(sut[["b", "a1"]])
    }

    func testEmptyDictionaryWorks() {
        let sut: [String: String] = [:]
        XCTAssertEqual(sut[[]], [])
        XCTAssertNil(sut[["a"]])
    }

}
