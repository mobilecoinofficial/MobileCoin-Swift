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

    func testTenConsecutiveCallsNeverReturnSameUrlBackToBack() {
        let urlA = "mc://exampleA.com"
        let urlB = "mc://exampleB.com"
        let urlC = "mc://exampleC.com"

        _ = ConsensusUrl.make(strings: [urlA, urlB, urlC]).flatMap { consensusUrls in
            RandomUrlLoadBalancer.make(urls: consensusUrls).flatMap { loadBalancer in
                var currentUrl: MobileCoinUrl<ConsensusScheme>
                var newUrl: MobileCoinUrl<ConsensusScheme> = loadBalancer.nextUrl()

                for _ in 1...10 {
                    currentUrl = newUrl
                    newUrl = loadBalancer.nextUrl()
                    XCTAssertNotEqual(currentUrl, newUrl)
                }
            }
        }
    }

}
