//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class TxOutMemoIntegrationTests: XCTestCase {
    
    func testBuildTransactionWithSenderAndDestinationMemo() throws {
        let txFixture = try Transaction.Fixtures.TxOutMemo()

        XCTAssertSuccess(TransactionBuilder.build(
            inputs: txFixture.inputs,
            accountKey: txFixture.senderAccountKey,
            to: txFixture.recipientAccountKey.publicAddress,
            memoType: .recoverable,
            amount: txFixture.amount,
            fee: txFixture.fee,
            tombstoneBlockIndex: txFixture.tombstoneBlockIndex,
            fogResolver: txFixture.fogResolver,
            blockVersion: txFixture.blockVersion))
    }

    func testTransactionWithSenderMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestination()
        let txFixture = fixture.txFixture
        let senderAccountKey = txFixture.senderAccountKey
        let senderPublicAddress = senderAccountKey.publicAddress
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
        let txFixture = fixture.txFixture
        let recipientAccountKey = txFixture.recipientAccountKey
        let recipientPublicAddress = recipientAccountKey.publicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destination(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover()
        else {
            XCTFail("Unable to recover memo data")
            return
        }
        
        XCTAssertEqual(recovered.addressHash, recipientPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.fee, txFixture.fee)
        XCTAssertEqual(recovered.totalOutlay, txFixture.totalOutlay)
    }

    func testBuildTransactionWithSenderWithPaymentRequest() throws {
        let txFixture = try Transaction.Fixtures.TxOutMemo()
        let paymentRequestId =
            TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination.paymentRequestId

        XCTAssertSuccess(TransactionBuilder.build(
            inputs: txFixture.inputs,
            accountKey: txFixture.senderAccountKey,
            to: txFixture.recipientAccountKey.publicAddress,
            memoType: .customPaymentRequest(sender: txFixture.senderAccountKey, id: paymentRequestId),
            amount: txFixture.amount,
            fee: txFixture.fee,
            tombstoneBlockIndex: txFixture.tombstoneBlockIndex,
            fogResolver: txFixture.fogResolver,
            blockVersion: txFixture.blockVersion))
    }

    func testTransactionWithSenderWithPaymentRequestMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let txFixture = fixture.txFixture
        let senderAccountKey = txFixture.senderAccountKey
        let senderPublicAddress = senderAccountKey.publicAddress
        let receivedTxOut = fixture.receivedTxOut
        let paymentRequestId =
            TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination.paymentRequestId

        guard
            case let .senderWithPaymentRequest(recoverable) = receivedTxOut.recoverableMemo,
            let recovered = recoverable.recover(senderPublicAddress: senderPublicAddress)
        else {
            XCTFail("Unable to recover memo data")
            return
        }
        
        XCTAssertEqual(recovered.addressHash, senderPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.paymentRequestId, paymentRequestId)
    }

    func testTransactionSenderWithPaymentRequestDestinationMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderWithPaymentRequestAndDestination()
        let txFixture = fixture.txFixture
        let recipientAccountKey = txFixture.recipientAccountKey
        let recipientPublicAddress = recipientAccountKey.publicAddress
        let sentTxOut = fixture.sentTxOut

        guard
            case let .destination(recoverable) = sentTxOut.recoverableMemo,
            let recovered = recoverable.recover()
        else {
            XCTFail("Unable to recover memo data")
            return
        }
        
        XCTAssertEqual(recovered.addressHash, recipientPublicAddress.calculateAddressHash())
        XCTAssertEqual(recovered.fee, txFixture.fee)
        XCTAssertEqual(recovered.totalOutlay, txFixture.totalOutlay)
    }

    func testBlockVersionOneUnusedMemo() throws {
        let fixture = try TransactionBuilder.Fixtures.SenderAndDestinationBlockVersionOne()
        let txFixture = fixture.txFixture
        let recipientAccountKey = txFixture.recipientAccountKey
        let recipientPublicAddress = recipientAccountKey.publicAddress
        let sentTxOut = fixture.sentTxOut

        XCTAssertTrue(
            sentTxOut.recoverableMemo == .notset,
            "Expecting a Recoverable Memo of type .notset"
        )
    }

}

extension TransactionBuilder {
    enum Fixtures {}
}

extension TransactionBuilder.Fixtures {
    struct SenderAndDestination {
        let txFixture: Transaction.Fixtures.TxOutMemo
        let receivedTxOut: KnownTxOut
        let sentTxOut: KnownTxOut
       
        static let memoType: MemoType = .recoverable

        init() throws {
            self.receivedTxOut = try Self.getReceivedTxOut()
            self.sentTxOut = try Self.getSentTxOut()
            self.txFixture = try Transaction.Fixtures.TxOutMemo()
        }
        
