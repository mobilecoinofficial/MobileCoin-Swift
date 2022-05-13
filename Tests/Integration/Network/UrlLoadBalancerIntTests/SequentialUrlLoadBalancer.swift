//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
@testable import MobileCoin

class SequentialUrlLoadBalancer<ServiceUrl: MobileCoinUrlProtocol>: UrlLoadBalancer<ServiceUrl> {
    private(set) var curIdx = 0
    var rotationEnabled = true

    override func nextUrl() -> ServiceUrl {
        if rotationEnabled {
            curIdx = (curIdx + 1) % urlsTyped.count
        }
        return urlsTyped[curIdx]
    }

    required internal init(urls: [ServiceUrl]) {
        super.init(urls: urls)
    }
}
