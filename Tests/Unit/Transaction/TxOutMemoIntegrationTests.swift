//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TxOutMemoIntegrationTests: XCTestCase {

    func testBuildTransactionWithSenderAndDestinationMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let txFixture = fixture.txFixture

        let context = TransactionBuilder.Context(
            accountKey: txFixture.senderAccountKey,
            blockVersion: txFixture.blockVersion,
            fogResolver: txFixture.fogResolver,
            memoType: .recoverable,
            tombstoneBlockIndex: txFixture.tombstoneBlockIndex,
            fee: txFixture.fee,
            rngSeed: testRngSeed())

        XCTAssertSuccess(TransactionBuilder.build(
            context: context,
            inputs: txFixture.inputs,
            to: txFixture.recipientAccountKey.publicAddress,
            amount: txFixture.amount))
    }

    func testTransactionWithSenderMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .sender(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress)
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, senderPublicAddress.calculateAddressHash())
    }

    func testTransactionWithDestinationMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destination(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover()
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, recipientPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.fee, fixture.fee.value)
        XCTAssertEqual(recovered.totalOutlay, fixture.totalOutlay)
    }

    func testBuildTransactionWithSenderWithPaymentRequest() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let txFixture = fixture.txFixture

        let context = TransactionBuilder.Context(
            accountKey: txFixture.senderAccountKey,
            blockVersion: txFixture.blockVersion,
            fogResolver: txFixture.fogResolver,
            memoType: fixture.memoType,
            tombstoneBlockIndex: txFixture.tombstoneBlockIndex,
            fee: txFixture.fee,
            rngSeed: testRngSeed())

        XCTAssertSuccess(TransactionBuilder.build(
            context: context,
            inputs: txFixture.inputs,
            to: txFixture.recipientAccountKey.publicAddress,
            amount: txFixture.amount))
    }

    func testTransactionWithSenderWithPaymentRequestMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .senderWithPaymentRequest(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress)
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, senderPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.paymentRequestId, fixture.paymentRequestId)
    }

    func testTransactionSenderWithPaymentRequestDestinationMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destinationWithPaymentRequest(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover()
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, recipientPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.fee, fixture.fee.value)
        XCTAssertEqual(recovered.totalOutlay, fixture.totalOutlay)
        XCTAssertEqual(recovered.paymentRequestId, fixture.paymentRequestId)
    }

    func testBuildTransactionWithSenderWithPaymentIntent() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentIntentAndDestination()
        let txFixture = fixture.txFixture
        let paymentIntentId = fixture.paymentIntentId

        let context = TransactionBuilder.Context(
            accountKey: txFixture.senderAccountKey,
            blockVersion: txFixture.blockVersion,
            fogResolver: txFixture.fogResolver,
            memoType: fixture.memoType,
            tombstoneBlockIndex: txFixture.tombstoneBlockIndex,
            fee: txFixture.fee,
            rngSeed: testRngSeed())

        XCTAssertSuccess(TransactionBuilder.build(
            context: context,
            inputs: txFixture.inputs,
            to: txFixture.recipientAccountKey.publicAddress,
            amount: txFixture.amount))
    }

    func testTransactionWithSenderWithPaymentIntentMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentIntentAndDestination()
        let senderPublicAddress = fixture.senderPublicAddress
        let receivedTxOut = fixture.receivedTxOut

        guard
            case let .senderWithPaymentIntent(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress)
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, senderPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.paymentIntentId, fixture.paymentIntentId)
    }

    func testTransactionSenderWithPaymentIntentDestinationMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentIntentAndDestination()
        let recipientPublicAddress = fixture.recipeintPublicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destinationWithPaymentIntent(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover()
        else {
            XCTFail("Unable to recover memo data")
            return
        }

        XCTAssertEqual(recovered.addressHash, recipientPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.fee, fixture.fee.value)
        XCTAssertEqual(recovered.totalOutlay, fixture.totalOutlay)
        XCTAssertEqual(recovered.paymentIntentId, fixture.paymentIntentId)
    }

    func testBlockVersionOneUnusedMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestinationBlockVersionOne()
        let sentTxOut = fixture.sentTxOut

        XCTAssertTrue(
            sentTxOut.recoverableMemo == .notset,
            "Expecting a Recoverable Memo of type .notset"
        )
    }

}
