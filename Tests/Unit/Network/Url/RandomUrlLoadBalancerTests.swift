//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class RandomUrlLoadBalancerTests: XCTestCase {

    func testSingleUrlReturnsThatUrl() {
        let urlString = "http://www.mobilecoin.com"

        _ = ConsensusUrl.make(string: urlString).flatMap { consensusUrl in
            let loadBalancer = try? RandomUrlLoadBalancer(urls: [consensusUrl])
            XCTAssertEqual(loadBalancer?.nextUrl(), consensusUrl)
        }
    }

    func testMultipleUrlsReturnsDifferentUrlOnSecondCall() {
        let urlA = "http://www.mobilecoin.com/A"
        let urlB = "http://www.mobilecoin.com/B"

        _ = ConsensusUrl.make(strings: [urlA, urlB]).flatMap { consensusUrls in
            let loadBalancer = try? RandomUrlLoadBalancer(urls:consensusUrls)
            let nextA = loadBalancer?.nextUrl()
            let nextB = loadBalancer?.nextUrl()
            XCTAssertNotEqual(nextA, nextB)
        }
    }

}
