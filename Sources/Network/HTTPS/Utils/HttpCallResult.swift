//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation


public struct HttpCallResult<ResponsePayload> {
    let status: HTTPStatus
    let allHeaderFields: [AnyHashable: Any]?
    let response: ResponsePayload?
}

extension HttpCallResult {
    init(
        status: HTTPStatus
    ) {
        self.init(status: status, allHeaderFields: nil, response: nil)
    }
}

