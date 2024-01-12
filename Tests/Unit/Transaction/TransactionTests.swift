//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

class TransactionTests: XCTestCase {

    func testBuildWorks() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()

        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: fixture.blockVersion,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())

        XCTAssertSuccess(TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            outputs: fixture.outputs))
    }

    func testLegacyBlockVersion() throws {
        let fixture = try Transaction.Fixtures.BuildTx()

        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: .legacy,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())

        let txOutContext = try TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            outputs: fixture.outputs).get()

        let txOut = txOutContext.changeTxOutContext.txOut
        let accountKey = fixture.accountKey
        let indexedKeyImage = txOut.constructKeyImage(
            index: accountKey.subaddressIndex,
            accountKey: accountKey)
        guard let (index, _) = indexedKeyImage,
              index == McConstants.DEFAULT_SUBADDRESS_INDEX else {
                XCTFail("Invalid")
                  return
        }
    }

    func testRTHBlockVersion() throws {
        let fixture = try Transaction.Fixtures.BuildTx()

        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: .minRTHEnabled,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())

        let txOutContext = try TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            outputs: fixture.outputs).get()

        let txOut = txOutContext.changeTxOutContext.txOut
        let accountKey = fixture.accountKey
        let indexedKeyImage = txOut.constructKeyImage(
            index: accountKey.changeSubaddressIndex,
            accountKey: accountKey)
        guard let (index, _) = indexedKeyImage,
              index == McConstants.DEFAULT_CHANGE_SUBADDRESS_INDEX else {
                XCTFail("Invalid")
                  return
        }
    }

    func testFutureBlockVersionFailure() throws {
        let fixture = try Transaction.Fixtures.BuildTx()

        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: .versionMax,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())

        XCTAssertFailure(TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            outputs: fixture.outputs))
    }

    func testExactChangeCreatesChangeOutput() throws {
        let fixture = try Transaction.Fixtures.ExactChange()

        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: .minRTHEnabled,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())

        let txOutContext = try TransactionBuilder.build(
            context: context,
            inputs: fixture.inputs,
            outputs: fixture.outputs).get()

        XCTAssertNotNil(txOutContext.changeTxOutContext)
    }

}
