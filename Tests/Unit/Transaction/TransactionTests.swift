//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

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
            blockVersion: fixture.blockVersion))
    }

    // TODO refactor to be less messy
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
            blockVersion: .legacy).get()
        
        let txOut = txOutContext.changeTxOutContext.txOut
        let accountKey = fixture.accountKey
        let indexedKeyImage = txOut.indexedKeyImage(
            index: accountKey.subaddressIndex,
            accountKey: accountKey)
        guard let (index, _) = indexedKeyImage,
              index == McConstants.DEFAULT_SUBADDRESS_INDEX else {
                XCTFail("Invalid")
                  return
        }
    }

    // TODO refactor to be less messy
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
            blockVersion: .minRTHEnabled).get()
        
        let txOut = txOutContext.changeTxOutContext.txOut
        let accountKey = fixture.accountKey
        let indexedKeyImage = txOut.indexedKeyImage(
            index: accountKey.changeSubaddressIndex,
            accountKey: accountKey)
        guard let (index, _) = indexedKeyImage,
              index == McConstants.DEFAULT_CHANGE_SUBADDRESS_INDEX else {
                XCTFail("Invalid")
                  return
        }
    }

    func testExactChangeCreatesChangeOutput() throws {
        let fixture = try Transaction.Fixtures.ExactChange()

        // TODO - Do we need to test on both blockversions ?
        let txOutContext = try TransactionBuilder.build(
            inputs: fixture.inputs,
            accountKey: fixture.accountKey,
            outputs: fixture.outputs,
            memoType: .unused,
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver,
            blockVersion: .minRTHEnabled).get()
        
        XCTAssertNotNil(txOutContext.changeTxOutContext)
    }

}
