//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TransportProtocol {
    public static let grpc = TransportProtocol(option: .grpc)
    public static let http = TransportProtocol(option: .http)

    let option: Option
}

extension TransportProtocol {
    enum Option {
        case grpc
        case http
    }
}
