//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class MobUriPublicApiTests: XCTestCase {

    let validUris = [
        "mob:///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "mob://mobilecoin.com/b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "mob://mobilecoin.com:1234/b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
    ]

    let invalidUris = [
        "mob:///bad/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "meow:///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "mob://b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "mob://b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)1/payload2",
        "mob:///b58/payload",
        "mob:///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded.dropLast())",
        "mob:///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)0",
        "mob: ///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "mob::///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
        "///b58/\(Base58Coder.Fixtures.DefaultUsingPublicAddress.encoded)",
    ]

    func testDecodingValidUrisWorks() {
        for uri in validUris {
            XCTAssertSuccess(MobUri.decode(uri: uri), "Decoding failed: \(uri)")
        }
    }

    func testDecodingInvalidUrisThrows() {
        for uri in invalidUris {
            XCTAssertFailure(MobUri.decode(uri: uri), "Decoding expected to fail: \(uri)")
        }
    }

    func testEncodingPublicAddress() throws {
        let fixture = try MobUri.Fixtures.Default()
        XCTAssertEqual(MobUri.encode(fixture.publicAddress), fixture.uri)
    }

}
