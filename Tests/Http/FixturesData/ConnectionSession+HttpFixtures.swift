//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

extension ConnectionSession {
    enum HttpFixtures {}
}

extension ConnectionSession.HttpFixtures {
    struct Default {
        let session: ConnectionSession

        let credentials = Self.credentials
        let headersWithAuth = Self.headersWithAuthorization

        let responseHeadersWithSetCookie1 = Self.responseHeadersWithSetCookie(cookie: Self.cookie1)
        let responseHeadersWithSetCookie2 = Self.responseHeadersWithSetCookie(cookie: Self.cookie2)
        let http1ResponseHeadersWithSetCookie1 =
            Self.http1ResponseHeadersWithSetCookie(cookie: Self.cookie1)
        let http1ResponseHeadersWithSetCookie2 =
            Self.http1ResponseHeadersWithSetCookie(cookie: Self.cookie2)

        let headersWithCookie1 = Self.headersWithCookie(cookie: Self.cookie1) as! [String: String]
        let headersWithCookie2 = Self.headersWithCookie(cookie: Self.cookie2) as! [String: String]
        let headersWithAuthAndCookie1 = Self.headersWithAuthorizationAndCookie(cookie: Self.cookie1)

        init() throws {
            let url = try Self.url()
            self.session = ConnectionSession(url: url)
        }
    }
}

extension ConnectionSession.HttpFixtures {
    struct DefaultWithCookie {
        let session: ConnectionSession

        init() throws {
            let defaultFixture = try Default()
            let session = defaultFixture.session
            session.processResponse(headers: defaultFixture.responseHeadersWithSetCookie1)

            let headers = session.requestHeaders
            XCTAssertEqual(headers, defaultFixture.headersWithCookie1)

            self.session = session
        }
    }
}

extension ConnectionSession.HttpFixtures {
    struct Insecure {
        let session: ConnectionSession

        let responseHeadersWithSetCookie1 = Default.responseHeadersWithSetCookie(
            cookie: Default.cookie1)

        init() throws {
            let url = try Self.url()
            self.session = ConnectionSession(url: url)
        }
    }
}

extension ConnectionSession.HttpFixtures.Default {

    fileprivate static func url() throws -> MobileCoinUrlProtocol {
        try ConsensusUrl.make(string: "mc://node1.fake.mobilecoin.com").get()
    }

    fileprivate static let credentials = BasicCredentials(username: "user1", password: "password1")

    fileprivate static let cookie1 = "INGRESSCOOKIE=35b2f12510e6a173ad22758a8880619b"
    fileprivate static let cookie2 = "INGRESSCOOKIE=788eaf4b8baca6ba6957d541da88199d"

    fileprivate static var headersWithAuthorization: [String: String] {
        ["authorization": "Basic dXNlcjE6cGFzc3dvcmQx"]
    }

    fileprivate static func http1ResponseHeadersWithSetCookie(cookie: String) -> [String: String] {
        ["Set-Cookie": "\(cookie); Max-Age=3600; Path=/; Secure; HttpOnly"]
    }

    fileprivate static func responseHeadersWithSetCookie(cookie: String) -> [String: String] {
        ["set-cookie": "\(cookie); Max-Age=3600; Path=/; Secure; HttpOnly"]
    }

    fileprivate static func headersWithCookie(cookie: String) -> [String: String] {
        ["cookie": cookie]
    }

    fileprivate static func headersWithAuthorizationAndCookie(cookie: String) -> [String: String] {
        [
            "authorization": "Basic dXNlcjE6cGFzc3dvcmQx",
            "cookie": cookie,
        ]
    }

}

extension ConnectionSession.HttpFixtures.Insecure {

    fileprivate static func url() throws -> MobileCoinUrlProtocol {
        try ConsensusUrl.make(string: "insecure-mc://node1.fake.mobilecoin.com").get()
    }

}
