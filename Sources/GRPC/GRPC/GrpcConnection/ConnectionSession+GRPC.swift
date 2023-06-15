//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
//  swiftlint:disable all

import Foundation
import GRPC
import NIOHPACK
import NIOHTTP1
import NIOSSL

extension ConnectionSession {
    func addRequestHeaders(to hpackHeaders: inout HPACKHeaders) {
        addAuthorizationHeader(to: &hpackHeaders)
        addCookieHeader(to: &hpackHeaders)
    }

    func processResponse(headers: HPACKHeaders) {
        processCookieHeader(headers: headers)
    }
}

extension ConnectionSession {
    func addAuthorizationHeader(to hpackHeaders: inout HPACKHeaders) {
        if let credentials = authorizationCredentials {
            hpackHeaders.add(httpHeaders: ["Authorization": credentials.authorizationHeaderValue])
        }
    }
    
}

// GRPC
extension ConnectionSession {
    func processCookieHeader(headers: HPACKHeaders) {
        let http1Headers = Dictionary(
            headers.map { ($0.name.capitalized, $0.value) },
            uniquingKeysWith: { k, _ in k })

        let receivedCookies = HTTPCookie.cookies(
            withResponseHeaderFields: http1Headers,
            for: url)
        receivedCookies.forEach(cookieStorage.setCookie)
    }
    
    func addCookieHeader(to hpackHeaders: inout HPACKHeaders) {
        if let cookies = cookieStorage.cookies(for: url) {
            hpackHeaders.add(httpHeaders: HTTPCookie.requestHeaderFields(with: cookies))
        }
    }
}

extension HPACKHeaders {
    mutating func add(httpHeaders: [String: String]) {
        add(httpHeaders: HTTPHeaders(Array(httpHeaders)))
    }

    mutating func add(httpHeaders: HTTPHeaders) {
        add(contentsOf: HPACKHeaders(httpHeaders: httpHeaders))
    }
}

