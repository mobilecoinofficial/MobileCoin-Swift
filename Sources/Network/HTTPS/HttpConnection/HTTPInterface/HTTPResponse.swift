//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct HTTPResponse {
    public let httpUrlResponse: HTTPURLResponse
    public let responseData: Data?

    public init(httpUrlResponse: HTTPURLResponse, responseData: Data?) {
        self.httpUrlResponse = httpUrlResponse
        self.responseData = responseData
    }
    
    public var statusCode: Int {
        httpUrlResponse.statusCode
    }

    public var allHeaderFields: [AnyHashable: Any] {
        httpUrlResponse.allHeaderFields
    }
}