        static func getMemoType() -> MemoType {
            .recoverable
        }
        
        static func getReceivedTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().recipientAccountKey,
                transaction: try Self.getTransaction())
        }
        
        static func getSentTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().senderAccountKey,
                transaction: try Self.getTransaction())
        }
        
        private static func getTransaction() throws -> Transaction {
            let fixture = try Transaction.Fixtures.TxOutMemo()
            let memoType = getMemoType()
            return try XCTUnwrapSuccess(TransactionBuilder.build(
                            inputs: fixture.inputs,
                            accountKey: fixture.senderAccountKey,
                            to: fixture.recipientAccountKey.publicAddress,
                            memoType: memoType,
                            amount: fixture.amount,
                            fee: fixture.fee,
                            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
                            fogResolver: fixture.fogResolver,
                            blockVersion: fixture.blockVersion)).transaction
                        
        }
        
    }
    
    struct SenderWithPaymentRequestAndDestination {
        let paymentRequestId: UInt64
        let txFixture: Transaction.Fixtures.TxOutMemo
        let receivedTxOut: KnownTxOut
        let sentTxOut: KnownTxOut

        init() throws {
            self.paymentRequestId = Self.paymentRequestId
            self.receivedTxOut = try Self.getReceivedTxOut()
            self.sentTxOut = try Self.getSentTxOut()
            self.txFixture = try Transaction.Fixtures.TxOutMemo()
        }
        
        static let paymentRequestId: UInt64 = 301
        
        static func getMemoType() throws -> MemoType {
            try .customPaymentRequest(
                    sender: try Transaction.Fixtures.TxOutMemo().senderAccountKey,
                    id: paymentRequestId)
        }
        
        static func getReceivedTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().recipientAccountKey,
                transaction: try Self.getTransaction())
        }
        
        static func getSentTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().senderAccountKey,
                transaction: try Self.getTransaction())
        }
        
        private static func getTransaction() throws -> Transaction {
            let fixture = try Transaction.Fixtures.TxOutMemo()
            let memoType = try getMemoType()
            return try XCTUnwrapSuccess(TransactionBuilder.build(
                            inputs: fixture.inputs,
                            accountKey: fixture.senderAccountKey,
                            to: fixture.recipientAccountKey.publicAddress,
                            memoType: memoType,
                            amount: fixture.amount,
                            fee: fixture.fee,
                            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
                            fogResolver: fixture.fogResolver,
                            blockVersion: fixture.blockVersion)).transaction
        }
        
    }
    
    struct SenderAndDestinationBlockVersionOne {
        let txFixture: Transaction.Fixtures.TxOutMemo
        let receivedTxOut: KnownTxOut
        let sentTxOut: KnownTxOut
       
        static let memoType: MemoType = .recoverable

        init() throws {
            self.receivedTxOut = try Self.getReceivedTxOut()
            self.sentTxOut = try Self.getSentTxOut()
            self.txFixture = try Transaction.Fixtures.TxOutMemo()
        }
        
        static func getMemoType() -> MemoType {
            .recoverable
        }
        
        static func getReceivedTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().recipientAccountKey,
                transaction: try Self.getTransaction())
        }
        
        static func getSentTxOut() throws -> KnownTxOut {
            try Transaction.Fixtures.getOwnedOutput(
                accountKey: try Transaction.Fixtures.TxOutMemo().senderAccountKey,
                transaction: try Self.getTransaction())
        }
        
        private static func getTransaction() throws -> Transaction {
            let fixture = try Transaction.Fixtures.TxOutMemo()
            let memoType = getMemoType()
            return try XCTUnwrapSuccess(TransactionBuilder.build(
                            inputs: fixture.inputs,
                            accountKey: fixture.senderAccountKey,
                            to: fixture.recipientAccountKey.publicAddress,
                            memoType: memoType,
                            amount: fixture.amount,
                            fee: fixture.fee,
                            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
                            fogResolver: fixture.fogResolver,
                            blockVersion: BlockVersion.one)).transaction
                        
        }
        
    }
    
}

extension Transaction.Fixtures {
    static func getOwnedOutput(
        accountKey: AccountKey,
        transaction: Transaction,
        globalIndex: UInt64 = Transaction.Fixtures.TxOutMemo.globalIndex,
        blockMetadata: BlockMetadata = Transaction.Fixtures.TxOutMemo.blockMetadata
    ) throws -> KnownTxOut {
        try XCTUnwrap(
            transaction.outputs.compactMap({
                            LedgerTxOut(
                                PartialTxOut($0),
                                globalIndex: globalIndex,
                                block: blockMetadata)
                                    .decrypt(accountKey: accountKey)
                            }
                        ).first)
    }
}
