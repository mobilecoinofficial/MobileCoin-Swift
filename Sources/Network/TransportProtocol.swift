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
    public static var grpcProtocolSupported: Bool {
        Bundle.testBundle?.boolean(forInfoDictionaryKey: .grpcKey) ?? false
    }
    
    static var httpProtocolSupported: Bool {
        Bundle.testBundle?.boolean(forInfoDictionaryKey: .httpKey) ?? false
    }
    
    public static var supportedProtocols: [TransportProtocol] {
        [(TransportProtocol.grpc, TransportProtocol.grpcProtocolSupported),
         (TransportProtocol.http, TransportProtocol.httpProtocolSupported)]
            .filter({$0.1})
            .map({$0.0})
    }
}

// swiftlint:disable no_extension_access_modifier
fileprivate extension String {
    static let grpcKey: String = "GRPCNetworkProtocolSupported"
    static let httpKey: String = "HTTPNetworkProtocolSupported"
}

struct EmptyConnectionProtocol: ConnectionProtocol {
    func setAuthorization(credentials: BasicCredentials) {
        logger.fatalError("Not implemented in this transport protocol")
    }
}

extension TransportProtocol {
}


extension Bundle {
    static var testBundle : Bundle? {
        Bundle.allBundles.first(where: {$0.bundleURL.path.contains("Tests")})
    }
    
    func boolean(forInfoDictionaryKey key: String) -> Bool? {
        guard let value = self.object(forInfoDictionaryKey: key) as? String
        else {
            return nil
        }
        return value == "YES"
    }
}
