//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

typealias ConnectionWrapperFactory = (TransportProtocol.Option)
                                    -> ConnectionOptionWrapper<ConnectionProtocol, ConnectionProtocol>

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

extension TransportProtocol : Equatable { }

extension TransportProtocol {
    var certificateValidator: NIOSSLCertificateValidator {
        switch self.option {
        case .grpc:
            return WrappedNIOSSLCertificateValidator()
        case .http:
            return EmptyNIOSSLCertificateValidator()
        }
    }
}

protocol SupportedProtocols {
    static var supportedProtocols: [TransportProtocol] { get }
}

extension SupportedProtocols {
    public static var supportedProtocols: [TransportProtocol] { [] }
}
