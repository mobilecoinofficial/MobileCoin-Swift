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
            recipient: output.recipient))

        XCTAssertEqual(derived.payload.txOutPublicKey, built.payloadTxOutContext.txOutPublicKey)
        XCTAssertEqual(derived.change.txOutPublicKey, built.changeTxOutContext.txOutPublicKey)
    }

    /// The derivation names no amounts at all — it has no parameter for them —
    /// while the built transaction carries real ones. The keys still match,
    /// which is what shows no amount reaches a draw.
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
            recipient: output.recipient))

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
            recipient: output.recipient))
        let second = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient))

        XCTAssertEqual(first.payload.txOutPublicKey, second.payload.txOutPublicKey)
        XCTAssertEqual(first.change.txOutPublicKey, second.change.txOutPublicKey)
    }

    func testDifferentSeedsDeriveDifferentKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let output = try XCTUnwrap(fixture.outputs.first)

        let first = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: testRngSeed()),
            recipient: output.recipient))
        let second = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: Self.otherRngSeed),
            recipient: output.recipient))

        XCTAssertNotEqual(first.payload.txOutPublicKey, second.payload.txOutPublicKey)
        XCTAssertNotEqual(first.change.txOutPublicKey, second.change.txOutPublicKey)
    }

    /// Same reasoning for the fee: the derivation is given one that no real
    /// transaction would use, and the keys are unaffected.
    func testFeeDoesNotMoveTheKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let realFee = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient))
        let absurdFee = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(
                fixture: fixture,
                rngSeed: seed,
                fee: Amount(999_999_999, in: fixture.fee.tokenId)),
            recipient: output.recipient))

        XCTAssertEqual(realFee.payload.txOutPublicKey, absurdFee.payload.txOutPublicKey)
        XCTAssertEqual(realFee.change.txOutPublicKey, absurdFee.change.txOutPublicKey)
    }

    /// The token id is its own question, separate from the value.
    /// `txOutContexts` takes both zero amounts from `context.fee.tokenId`, and
    /// `MobileCoinClient` pins that to `.MOB`, so a caller deriving for a
    /// non-MOB transaction runs the builder with a token id the real send will
    /// not use. This pins that it makes no difference to the keys.
    ///
    /// Both sides run at block version two because that is the first version
    /// accepting a token id other than MOB — at the fixture's own version the
    /// non-MOB build fails with `TokenIdNotSupportedAtBlockVersion` rather
    /// than producing keys to compare.
    func testTokenIdDoesNotMoveTheKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let inMob = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(
                fixture: fixture,
                rngSeed: seed,
                fee: Amount(fixture.fee.value, in: .MOB),
                blockVersion: .versionTwo),
            recipient: output.recipient))
        let inMobUsd = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(
                fixture: fixture,
                rngSeed: seed,
                fee: Amount(fixture.fee.value, in: .MOBUSD),
                blockVersion: .versionTwo),
            recipient: output.recipient))

        XCTAssertEqual(inMob.payload.txOutPublicKey, inMobUsd.payload.txOutPublicKey)
        XCTAssertEqual(inMob.change.txOutPublicKey, inMobUsd.change.txOutPublicKey)
    }

    /// And the memo, which is what a payment request id would select.
    func testMemoTypeDoesNotMoveTheKeys() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let recoverable = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient))
        let unused = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed, memoType: .unused),
            recipient: output.recipient))

        XCTAssertEqual(recoverable.payload.txOutPublicKey, unused.payload.txOutPublicKey)
        XCTAssertEqual(recoverable.change.txOutPublicKey, unused.change.txOutPublicKey)
    }

    /// The public key is `r * D`, so the recipient is as much an input to it as
    /// the seed. A caller holding only a seed cannot know the key.
    func testRecipientChangesThePayloadKey() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = testRngSeed()
        let output = try XCTUnwrap(fixture.outputs.first)

        let toRecipient = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: output.recipient))
        let toSelf = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: Self.context(fixture: fixture, rngSeed: seed),
            recipient: fixture.accountKey.publicAddress))

        XCTAssertNotEqual(toRecipient.payload.txOutPublicKey, toSelf.payload.txOutPublicKey)
    }

    /// A second seed, fixed so a failure can be re-run. Differs from
    /// `testRngSeed()` in its last byte.
    private static let otherRngSeed = RngSeed(Data(repeating: 0, count: 31) + Data([1]))!

    private static func context(
        fixture: Transaction.Fixtures.BuildTxTestNet,
        rngSeed: RngSeed,
        fee: Amount? = nil,
        memoType: MemoType = .recoverable,
        blockVersion: BlockVersion? = nil
    ) -> TransactionBuilder.Context {
        TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: blockVersion ?? fixture.blockVersion,
            fogResolver: fixture.fogResolver,
            memoType: memoType,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fee ?? fixture.fee,
            rngSeed: rngSeed)
    }

}
