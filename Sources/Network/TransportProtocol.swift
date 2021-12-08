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

extension TransportProtocol {
    static var grpcProtocolSupported : Bool {
        Bundle.main.object(forInfoDictionaryKey: .grpcKey) as? Bool ?? false
    }
    
    static var httpProtocolSupported : Bool {
        Bundle.main.object(forInfoDictionaryKey: .httpKey) as? Bool ?? false
    }
    
    static var supportedProtocols : [TransportProtocol] {
        [(TransportProtocol.grpc, TransportProtocol.grpcProtocolSupported),
         (TransportProtocol.http, TransportProtocol.httpProtocolSupported)]
            .filter({$0.1})
            .map({$0.0})
    }
}

// swiftlint:disable no_extension_access_modifier
fileprivate extension String {
    static let grpcKey : String = "GRPC Network Protocol Supported"
    static let httpKey : String = "HTTP Network Protocol Supported"
}

struct EmptyConnectionProtocol : ConnectionProtocol {
    func setAuthorization(credentials: BasicCredentials) {
        logger.fatalError("Not implemented in this transport protocol")
    }
}

extension TransportProtocol {
}
