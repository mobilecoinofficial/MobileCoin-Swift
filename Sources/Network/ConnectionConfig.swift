//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import NIOSSL

protocol ConnectionConfigProtocol {
    var url: MobileCoinUrlProtocol { get }
    var transportProtocolOption: TransportProtocol.Option { get }
    var trustRoots: [NIOSSLCertificate]? { get }
    var authorization: BasicCredentials? { get }
}

struct ConnectionConfig<Url: MobileCoinUrlProtocol>: ConnectionConfigProtocol {
    let urlTyped: Url
    let transportProtocolOption: TransportProtocol.Option
    let trustRoots: [NIOSSLCertificate]?
    let authorization: BasicCredentials?

    init(
        url: Url,
        transportProtocolOption: TransportProtocol.Option,
        trustRoots: [NIOSSLCertificate]?,
        authorization: BasicCredentials?
    ) {
        self.urlTyped = url
        self.transportProtocolOption = transportProtocolOption
        self.trustRoots = trustRoots
        self.authorization = authorization
    }

    var url: MobileCoinUrlProtocol { urlTyped }
}
