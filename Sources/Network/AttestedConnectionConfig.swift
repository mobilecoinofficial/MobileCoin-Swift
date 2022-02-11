//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol AttestedConnectionConfigProtocol: ConnectionConfigProtocol {
    var attestation: Attestation { get }
}

struct AttestedConnectionConfig<Url: MobileCoinUrlProtocol>: AttestedConnectionConfigProtocol {
    let urlLoadBalancer: RandomUrlLoadBalancer<Url>
    let transportProtocolOption: TransportProtocol.Option
    let attestation: Attestation
    let trustRoots: [TransportProtocol: SSLCertificates]
    let authorization: BasicCredentials?

    init(
        urlLoadBalancer: RandomUrlLoadBalancer<Url>,
        transportProtocolOption: TransportProtocol.Option,
        attestation: Attestation,
        trustRoots: [TransportProtocol: SSLCertificates],
        authorization: BasicCredentials?
    ) {
        self.urlLoadBalancer = urlLoadBalancer
        self.transportProtocolOption = transportProtocolOption
        self.attestation = attestation
        self.trustRoots = trustRoots
        self.authorization = authorization
    }

    var currentUrl: MobileCoinUrlProtocol? { self.urlLoadBalancer.currentUrl }
    func nextUrl() { _ = self.urlLoadBalancer.nextUrl() }}
