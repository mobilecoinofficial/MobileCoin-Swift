//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

func testRngCallback(context: UnsafeMutableRawPointer!) -> UInt64 {
    context.assumingMemoryBound(to: MobileCoinXoshiroRng.self).pointee.next()
}

typealias TestRng = MobileCoinXoshiroRng

func testRngSeed() -> RngSeed {
    guard let rngSeed = MobileCoinXoshiroRng().generateRngSeed() else {
        fatalError("Generating an RNG Seed from our Test RNG should not fail.")
    }
    return rngSeed
}
