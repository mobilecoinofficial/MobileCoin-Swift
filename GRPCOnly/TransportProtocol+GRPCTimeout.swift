//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
import Foundation

extension TransportProtocol {
    static var grpcTimeout: Double = {
        guard let timeout = GrpcChannelManager.Defaults.callOptionsTimeLimit.timeout else {
            logger.error("No GrpcTimeout value !")
            return Double(0)
        }
        return Double(timeout.nanoseconds) / 1.0e9
    }()

    static var httpTimeout: Double = {
        0
    }()

    var timeoutInSeconds: Double {
        // pad timeout of test by 2 seconds over the protocol timeout
        let padTime = 2.0

        switch self.option {
        case .grpc:
            return padTime + Self.grpcTimeout
        case .http:
            return padTime + Self.httpTimeout
        }
    }
}
