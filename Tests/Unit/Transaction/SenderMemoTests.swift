//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class SenderMemoTests: XCTestCase {
    func testSenderMemoCreate() throws {
        let fixture = try MemoData.Fixtures.SenderMemo()
        
        let memoData = try XCTUnwrap(
            SenderMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey))
        
        XCTAssertEqual(
            memoData.data.hexEncodedString(),
            fixture.expectedMemoData.hexEncodedString())

        XCTAssertTrue(
            SenderMemoUtils.isValid(
                memoData: memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be true for valid memo data")

        XCTAssertEqual(
            SenderMemoUtils.getAddressHash(memoData: memoData),
            fixture.senderAccountKey.publicAddress.calculateAddressHash())
    }
    
    func testInvalidSenderMemoCreateFails() throws {
        let fixture = try MemoData.Fixtures.InvalidSenderMemo()

        XCTAssertFalse(
            SenderMemoUtils.isValid(
                memoData: fixture.invalidMemoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be false for invalidMemoData")
        
        XCTAssertNotEqual(
            SenderMemoUtils.getAddressHash(memoData: fixture.invalidMemoData),
            fixture.senderAccountKey.publicAddress.calculateAddressHash(),
            "AddressHash values should not match for invalid memo data")
    }
    
    func testSenderMemoWrongPrivateViewKeyInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderMemoInvalidates()
        
        XCTAssertFalse(
            SenderMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.wrongReceiverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be `false` for incorrect private view key")
    }
    
    func testSenderMemoWrongSenderAddressInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderMemoInvalidates()
        
        XCTAssertFalse(
            SenderMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.wrongSenderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be `false` for incorrect senderPublicAddress")
    }
    
    func testSenderMemoWrongPublicAddressInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderMemoInvalidates()
        
        XCTAssertFalse(
            SenderMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.badTxOutPublicKey),
            "Expected isValid to be `false` for incorrect txOutPublicKey")
    }
    
}
