//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable multiline_function_chains

@testable import MobileCoin
import XCTest

class TransactionTests: XCTestCase {

    func testBuildWorks() throws {
        let fixture = try Transaction.Fixtures.BuildTx()
        XCTAssertSuccess(TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: fixture.blockVersion,
            rngSeed: testRngSeed()))
    }

    func testLegacyBlockVersion() throws {
        let fixture = try Transaction.Fixtures.BuildTx()
        let txOutContext = try TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: .legacy,
            rngSeed: testRngSeed()).get()

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
        let txOutContext = try TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: .minRTHEnabled,
            rngSeed: testRngSeed()).get()

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
        XCTAssertFailure(TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: .versionMax,
            rngSeed: testRngSeed()))
    }

    func testExactChangeCreatesChangeOutput() throws {
        let fixture = try Transaction.Fixtures.ExactChange()

        let txOutContext = try TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: .minRTHEnabled,
            rngSeed: testRngSeed()).get()

        XCTAssertNotNil(txOutContext.changeTxOutContext)
    }

}
