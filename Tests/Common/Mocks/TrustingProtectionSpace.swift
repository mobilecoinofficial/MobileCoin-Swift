//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
import Foundation
import Security

// `URLProtectionSpace` builds its own `serverTrust` from a live TLS handshake,
// so a fixture chain reaches a delegate only through an override.
final class TrustingProtectionSpace: URLProtectionSpace, @unchecked Sendable {
    private let trust: SecTrust

    init(trust: SecTrust, host: String) {
        self.trust = trust
        super.init(
            host: host,
            port: 443,
            protocol: NSURLProtectionSpaceHTTPS,
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("unused") }

    override var serverTrust: SecTrust? { trust }
}
