//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TxOutMemoParserTests: XCTestCase {

    func testEmptyMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultEmptyPayload()
        XCTAssertEqual(
            .notset,
            TxOutMemoParser.parse(
                decryptedPayload: fixture.payload,
                accountKey: fixture.senderAccountKey,
                txOut: fixture.txOut))
    }

    func testUnusedMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultUnusedPayload()
        XCTAssertEqual(
            .unused,
            TxOutMemoParser.parse(
                decryptedPayload: fixture.payload,
                accountKey: fixture.senderAccountKey,
                txOut: fixture.txOut))
    }

    func testSenderMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultSenderMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .sender = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

    func testDestinationMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultDestinationMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .destination = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

    func testSenderWithPaymentRequestMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .senderWithPaymentRequest = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

    func testDestinationWithPaymentRequestMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultDestinationWithPaymentRequestMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .destinationWithPaymentRequest = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

    func testSenderWithPaymentIntentMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultSenderWithPaymentIntentMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .senderWithPaymentIntent = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

    func testDestinationWithPaymentIntentMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultDestinationWithPaymentIntentMemo()
        let txOutMemo = TxOutMemoParser.parse(
            decryptedPayload: fixture.payload,
            accountKey: fixture.senderAccountKey,
            txOut: fixture.txOut)

        guard case .destinationWithPaymentIntent = txOutMemo else {
            XCTFail("Unexcpeted RecoverableMemo type")
            return
        }
    }

}
