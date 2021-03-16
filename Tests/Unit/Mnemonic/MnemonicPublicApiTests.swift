//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable vertical_parameter_alignment_on_call

import MobileCoin
import XCTest

class MnemonicPublicApiTests: XCTestCase {

    func test12WordMnemonicFromEntropySucceeds() throws {
        let entropy = try XCTUnwrap(Data(base64Encoded: "xDD+9iYqniHUWH3CL1TBtw=="))
        XCTAssertSuccessEqual(Mnemonic.mnemonic(fromEntropy: entropy),
            "service margin rural era prepare axis fabric autumn season kingdom corn hover")
    }

    func test24WordMnemonicFromEntropySucceeds() throws {
        let entropy =
            try XCTUnwrap(Data(base64Encoded: "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQ="))
        XCTAssertSuccessEqual(Mnemonic.mnemonic(fromEntropy: entropy),
            "health reflect aware glory ignore veteran bag mango cup glimpse lottery master " +
            "space finger civil sock wall swarm ribbon sponsor frame delay marriage oyster")
    }

    func testMnemonicFromZeroLengthEntropyFails() {
        XCTAssertFailure(Mnemonic.mnemonic(fromEntropy: Data()))
    }

    func testMnemonicFromTooShortEntropyFails() throws {
        let entropy = try XCTUnwrap(Data(base64Encoded: "xDD+9iYqniHUWH3CL1TB"))
        XCTAssertFailure(Mnemonic.mnemonic(fromEntropy: entropy))
    }

    func testMnemonicFromTooLongEntropyFails() throws {
        let entropy =
            try XCTUnwrap(Data(base64Encoded: "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQR"))
        XCTAssertFailure(Mnemonic.mnemonic(fromEntropy: entropy))
    }

    func testEntropyFrom12WordMnemonic() throws {
        XCTAssertSuccessEqual(
            Mnemonic.entropy(fromMnemonic:
                "service margin rural era prepare axis fabric autumn season kingdom corn hover"),
            try XCTUnwrap(Data(base64Encoded: "xDD+9iYqniHUWH3CL1TBtw==")))
    }

    func testEntropyFrom24WordMnemonic() throws {
        XCTAssertSuccessEqual(
            Mnemonic.entropy(fromMnemonic:
                "health reflect aware glory ignore veteran bag mango cup glimpse lottery master " +
                "space finger civil sock wall swarm ribbon sponsor frame delay marriage oyster"),
            try XCTUnwrap(Data(base64Encoded: "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQ=")))
    }

    func testEntropyFromUnknownWordMnemonicFails() throws {
        XCTAssertFailure(Mnemonic.entropy(fromMnemonic:
            "service margin rural era prepare axis fabric autumn season kingdom corn hoverx"))
    }

    func testEntropyFromBadChecksumMnemonicFails() throws {
        XCTAssertFailure(Mnemonic.entropy(fromMnemonic:
            "service margin rural era prepare axis fabric autumn season kingdom corn corn"))
    }

    func testWordsByPrefix() throws {
        XCTAssertEqual(Mnemonic.words(matchingPrefix: "z"), ["zebra", "zero", "zone", "zoo"])
    }

    func testAllWords() throws {
        XCTAssertEqual(Mnemonic.allWords.count, 2048)
    }

}
