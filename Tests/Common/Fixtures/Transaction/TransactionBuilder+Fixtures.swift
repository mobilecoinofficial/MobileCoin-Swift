//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

extension TransactionBuilder {
    enum Fixtures {}
}

extension TransactionBuilder.Fixtures {
    struct SenderAndDestination {
        let txFixture: Transaction.Fixtures.TxOutMemo
        let senderPublicAddress: PublicAddress
        let recipeintPublicAddress: PublicAddress
        let receivedTxOut: KnownTxOut
        let sentTxOut: KnownTxOut
        let memoType: MemoType
        let fee: Amount
        let totalOutlay: UInt64

        static let Fixtures = TransactionBuilder.Fixtures.self

        init() throws {
            self.txFixture = try Self.Fixtures.getTxOutMemo()
            self.memoType = Self.getMemoType()
            self.senderPublicAddress = self.txFixture.senderAccountKey.publicAddress
            self.recipeintPublicAddress = self.txFixture.recipientAccountKey.publicAddress
            self.fee = self.txFixture.fee
            self.totalOutlay = self.txFixture.totalOutlay
            self.receivedTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.recipientAccountKey,
                            transaction: try Self.Fixtures.getTransaction(memoType: memoType))
            self.sentTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.senderAccountKey,
                            transaction: try Self.Fixtures.getTransaction(memoType: memoType))
        }

        static func getMemoType() -> MemoType {
            .recoverable
        }
    }

    struct SenderWithPaymentRequestAndDestination {
        let paymentRequestId: UInt64
        let txFixture: Transaction.Fixtures.TxOutMemo
        let senderPublicAddress: PublicAddress
        let recipeintPublicAddress: PublicAddress
        let receivedTxOut: KnownTxOut
        let sentTxOut: KnownTxOut
        let memoType: MemoType
        let fee: Amount
        let totalOutlay: UInt64

        static let Fixtures = TransactionBuilder.Fixtures.self

        init() throws {
            self.memoType = try Self.getMemoType()
            self.txFixture = try Transaction.Fixtures.TxOutMemo()
            self.senderPublicAddress = txFixture.senderAccountKey.publicAddress
            self.recipeintPublicAddress = txFixture.recipientAccountKey.publicAddress
            self.paymentRequestId = Self.paymentRequestId
            self.fee = txFixture.fee
            self.totalOutlay = txFixture.totalOutlay
            self.receivedTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.recipientAccountKey,
                            transaction: try Self.Fixtures.getTransaction(memoType: memoType))
            self.sentTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.senderAccountKey,
                            transaction: try Self.Fixtures.getTransaction(memoType: memoType))
        }

        static let paymentRequestId: UInt64 = 301

        static func getMemoType() throws -> MemoType {
            .customPaymentRequest(
                    sender: try Transaction.Fixtures.TxOutMemo().senderAccountKey,
                    id: paymentRequestId)
        }
    }

    struct SenderAndDestinationBlockVersionOne {
        let txFixture: Transaction.Fixtures.TxOutMemo
        let receivedTxOut: KnownTxOut
        let senderPublicAddress: PublicAddress
        let recipeintPublicAddress: PublicAddress
        let sentTxOut: KnownTxOut
        let memoType: MemoType

        static let Fixtures = TransactionBuilder.Fixtures.self

        init() throws {
            self.memoType = Self.getMemoType()
            self.txFixture = try Transaction.Fixtures.TxOutMemo()
            self.senderPublicAddress = txFixture.senderAccountKey.publicAddress
            self.recipeintPublicAddress = txFixture.recipientAccountKey.publicAddress
            self.receivedTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.recipientAccountKey,
                            transaction: try Self.Fixtures.getTransaction(
                                                                memoType: memoType,
                                                                blockVersion: .legacy))
            self.sentTxOut = try
                        Self.Fixtures.getOwnedOutput(
                            accountKey: txFixture.senderAccountKey,
                            transaction: try Self.Fixtures.getTransaction(
                                                                memoType: memoType,
                                                                blockVersion: .legacy))
        }

        static func getMemoType() -> MemoType {
            .recoverable
        }

    }

}

extension TransactionBuilder.Fixtures {

    static func getTxOutMemo() throws -> Transaction.Fixtures.TxOutMemo {
        try Transaction.Fixtures.TxOutMemo()
    }

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

    static func getReceivedTxOut(
        recipientAccountKey: AccountKey,
        transaction: Transaction
    ) throws -> KnownTxOut {
        try Self.getOwnedOutput(
            accountKey: recipientAccountKey,
            transaction: transaction)
    }

    static func getSentTxOut(
        senderAccountKey: AccountKey,
        transaction: Transaction
    ) throws -> KnownTxOut {
        try Self.getOwnedOutput(
            accountKey: senderAccountKey,
            transaction: transaction)
    }

    static func getTransaction(
        memoType: MemoType,
        blockVersion: BlockVersion = .minRTHEnabled
    ) throws -> Transaction {
        let fixture = try Transaction.Fixtures.TxOutMemo()
        let context = TransactionBuilder.Context(
            accountKey: fixture.senderAccountKey,
            blockVersion: blockVersion,
            fogResolver: fixture.fogResolver,
            memoType: memoType,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())
        return try XCTUnwrapSuccess(TransactionBuilder.build(
                        context: context,
                        inputs: fixture.inputs,
                        to: fixture.recipientAccountKey.publicAddress,
                        amount: fixture.amount)).transaction
    }

}
