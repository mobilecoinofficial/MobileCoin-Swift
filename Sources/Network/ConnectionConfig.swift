//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol ConnectionConfigProtocol {
    var currentUrl: MobileCoinUrlProtocol? { get }
    var transportProtocolOption: TransportProtocol.Option { get }
    var trustRoots: [TransportProtocol:SSLCertificates] { get }
    var authorization: BasicCredentials? { get }
}

struct ConnectionConfig<Url: MobileCoinUrlProtocol>: ConnectionConfigProtocol {
    let urlLoadBalancer: RandomUrlLoadBalancer<Url>
    let transportProtocolOption: TransportProtocol.Option
    let trustRoots: [TransportProtocol:SSLCertificates]
    let authorization: BasicCredentials?

    init(
        urlLoadBalancer: RandomUrlLoadBalancer<Url>,
        transportProtocolOption: TransportProtocol.Option,
        trustRoots: [TransportProtocol:SSLCertificates],
        authorization: BasicCredentials?
    ) {
        self.urlLoadBalancer = urlLoadBalancer
        self.transportProtocolOption = transportProtocolOption
        self.trustRoots = trustRoots
        self.authorization = authorization
    }

    var currentUrl: MobileCoinUrlProtocol? { self.urlLoadBalancer.currentUrl }
    func nextUrl() { _ = self.urlLoadBalancer.nextUrl() }
}
