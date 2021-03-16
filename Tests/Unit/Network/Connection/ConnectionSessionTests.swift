//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import NIOHPACK
import XCTest

class ConnectionSessionTests: XCTestCase {

    func testAuth() throws {
        let fixture = try ConnectionSession.Fixtures.Default()
        let session = fixture.session

        session.authorizationCredentials = fixture.credentials

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, fixture.headersWithAuth)
    }

    func testSetCookie() throws {
        let fixture = try ConnectionSession.Fixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, fixture.headersWithCookie1)
    }

    func testSetCookieOverridesExistingCookie() throws {
        let fixture = try ConnectionSession.Fixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)
        session.processResponse(headers: fixture.responseHeadersWithSetCookie2)

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, fixture.headersWithCookie2)
    }

    func testHttp1SetCookie() throws {
        let fixture = try ConnectionSession.Fixtures.Default()
        let session = fixture.session

        session.processResponse(headers: fixture.http1ResponseHeadersWithSetCookie1)

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, fixture.headersWithCookie1)
    }

    func testSetCookieInsecure() throws {
        let fixture = try ConnectionSession.Fixtures.Insecure()
        let session = fixture.session

        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, [:])
    }

    func testAuthAndCookie() throws {
        let fixture = try ConnectionSession.Fixtures.Default()
        let session = fixture.session

        session.authorizationCredentials = fixture.credentials
        session.processResponse(headers: fixture.responseHeadersWithSetCookie1)

        var hpackHeaders = HPACKHeaders()
        session.addRequestHeaders(to: &hpackHeaders)
        XCTAssertEqual(hpackHeaders, fixture.headersWithAuthAndCookie1)
    }

}
