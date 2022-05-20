//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

@testable import MobileCoin

extension TransportProtocol {
    static var grpcTimeout: Double = {
        Double(GrpcChannelManager.Defaults.callOptionsTimeLimit.timeout!.nanoseconds) / 1.0e9
    }()

    var timeoutInSeconds: Double {
        // pad timeout of test by 2 seconds over the protocol timeout
        let padTime = 2.0

        switch self.option {
        case .grpc:
            return padTime + Self.grpcTimeout
        }
    }
}
