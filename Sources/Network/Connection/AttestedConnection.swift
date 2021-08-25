//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

//class AttestedConnection<Service> {
//    private let inner: SerialDispatchLock<Inner>
//
//    init(connectionOptionWrapper: ConnectionOptionWrapper<Service>, targetQueue: DispatchQueue?) {
//        let inner = Inner(connectionOptionWrapper: connectionOptionWrapper)
//        self.inner = .init(inner, targetQueue: targetQueue)
//    }
//
//    func setConnectionOptionWrapper(_ connectionOptionWrapper: ConnectionOptionWrapper<Service>) {
//        inner.accessAsync { $0.connectionOptionWrapper = connectionOptionWrapper }
//    }
//
//    func setAuthorization(credentials: BasicCredentials) {
//        inner.accessAsync { $0.setAuthorization(credentials: credentials) }
//    }
//}
//
//extension AttestedConnection {
//    private struct Inner {
//        var connectionOptionWrapper: ConnectionOptionWrapper<ServiceType> {
//            didSet {
//                if let credentials = authorizationCredentials {
//                    switch connectionOptionWrapper {
//                    case .grpc(grpcService: let grpcService):
//                        grpcService.setAuthorization(credentials: credentials)
//                    case .http(httpService: let httpService):
//                        httpService.setAuthorization(credentials: credentials)
//                    }
//                }
//            }
//        }
//        private var authorizationCredentials: BasicCredentials?
//
//        init(connectionOptionWrapper: ConnectionOptionWrapper<ServiceType>) {
//            self.connectionOptionWrapper = connectionOptionWrapper
//        }
//
//        mutating func setAuthorization(credentials: BasicCredentials) {
//            self.authorizationCredentials = credentials
//            switch connectionOptionWrapper {
//            case .grpc(grpcService: let grpcService):
//                grpcService.setAuthorization(credentials: credentials)
//            case .http(httpService: let httpService):
//                httpService.setAuthorization(credentials: credentials)
//            }
//        }
//    }
//}
