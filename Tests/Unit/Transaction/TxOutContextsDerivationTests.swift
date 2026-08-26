//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

/// Covers deriving TxOut public keys ahead of the transaction that will carry
/// them.
///
/// The reason this is safe at all is that inputs consume none of the seeded
/// RNG, so the outputs a seed produces do not depend on what is being spent.
/// These pin that: if a draw is ever added ahead of the output keys, or the
/// two paths stop sharing `addOutputs`, the first test here fails.
class TxOutContextsDerivationTests: XCTestCase {

    func testDerivedKeysMatchTheBuiltTransaction() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let context = Self.context(fixture: fixture, rngSeed: testRngSeed())

        let output = try XCTUnwrap(fixture.outputs.first)
        let built = try XCTUnwrapSuccess(TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            to: output.recipient,
            amount: output.amount))

        let derived = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: context,
            recipient: output.recipient,
            amount: output.amount))

        XCTAssertEqual(derived.payload.txOutPublicKey, built.payloadTxOutContext.txOutPublicKey)
        XCTAssertEqual(derived.change.txOutPublicKey, built.changeTxOutContext.txOutPublicKey)
    }

    /// The derivation reports no change amount, because with no inputs there is
    /// nothing left over. The change key still has to match the built
    /// transaction's, which it can only do if amounts never reach the RNG.
    func testChangeAmountDoesNotMoveTheChangeKey() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let context = Self.context(fixture: fixture, rngSeed: testRngSeed())

        let output = try XCTUnwrap(fixture.outputs.first)
        let built = try XCTUnwrapSuccess(TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            to: output.recipient,
            amount: output.amount))

        let derived = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: context,
            recipient: output.recipient,
            amount: output.amount))

        // Guards the test itself: if the built change were also zero there
        // would be nothing to distinguish the amounts.
        XCTAssertNotEqual(
            built.changeTxOutContext.txOut.value(accountKey: fixture.accountKey), 0)
        XCTAssertEqual(derived.change.txOutPublicKey, built.changeTxOutContext.txOutPublicKey)
    }

    func testSameSeedDerivesTheSameKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let first = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient,
            amount: output.amount))
        let second = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient,
            amount: output.amount))

        XCTAssertEqual(first.payload.txOutPublicKey, second.payload.txOutPublicKey)
        XCTAssertEqual(first.change.txOutPublicKey, second.change.txOutPublicKey)
    }

    func testDifferentSeedsDeriveDifferentKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let output = try XCTUnwrap(fixture.outputs.first)

        let first = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: RngSeed()),
            recipient: output.recipient,
            amount: output.amount))
        let second = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: RngSeed()),
            recipient: output.recipient,
            amount: output.amount))

        XCTAssertNotEqual(first.payload.txOutPublicKey, second.payload.txOutPublicKey)
        XCTAssertNotEqual(first.change.txOutPublicKey, second.change.txOutPublicKey)
    }

    /// The public key is `r * D`, so the recipient is as much an input to it as
    /// the seed. A caller holding only a seed cannot know the key.
    func testRecipientChangesThePayloadKey() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let toRecipient = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient,
            amount: output.amount))
        let toSelf = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: fixture.accountKey.publicAddress,
            amount: output.amount))

        XCTAssertNotEqual(toRecipient.payload.txOutPublicKey, toSelf.payload.txOutPublicKey)
    }

    private static func context(
        fixture: Transaction.Fixtures.BuildTxTestNet,
        rngSeed: RngSeed
    ) -> TransactionBuilder.Context {
        TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: fixture.blockVersion,
            fogResolver: fixture.fogResolver,
            memoType: .recoverable,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: rngSeed)
    }

}
