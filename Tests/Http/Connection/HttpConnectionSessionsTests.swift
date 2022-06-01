//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class HttpConnectionSessionsTests: XCTestCase {

    func testAuth() throws {
        XCTAssertTrue(true)
        let fixture = try ConnectionSession.HttpFixtures.Default()
        let session = fixture.session

        session.authorizationCredentials = fixture.credentials

        assertDictionariesEqualCaseInsensitively(session.requestHeaders, fixture.headersWithAuth)
    }

    func testSetCookie() throws {
        let fixture = try ConnectionSession.HttpFixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        assertDictionariesEqualCaseInsensitively(session.requestHeaders, fixture.headersWithCookie1)
    }

    func testSetCookieOverridesExistingCookie() throws {
        let fixture = try ConnectionSession.HttpFixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)
        session.processResponse(headers: fixture.responseHeadersWithSetCookie2)

        assertDictionariesEqualCaseInsensitively(session.requestHeaders, fixture.headersWithCookie2)
    }

    func testHttp1SetCookie() throws {
        let fixture = try ConnectionSession.HttpFixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.http1ResponseHeadersWithSetCookie1)

        assertDictionariesEqualCaseInsensitively(session.requestHeaders, fixture.headersWithCookie1)
    }

    func testSetCookieInsecure() throws {
        let fixture = try ConnectionSession.HttpFixtures.Insecure()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        assertDictionariesEqualCaseInsensitively(session.requestHeaders, [:])
    }

    func testAuthAndCookie() throws {
        let fixture = try ConnectionSession.HttpFixtures.Default()
        let session = fixture.session

        session.authorizationCredentials = fixture.credentials
        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        assertDictionariesEqualCaseInsensitively(
                session.requestHeaders,
                fixture.headersWithAuthAndCookie1)
    }

    func assertDictionariesEqualCaseInsensitively(_ a: [String: String], _ b: [String: String]) {
        let a_pairs = Set(a.map { key, value in
            CaseInsensitiveKeyValue(key: key, value: value)
        })
        let b_pairs = Set(b.map { key, value in
            CaseInsensitiveKeyValue(key: key, value: value)
        })
        XCTAssertTrue(a_pairs == b_pairs)
    }
}

struct CaseInsensitiveKeyValue {
    let key: String
    let value: String

    init(key: String, value: String) {
        self.key = key.lowercased()
        self.value = value
    }
}

extension CaseInsensitiveKeyValue: Equatable, Hashable { }
