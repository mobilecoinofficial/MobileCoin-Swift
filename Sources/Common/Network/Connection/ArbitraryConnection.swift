//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class ArbitraryConnection<HttpService> {
    private let inner: SerialDispatchLock<Inner>

    private let serviceFactory: (TransportProtocol.Option) -> HttpService

    init(
        serviceFactory: @escaping (TransportProtocol.Option) -> HttpService,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) {
        self.serviceFactory = serviceFactory
        let inner = Inner(service: serviceFactory(transportProtocolOption))
        self.inner = .init(inner, targetQueue: targetQueue)
    }

    func setTransportProtocolOption(_ transportProtocolOption: TransportProtocol.Option) {
        let service = serviceFactory(transportProtocolOption)
        inner.accessAsync { $0.service = service }
    }

    var service: HttpService {
        inner.accessWithoutLocking.service
    }
}

extension ArbitraryConnection {
    private struct Inner {
        var service: HttpService

        init(service: HttpService) {
            self.service = service
        }
    }
}
