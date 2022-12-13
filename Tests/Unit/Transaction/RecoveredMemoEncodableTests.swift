//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

final class RecoveredMemoEncodableTests: XCTestCase {

    func testTransactionWithSenderMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .sender(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)

        guard
            let unauthenticated = recoverable.unauthenticatedMemo(),
            let unauthEncoded = try? DictionaryEncoder().encode(unauthenticated) as? [String: Any]
        else {
            XCTFail("Unable to get unauthenticated memo data for encodable testing")
            return
        }

        XCTAssertEqual(unauthEncoded as NSDictionary, expected as NSDictionary)
    }

    func testSenderWithPaymentRequestMemoEncodable() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .senderWithPaymentRequest(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data for encodable testing")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
            "paymentRequestId": recovered.paymentRequestId,
        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)

        guard
            let unauthenticated = recoverable.unauthenticatedMemo(),
            let unauthEncoded = try? DictionaryEncoder().encode(unauthenticated) as? [String: Any]
        else {
            XCTFail("Unable to get unauthenticated memo data for encodable testing")
            return
        }

        XCTAssertEqual(unauthEncoded as NSDictionary, expected as NSDictionary)
    }

    func testSenderWithPaymentIntentMemoEncodable() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentIntentAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .senderWithPaymentIntent(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data for encodable testing")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
            "paymentIntentId": recovered.paymentIntentId,
        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)

        guard
            let unauthenticated = recoverable.unauthenticatedMemo(),
            let unauthEncoded = try? DictionaryEncoder().encode(unauthenticated) as? [String: Any]
        else {
            XCTFail("Unable to get unauthenticated memo data for encodable testing")
            return
        }

        XCTAssertEqual(unauthEncoded as NSDictionary, expected as NSDictionary)
    }

    func testDestinationMemoEncodable() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destination(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover(),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
            "fee": recovered.fee,
            "totalOutlay": recovered.totalOutlay,
            "numberOfRecipients": recovered.numberOfRecipients,
        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)
    }

    func testDestinationWithPaymentRequestMemoEncodable() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destinationWithPaymentRequest(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover(),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
            "fee": recovered.fee,
            "totalOutlay": recovered.totalOutlay,
            "numberOfRecipients": recovered.numberOfRecipients,
            "paymentRequestId": recovered.paymentRequestId,

        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)
    }

    func testDestinationWithPaymentIntentMemoEncodable() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentIntentAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destinationWithPaymentIntent(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover(),
            let encoded = try? DictionaryEncoder().encode(recovered) as? [String: Any]
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        let expected: [String: Any] = [
            "addressHashHex": recovered.addressHashHex,
            "fee": recovered.fee,
            "totalOutlay": recovered.totalOutlay,
            "numberOfRecipients": recovered.numberOfRecipients,
            "paymentIntentId": recovered.paymentIntentId,

        ]

        XCTAssertEqual(encoded as NSDictionary, expected as NSDictionary)
    }

}
