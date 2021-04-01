//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class AccountKeyTests: XCTestCase {

    func testInit() throws {
        let fixture = try AccountKey.Fixtures.Init()
        _ = AccountKey(mnemonic: fixture.mnemonic)
    }

    func testMakeWithFog() throws {
        let fixture = try AccountKey.Fixtures.Init()
        XCTAssertSuccess(AccountKey.make(
            mnemonic: fixture.mnemonicString,
            fogReportUrl: fixture.fogReportUrl,
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki))
    }

    func testFromMnemonic() throws {
        let fixture = try AccountKey.Fixtures.Init()
        let accountKey = AccountKey(mnemonic: fixture.mnemonic)
        XCTAssertEqual(accountKey.viewPrivateKey, fixture.viewPrivateKey)
        XCTAssertEqual(accountKey.spendPrivateKey, fixture.spendPrivateKey)
    }

    func testPrivateKeys() throws {
        let fixture = try AccountKey.Fixtures.DefaultZero()
        let accountKey = fixture.accountKey
        XCTAssertEqual(accountKey.viewPrivateKey, fixture.viewPrivateKey)
        XCTAssertEqual(accountKey.spendPrivateKey, fixture.spendPrivateKey)
    }

    func testSubaddressPrivateKeys() throws {
        let fixture = try AccountKey.Fixtures.DefaultZero()
        let accountKey = fixture.accountKey
        XCTAssertEqual(accountKey.subaddressViewPrivateKey, fixture.subaddressViewPrivateKey)
        XCTAssertEqual(accountKey.subaddressSpendPrivateKey, fixture.subaddressSpendPrivateKey)
    }

    struct DefaultSubaddrKeysFromAcctPrivKeys: TestVector, Decodable {
        let viewPrivateKey: RistrettoPrivate
        let spendPrivateKey: RistrettoPrivate
        let subaddressViewPrivateKey: RistrettoPrivate
        let subaddressSpendPrivateKey: RistrettoPrivate
        let subaddressViewPublicKey: RistrettoPublic
        let subaddressSpendPublicKey: RistrettoPublic
    }

    func testDefaultSubaddrKeysFromAcctPrivKeys() throws {
        for testcase in try DefaultSubaddrKeysFromAcctPrivKeys.testcases() {
            let accountKey = AccountKey(
                viewPrivateKey: testcase.viewPrivateKey,
                spendPrivateKey: testcase.spendPrivateKey)
            let publicAddress = accountKey.publicAddress
            XCTAssertEqual(accountKey.subaddressViewPrivateKey, testcase.subaddressViewPrivateKey)
            XCTAssertEqual(accountKey.subaddressSpendPrivateKey, testcase.subaddressSpendPrivateKey)
            XCTAssertEqual(publicAddress.viewPublicKeyTyped, testcase.subaddressViewPublicKey)
            XCTAssertEqual(publicAddress.spendPublicKeyTyped, testcase.subaddressSpendPublicKey)
        }
    }

    struct SubaddrKeysFromAcctPrivKeys: TestVector, Decodable {
        let viewPrivateKey: RistrettoPrivate
        let spendPrivateKey: RistrettoPrivate
        let subaddressIndex: UInt64
        let subaddressViewPrivateKey: RistrettoPrivate
        let subaddressSpendPrivateKey: RistrettoPrivate
        let subaddressViewPublicKey: RistrettoPublic
        let subaddressSpendPublicKey: RistrettoPublic
    }

    func testSubaddrKeysFromAcctPrivKeys() throws {
        for testcase in try SubaddrKeysFromAcctPrivKeys.testcases() {
            let accountKey = AccountKey(
                viewPrivateKey: testcase.viewPrivateKey,
                spendPrivateKey: testcase.spendPrivateKey,
                subaddressIndex: testcase.subaddressIndex)
            let publicAddress = accountKey.publicAddress
            XCTAssertEqual(accountKey.subaddressViewPrivateKey, testcase.subaddressViewPrivateKey)
            XCTAssertEqual(accountKey.subaddressSpendPrivateKey, testcase.subaddressSpendPrivateKey)
            XCTAssertEqual(publicAddress.viewPublicKeyTyped, testcase.subaddressViewPublicKey)
            XCTAssertEqual(publicAddress.spendPublicKeyTyped, testcase.subaddressSpendPublicKey)
        }
    }

}
