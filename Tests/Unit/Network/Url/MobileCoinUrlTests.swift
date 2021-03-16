//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class MobileCoinUrlTests: XCTestCase {

    func testInit() throws {
        XCTAssertSuccess(MobileCoinUrl<ConsensusScheme>.make(string: "mc://example.com"))
        XCTAssertSuccess(MobileCoinUrl<FogScheme>.make(string: "fog://example.com"))
    }

    func testAcceptsInsecureScheme() throws {
        XCTAssertSuccess(MobileCoinUrl<ConsensusScheme>.make(string: "insecure-mc://example.com"))
        XCTAssertSuccess(MobileCoinUrl<FogScheme>.make(string: "insecure-fog://example.com"))
    }

    func testNoSchemeFails() {
        XCTAssertFailure(MobileCoinUrl<ConsensusScheme>.make(string: "example.com"))
        XCTAssertFailure(MobileCoinUrl<FogScheme>.make(string: "example.com"))
    }

    func testWrongSchemeFails() {
        XCTAssertFailure(MobileCoinUrl<ConsensusScheme>.make(string: "fog://example.com"))
        XCTAssertFailure(MobileCoinUrl<FogScheme>.make(string: "mc://example.com"))
    }

    func testHttpSchemeFails() {
        XCTAssertFailure(MobileCoinUrl<ConsensusScheme>.make(string: "http://example.com"))
        XCTAssertFailure(MobileCoinUrl<FogScheme>.make(string: "http://example.com"))

        XCTAssertFailure(MobileCoinUrl<ConsensusScheme>.make(string: "https://example.com"))
        XCTAssertFailure(MobileCoinUrl<FogScheme>.make(string: "https://example.com"))
    }

    func testNoHostFails() {
        XCTAssertFailure(MobileCoinUrl<ConsensusScheme>.make(string: "mc://"))
        XCTAssertFailure(MobileCoinUrl<FogScheme>.make(string: "fog://"))
    }

    func testAcceptsCustomPort() throws {
        XCTAssertSuccess(MobileCoinUrl<ConsensusScheme>.make(string: "mc://example.com:1736"))
        XCTAssertSuccess(MobileCoinUrl<FogScheme>.make(string: "fog://example.com:1736"))
    }

}
