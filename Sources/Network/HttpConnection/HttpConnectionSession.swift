//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation


final class HttpConnectionSession {
    private static var ephemeralCookieStorage: HTTPCookieStorage {
        guard let cookieStorage = URLSessionConfiguration.ephemeral.httpCookieStorage else {
            // Safety: URLSessionConfiguration.ephemeral.httpCookieStorage will always return
            // non-nil.
            logger.fatalError("URLSessionConfiguration.ephemeral.httpCookieStorage returned nil.")
        }
        return cookieStorage
    }

    private let url: URL
    private let cookieStorage: HTTPCookieStorage
    var authorizationCredentials: BasicCredentials?

    private var cookieHeaders : [String:String] {
        guard let cookies = cookieStorage.cookies(for: url) else { return [:] }
        return HTTPCookie.requestHeaderFields(with: cookies)
    }

    private var authorizationHeades : [String: String] {
        guard let credentials = authorizationCredentials else { return [:] }
        return ["Authorization" : credentials.authorizationHeaderValue]
    }
    var requestHeaders: [String : String] {
        var headers : [String: String] = [:]
        headers.merge(cookieHeaders) {  (_, new) in new }
        headers.merge(authorizationHeades) {  (_, new) in new }
        return headers
    }
    
    convenience init(config: ConnectionConfigProtocol) {
        self.init(url: config.url, authorization: config.authorization)
    }

    init(url: MobileCoinUrlProtocol, authorization: BasicCredentials? = nil) {
        self.url = url.httpBasedUrl
        self.cookieStorage = Self.ephemeralCookieStorage
        self.authorizationCredentials = authorization
    }

    func processResponse(headers: [AnyHashable : Any]) {
        processCookieHeader(headers: headers)
    }
    
    private func processCookieHeader(headers: [AnyHashable: Any]) {
        let http1Headers = Dictionary(
            headers.compactMap({ (key: AnyHashable, value: Any) -> (name: String, value: String)? in
                guard let name = key as? String else { return nil }
                guard let value = value as? String else { return nil }
                return (name:name, value:value)
            }).map { ($0.name.capitalized, $0.value) },
            uniquingKeysWith: { k, _ in k })

        let receivedCookies = HTTPCookie.cookies(
            withResponseHeaderFields: http1Headers,
            for: url)
        receivedCookies.forEach(cookieStorage.setCookie)
    }
}
