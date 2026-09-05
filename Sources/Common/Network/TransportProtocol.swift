//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TransportProtocol: Sendable {
    public static let http = TransportProtocol(option: .http)

    let option: Option
}

extension TransportProtocol {
    enum Option {
        case http
    }
}

extension TransportProtocol: CustomStringConvertible {
    public var description: String {
        switch option {
        case .http:
            return "HTTP"
        }
    }
}

extension TransportProtocol: Equatable { }
extension TransportProtocol: Hashable { }

extension TransportProtocol {
    var certificateValidator: SSLCertificateValidator {
        SecSSLCertificateValidator()
    }

    var timeoutInSeconds: Double {
        DefaultHttpRequester.defaultConfiguration.timeoutIntervalForRequest
    }
}

protocol SupportedProtocols {
    static var supportedProtocols: [TransportProtocol] { get }
}

extension TransportProtocol: SupportedProtocols {
    public static var supportedProtocols: [TransportProtocol] { [.http] }
}
