//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class Slip10UtilsPerfTests: PerformanceTestCase {

    func testPerformancePrivateKeysFromMnemonic() throws {
        let fixture = try AccountKey.Fixtures.Init()
        measure {
            _ = Slip10Utils.accountPrivateKeys(fromMnemonic: fixture.mnemonic, accountIndex: 0)
        }
    }

}
