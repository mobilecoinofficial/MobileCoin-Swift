//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class CollectionIndicesSubscriptTests: XCTestCase {

    func testWorks() {
        let sut = ["a", "b", "c"]
        XCTAssertEqual(sut[[]], [])
        XCTAssertEqual(sut[[2, 0]], ["c", "a"])
        XCTAssertEqual(sut[[1]], ["b"])
    }

    func testEmptyArrayWorks() {
        let sut: [String] = []
        XCTAssertEqual(sut[[]], [])
    }

}
