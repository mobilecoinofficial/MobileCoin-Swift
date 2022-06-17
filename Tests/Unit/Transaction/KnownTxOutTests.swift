//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class KnownTxOutTests: XCTestCase {

    func testFogViewRecordMemoPayloadNotSet() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultNotSet()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case .notset = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
    }

    func testFogViewRecordMemoPayloadUnused() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultUnused()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case .unused = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
    }

    func testFogViewRecordSenderMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case .sender = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
    }

    func testFogViewRecordSenderMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case let .sender(recoverableMemo) = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
        let recovered = try XCTUnwrap(
            recoverableMemo.recover(senderPublicAddress: fixture.senderAccountKey.publicAddress))
        let senderAddressHash = fixture.senderAccountKey.publicAddress.calculateAddressHash()
        XCTAssertEqual(recovered.addressHash, senderAddressHash)
    }

    func testFogViewRecordDestinationMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultDestinationMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case .destination = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
    }

    func testFogViewRecordDestinationMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultDestinationMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case let .destination(recoverableMemo) = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
        let recovered = try XCTUnwrap(recoverableMemo.recover())
        XCTAssertEqual(recovered.fee, fixture.fee)
        XCTAssertEqual(recovered.totalOutlay, fixture.totalOutlay)
        XCTAssertEqual(recovered.numberOfRecipients, fixture.numberOfRecipients.value)
    }

    func testFogViewRecordSenderWithPaymentRequestMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case .senderWithPaymentRequest = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
    }

    func testFogViewRecordSenderWithPaymentRequestMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo

        guard case let .senderWithPaymentRequest(recoverableMemo) = txOutMemo else {
            XCTFail("TxOutMemo type mismatch")
            return
        }
        let recovered = try XCTUnwrap(
            recoverableMemo.recover(senderPublicAddress: fixture.senderAccountKey.publicAddress))
        let senderAddressHash = fixture.senderAccountKey.publicAddress.calculateAddressHash()
        XCTAssertEqual(recovered.addressHash, senderAddressHash)
        XCTAssertEqual(recovered.paymentRequestId, fixture.paymentRequestId)
    }

    func testKnownTxOutShareSecret() throws {
        let fixture = try KnownTxOut.Fixtures.GetSharedSecret()
        let txOut = fixture.knownTxOut

        let txOutSharedSecret = txOut.sharedSecret
        let sharedSecret = try XCTUnwrap(TxOutUtils.sharedSecret(
            viewPrivateKey: fixture.receiverAccountKey.viewPrivateKey,
            publicKey: fixture.knownTxOut.publicKey))

        XCTAssertEqual(sharedSecret.data.hexEncodedString(), sharedSecret.hexEncodedString())
    }
}
