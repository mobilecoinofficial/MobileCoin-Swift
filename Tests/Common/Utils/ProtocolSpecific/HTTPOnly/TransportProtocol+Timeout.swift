//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

@testable import MobileCoin

extension TransportProtocol {
    static var httpTimeout: Double = {
        DefaultHttpRequester.defaultConfiguration.timeoutIntervalForRequest
    }()

    var timeoutInSeconds: Double {
        // pad timeout of test by 2 seconds over the protocol timeout
        let padTime = 2.0

        switch self.option {
        case .grpc:
            return 0
        case .http:
            return padTime + Self.httpTimeout
        }
    }
}
