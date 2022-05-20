//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
@testable import MobileCoin

protocol MockUrlLoadBalancer {
    var didRotate: Bool { get }
}

class SequentialUrlLoadBalancer<ServiceUrl: MobileCoinUrlProtocol>: UrlLoadBalancer<ServiceUrl>,
                                                                    MockUrlLoadBalancer {
    var numRotations = 0
    var didRotate: Bool { numRotations > 0 }

    private(set) var curIdx = 0
    var rotationEnabled = true

    override func nextUrl() -> ServiceUrl {
        if rotationEnabled {
            numRotations += 1
            curIdx = (curIdx + 1) % urlsTyped.count
        }
        return urlsTyped[curIdx]
    }

    required internal init(urls: [ServiceUrl]) {
        super.init(urls: urls)
    }
}
