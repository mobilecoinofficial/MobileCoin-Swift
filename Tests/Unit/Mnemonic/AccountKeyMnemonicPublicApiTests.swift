//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import MobileCoin
import XCTest

class AccountKeyMnemonicPublicApiTests: XCTestCase {

    func testRootEntropyFromMnemonicUsingAccountIndex0() throws {
        XCTAssertSuccessEqual(
            AccountKey.rootEntropy(
                fromMnemonic:
                    "service margin rural era prepare axis fabric autumn season kingdom corn hover",
                accountIndex: 0),
            try XCTUnwrap(Data(base64Encoded: "KIjs5OlwghZpuZlscxqM5Vf06uTSddlL4DVp9PcvYKY=")))
    }

    func testRootEntropyFromMnemonicUsingAccountIndex1() throws {
        XCTAssertSuccessEqual(
            AccountKey.rootEntropy(
                fromMnemonic:
                    "service margin rural era prepare axis fabric autumn season kingdom corn hover",
                accountIndex: 1),
            try XCTUnwrap(Data(base64Encoded: "uQRkCAxw/kG45QmwCOST7S7fQEbUudSBZd642PQk9i0=")))
    }

}
