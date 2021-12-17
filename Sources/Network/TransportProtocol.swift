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

protocol SupportedProtocols {
    static var supportedProtocols: [TransportProtocol] { get }
}

extension SupportedProtocols {
    public static var supportedProtocols: [TransportProtocol] { [] }
}

//extension TransportProtocol {
//    public static var grpcProtocolSupported: Bool {
//        Bundle.testBundle?.boolean(forInfoDictionaryKey: .grpcKey) ?? false
//    }
//
//    static var httpProtocolSupported: Bool {
//        Bundle.testBundle?.boolean(forInfoDictionaryKey: .httpKey) ?? true
//    }
//
//    // TODO
//    // Migrate all "config" code that uses .grpc as the "default" TransportProtocol, to instead
//    // not have a static default, or choose from supported options, preferring .grpc if avail.
//    public static var supportedProtocols: [TransportProtocol] {
//        let v = [(TransportProtocol.grpc, TransportProtocol.grpcProtocolSupported),
//         (TransportProtocol.http, TransportProtocol.httpProtocolSupported)]
//            .filter({$0.1})
//            .map({$0.0})
//
//
//        Bundle.allBundles.forEach { bundle in
//            print("\(bundle.bundlePath)")
//            print("\(bundle.infoDictionary?.keys)")
//            if let keys = bundle.infoDictionary?.keys,
//                keys.contains("GRPCNetworkProtocolSupported") {
//                print("found")
//            }
//
//            if let path = bundle.path(forResource: "MobileCoin-Core-Info", ofType: "plist") {
//                print("found")
//            }
//        }
//        print("Supported Protocols == \(v.count)")
//        return v
//    }
//}
//
//// swiftlint:disable no_extension_access_modifier
//fileprivate extension String {
//    static let grpcKey: String = "GRPCNetworkProtocolSupported"
//    static let httpKey: String = "HTTPNetworkProtocolSupported"
//}
//
//struct EmptyConnectionProtocol: ConnectionProtocol {
//    func setAuthorization(credentials: BasicCredentials) {
//        logger.fatalError("Not implemented in this transport protocol")
//    }
//}
//
//extension TransportProtocol {
//}
//
//
//extension Bundle {
//    static var testBundle : Bundle? {
//        Bundle.allBundles.first(where: {$0.bundleURL.path.contains("Tests")})
//    }
//
//    func boolean(forInfoDictionaryKey key: String) -> Bool? {
//        guard let value = self.object(forInfoDictionaryKey: key) as? String
//        else {
//            return nil
//        }
//        return value == "YES"
//    }
//}
