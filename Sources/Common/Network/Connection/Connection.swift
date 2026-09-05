//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class Connection<HttpService: ConnectionProtocol> {
    private let inner: SerialDispatchLock<Inner>
    private var transportProtocolOption: TransportProtocol.Option

    private let serviceFactory: (TransportProtocol.Option) -> HttpService

    init(
        serviceFactory: @escaping (TransportProtocol.Option) -> HttpService,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) {
        self.transportProtocolOption = transportProtocolOption
        self.serviceFactory = serviceFactory
        let inner = Inner(service: serviceFactory(transportProtocolOption))
        self.inner = .init(inner, targetQueue: targetQueue)
    }

    func rotateConnection() {
        let service = serviceFactory(self.transportProtocolOption)
        inner.accessAsync { $0.service = service }
    }

    func setTransportProtocolOption(_ transportProtocolOption: TransportProtocol.Option) {
        self.transportProtocolOption = transportProtocolOption
        let service = serviceFactory(transportProtocolOption)
        inner.accessAsync { $0.service = service }
    }

    func setAuthorization(credentials: BasicCredentials) {
        inner.accessAsync { $0.setAuthorization(credentials: credentials) }
    }

    var service: HttpService {
        inner.accessWithoutLocking.service
    }

    func rotateURLOnError<T>(
        _ completion: @escaping (Result<T, ConnectionError>) -> Void
    ) -> (Result<T, ConnectionError>) -> Void {
        { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                logger.debug("rotating config on error")
                completion(result)
                self?.rotateConnection()
            }
        }
    }

}

extension Connection {
    private struct Inner {
        var service: HttpService {
            didSet {
                if let credentials = authorizationCredentials {
                    service.setAuthorization(credentials: credentials)
                }
            }
        }

        private var authorizationCredentials: BasicCredentials?

        init(service: HttpService) {
            self.service = service
        }

        mutating func setAuthorization(credentials: BasicCredentials) {
            self.authorizationCredentials = credentials
            service.setAuthorization(credentials: credentials)
        }
    }
}
