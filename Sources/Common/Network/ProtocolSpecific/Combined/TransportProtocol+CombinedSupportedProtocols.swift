//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// Either module means the grpc transport is compiled in.
#if canImport(LibMobileCoinGRPC) || canImport(GRPC)
extension TransportProtocol: SupportedProtocols {
    public static var supportedProtocols: [TransportProtocol] {
        [.grpc, .http]
    }
}
#else
extension TransportProtocol: SupportedProtocols {
    public static var supportedProtocols: [TransportProtocol] {
        [.http]
    }
}
#endif
