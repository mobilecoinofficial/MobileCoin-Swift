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

    func testAlphaFog() throws {
        let fixture = try AccountKey.Fixtures.AlphaFog()
        XCTAssertSuccess(AccountKey.make(
            entropy: fixture.rootEntropy,
            fogReportUrl: fixture.fogReportUrl,
            fogReportId: fixture.fogReportId,
            fogAuthoritySpki: fixture.fogAuthoritySpki))

        let accountKey = fixture.manualAccountKey
        XCTAssertEqual(
                accountKey.viewPrivateKey.data.hexEncodedString(),
                fixture.viewPrivateKey.data.hexEncodedString())
        XCTAssertEqual(
                accountKey.spendPrivateKey.data.hexEncodedString(),
                fixture.spendPrivateKey.data.hexEncodedString())

        let fogInfo = try XCTUnwrap(accountKey.fogInfo)
        XCTAssertEqual(fogInfo.reportUrlString, fixture.fogReportUrl)
        XCTAssertEqual(fogInfo.reportId, fixture.fogReportId)
        XCTAssertEqual(
                fogInfo.authoritySpki.hexEncodedString(),
                fixture.fogAuthoritySpki.hexEncodedString())
        XCTAssertEqual(fogInfo.reportUrl.description, fixture.fogReportUrl)
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

    func testPublicAddressHash() throws {
        let fixture = try PublicAddress.Fixtures.Default()
        let publicAddress = fixture.publicAddress
        let addressHash = publicAddress.calculateAddressHash()
        XCTAssertNotNil(addressHash)
    }
}
