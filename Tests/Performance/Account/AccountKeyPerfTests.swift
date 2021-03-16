//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class AccountKeyPerfTests: PerformanceTestCase {

    func testPerformancePrivateKeysFromRootEntropy() throws {
        let fixture = try AccountKey.Fixtures.Init()
        measure {
            _ = AccountKeyUtils.privateKeys(fromRootEntropy: fixture.rootEntropy)
        }
    }

}
