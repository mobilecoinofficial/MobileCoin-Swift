//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TransactionPerfTests: PerformanceTestCase {

    func testPerformanceBuild() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let context = TransactionBuilder.Context(
            accountKey: fixture.accountKey,
            blockVersion: BlockVersion.legacy,
            fogResolver: fixture.fogResolver,
            memoType: .unused,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fee: fixture.fee,
            rngSeed: testRngSeed())
        measure {
            XCTAssertSuccess(TransactionBuilder.build(
                context: context,
                inputs: fixture.inputs,
                outputs: fixture.outputs))
        }
    }

}
