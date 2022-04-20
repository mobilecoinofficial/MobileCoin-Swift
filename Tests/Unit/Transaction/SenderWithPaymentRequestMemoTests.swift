//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin

class SenderWithPaymentRequestMemoTests: XCTestCase {
    func testSenderWithPaymentRequestMemoCreate() throws {
        let fixture = try MemoData.Fixtures.SenderWithPaymentRequestMemo()
        
        let memoData = try XCTUnwrap(
            SenderWithPaymentRequestMemoUtils.create(
                senderAccountKey: fixture.senderAccountKey,
                receipientPublicAddress: fixture.recieverAccountKey.publicAddress,
                txOutPublicKey: fixture.txOutPublicKey,
                paymentRequestId: fixture.paymentRequestId))
        
        XCTAssertEqual(
            memoData.data.hexEncodedString(),
            fixture.expectedMemoData.hexEncodedString())

        XCTAssertTrue(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be true for valid memo data")

        XCTAssertEqual(
            SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: memoData),
            fixture.senderAccountKey.publicAddress.calculateAddressHash())

        XCTAssertEqual(
            SenderWithPaymentRequestMemoUtils.getPaymentRequestId(memoData: memoData),
            fixture.paymentRequestId)
    }
    
    func testInvalidSenderWithPaymentRequestMemoCreateFails() throws {
        let fixture = try MemoData.Fixtures.InvalidSenderWithPaymentRequestMemo()
        
        XCTAssertFalse(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: fixture.invalidMemoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be false for invalidMemoData")
        
        XCTAssertNotEqual(
            SenderWithPaymentRequestMemoUtils.getAddressHash(memoData: fixture.invalidMemoData),
            fixture.senderAccountKey.publicAddress.calculateAddressHash(),
            "AddressHash values should not match for invalid memo data")

    }
    
    func testSenderWithPaymentRequestMemoWrongPrivateKeyInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderWithPaymentRequestMemoInvalidates()
        
        XCTAssertFalse(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.wrongReceiverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be `false` for incorrect view private key")
    }
    
    func testSenderWithPaymentRequestMemoWrongSenderAddresssInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderWithPaymentRequestMemoInvalidates()
        
        XCTAssertFalse(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.wrongSenderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.txOutPublicKey),
            "Expected isValid to be `false` for incorrect sender address")
    }
    
    func testSenderWithPaymentRequestMemoWrongTxOutPublicKeyInvalidates() throws {
        let fixture = try MemoData.Fixtures.SenderWithPaymentRequestMemoInvalidates()
        
        XCTAssertFalse(
            SenderWithPaymentRequestMemoUtils.isValid(
                memoData: fixture.memoData,
                senderPublicAddress: fixture.senderAccountKey.publicAddress,
                receipientViewPrivateKey: fixture.recieverAccountKey.subaddressViewPrivateKey,
                txOutPublicKey: fixture.badTxOutPublicKey),
            "Expected isValid to be `false` for incorrect tx out public key")
    }
}
