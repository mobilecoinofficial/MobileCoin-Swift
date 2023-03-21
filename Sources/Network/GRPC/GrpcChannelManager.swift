//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import NIO
import NIOSSL

final class GrpcChannelManager {
    private let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private var addressToChannel: [GrpcChannelConfig: GRPCChannel] = [:]

    func channel(for config: ConnectionConfigProtocol) -> GRPCChannel {
        let wrappedTrustRoots = config.trustRoots[.grpc] as? WrappedNIOSSLCertificate
        return channel(for: config.url, trustRoots: wrappedTrustRoots?.trustRoots)
        // return channel(for: config.url, trustRoots: nil)
    }

    func channel(for url: MobileCoinUrlProtocol, trustRoots: [NIOSSLCertificate]? = nil)
        -> GRPCChannel
    {
        let config = GrpcChannelConfig(url: url, trustRoots: trustRoots)
        guard let channel = addressToChannel[config] else {
            let channel = ClientConnection.create(group: eventLoopGroup, config: config)
            addressToChannel[config] = channel
            return channel
        }
        return channel
    }
}

extension GrpcChannelManager {
    enum Defaults {
        static let callOptionsTimeLimit = TimeLimit.timeout(TimeAmount.seconds(60))
    }
}

extension ClientConnection {
    fileprivate static func create(group: EventLoopGroup, config: GrpcChannelConfig) -> GRPCChannel
    {
        let builder: Builder
        if config.useTls {
            let secureBuilder = ClientConnection.secure(group: group)
            if let trustRoots = config.trustRoots {
                /**
                 /// A custom verification callback that allows completely overriding the certificate verification logic.
                 @discardableResult
                 public func withTLSCustomVerificationCallback(
                   _ callback: @escaping NIOSSLCustomVerificationCallback
                 ) -> Self {
                   self.tls.customVerificationCallback = callback
                   return self
                 }
                 */
//                secureBuilder.withTLSCustomVerificationCallback { certs, eventLoopPromise in
//                    print(certs)
//                }
                 secureBuilder.withTLS(trustRoots: .certificates(trustRoots))
                // secureBuilder.withTLS(certificateVerification: .fullVerification)
            }
            builder = secureBuilder
        } else {
            builder = ClientConnection.insecure(group: group)
        }
        builder.withBackgroundActivityLogger(logger)
        return builder.connect(host: config.host, port: config.port)
    }
}
