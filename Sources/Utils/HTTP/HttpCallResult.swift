//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import NIO
import NIOHPACK


public struct HttpCallResult<ResponsePayload> {
    let status: HTTPStatus
    let metadata: HTTPURLResponse?
    let response: ResponsePayload?
}

extension HttpCallResult {
    init(
        status: HTTPStatus
    ) {
        self.init(status: status, metadata: nil, response: nil)
    }
}

