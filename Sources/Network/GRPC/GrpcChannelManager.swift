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
        static let callOptionsTimeLimit = TimeLimit.timeout(TimeAmount.seconds(30))
    }
}

extension ClientConnection {

    fileprivate static func create(group: EventLoopGroup, config: GrpcChannelConfig) -> GRPCChannel
    {
        let builder: Builder
        if config.useTls {
            let secureBuilder = ClientConnection.secure(group: group)
            if let trustRoots = config.trustRoots {
                // This is our "shared" cert-pinning implementation for both HTTP and GRPC
                // GRPC's built in verification was failing for unknown reasons. That call was:
                // secureBuilder.withTLS(trustRoots: .certificates(trustRoots))

                // swiftlint:disable line_length
                secureBuilder.withTLSCustomVerificationCallback { serverCerts, eventLoopPromise -> Void in
                    let serverTrust: SecTrust
                    do {
                        serverTrust = try serverCerts.asServerSecTrust().get()
                    } catch {
                        logger.error(error.localizedDescription)
                        eventLoopPromise.succeed(.failed)
                        return
                    }

                    serverTrust.validateAgainst(pinnedKeys: trustRoots.asKeys) { result in
                        switch result {
                        case .success(let message):
                            logger.debug(message)
                            eventLoopPromise.succeed(.certificateVerified)
                        case .failure(let error):
                            logger.error(error.localizedDescription)
                            eventLoopPromise.succeed(.failed)
                        }
                    }
                }
                // swiftlint:enable line_length
            }
            builder = secureBuilder
        } else {
            builder = ClientConnection.insecure(group: group)
        }
        return builder.connect(host: config.host, port: config.port)
    }
}

extension Collection where Element == NIOSSLCertificate {
    var asDerData: [Data] {
        self.compactMap { certificate -> Data? in
            guard let derBytes = try? certificate.toDERBytes()
            else {
                logger.error("Could not extract DER bytes from an NIOSSLCerticate")
                return nil
            }
            return Data(derBytes)
        }
    }

    func asServerSecTrust() -> Result<SecTrust, SSLTrustError> {
        let secCertificates = self.asDerData.compactMap { certDerData in
            SecCertificateCreateWithData(nil, certDerData as CFData)
        }
        guard secCertificates.count == self.count
        else {
            let missingCerts = secCertificates.count - self.count
            return .failure(
                SSLTrustError("Could not create \(missingCerts) SecCertificates")
            )
        }

        var secTrust: SecTrust?
        guard
            SecTrustCreateWithCertificates(
                secCertificates as AnyObject,
                SecPolicyCreateBasicX509(),
                &secTrust
            ) == errSecSuccess,
            let serverTrust = secTrust
        else {
            return .failure(
                SSLTrustError("Cannot create SecTrust from Server Certificates")
            )
        }

        return .success(serverTrust)
    }

    var asKeys: [SecKey] {
        guard
            let keys = try? Data.pinnedCertificateKeys(for: self.asDerData).get()
        else {
            logger.error("Could not recreate SecKey's from pinned NIOSSL certs")
            return []
        }
        return keys
    }
}
