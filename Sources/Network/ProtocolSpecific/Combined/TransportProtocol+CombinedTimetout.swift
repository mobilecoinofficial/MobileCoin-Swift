//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
import Foundation

extension TransportProtocol {
    static var grpcTimeout: Double = {
        Double(GrpcChannelManager.Defaults.callOptionsTimeLimit.timeout!.nanoseconds) / 1.0e9
    }()

    static var httpTimeout: Double = {
        DefaultHttpRequester.defaultConfiguration.timeoutIntervalForRequest
    }()

    var timeoutInSeconds: Double {
        switch self.option {
        case .grpc:
            return Self.grpcTimeout
        case .http:
            return Self.httpTimeout
        }
    }
}
