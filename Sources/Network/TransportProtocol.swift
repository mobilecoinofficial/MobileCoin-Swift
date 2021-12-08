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
    
    var fogViewFactory :  ConnectionWrapperFactory = { option in
        ConnectionOptionWrapper.http(httpService: )
    }
}

extension TransportProtocol {
    enum Option {
        case grpc
        case http
    }
    var certificateValidator: NIOSSLCertificateValidator {
        switch self.option {
        case .grpc:
            return WrappedNIOSSLCertificateValidator()
        case .http:
            return EmptyNIOSSLCertificateValidator()
        }
    }
}

struct EmptyConnectionProtocol : ConnectionProtocol {
    func setAuthorization(credentials: BasicCredentials) {
        logger.fatalError("Not implemented in this transport protocol")
    }
}

extension TransportProtocol {
}
