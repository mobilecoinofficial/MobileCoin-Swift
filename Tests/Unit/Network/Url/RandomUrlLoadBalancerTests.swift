//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class RandomUrlLoadBalancerTests: XCTestCase {

    func testSingleUrlReturnsThatUrl() {
        let urlString = "mc://example.com"

        _ = ConsensusUrl.make(string: urlString).flatMap { consensusUrl in
            RandomUrlLoadBalancer.make(urls: [consensusUrl]).flatMap { loadBalancer in
                XCTAssertEqual(loadBalancer.nextUrl(), consensusUrl)
            }
        }
    }

    func testMultipleUrlsReturnsDifferentUrlOnSecondCall() {
        let urlA = "mc://example1.com"
        let urlB = "mc://example2.com"

        _ = ConsensusUrl.make(strings: [urlA, urlB]).flatMap { consensusUrls in
            RandomUrlLoadBalancer.make(urls: consensusUrls).flatMap { loadBalancer in
                let nextA = loadBalancer.nextUrl()
                let nextB = loadBalancer.nextUrl()
                XCTAssertNotEqual(nextA, nextB)
            }
        }
    }

}
