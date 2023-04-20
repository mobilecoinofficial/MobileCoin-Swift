//
//  TestSetupClientTests.swift
//  TestSetupClientTests
//
//  Created by Cary Bakker on 4/18/23.
//

import XCTest
@testable import TestSetupClient

final class TestSetupClientTests: XCTestCase {

    func testCreateAccounts() async throws {
        guard let testAccountSeed = ProcessInfo.processInfo.environment["testAccountSeed"] else {
            XCTFail("Unable to get testAccountSeed value")
            return
        }

        guard let srcAcctMnemonic = ProcessInfo.processInfo.environment["srcAcctMnemonic"] else {
            XCTFail("Unable to get source account mnemonic")
            return
        }

        await TestWalletCreator().createAccounts(
            srcAcctMnemonic: srcAcctMnemonic,
            testAccountSeed: testAccountSeed)
    }

}
