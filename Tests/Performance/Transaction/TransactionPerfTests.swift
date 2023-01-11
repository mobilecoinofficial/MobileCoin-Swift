//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class TransactionPerfTests: PerformanceTestCase {

    func testPerformanceBuild() throws {
        let fixture = try Transaction.Fixtures.BuildTx()

        measure {
            XCTAssertSuccess(TransactionBuilder.build(
                inputs: fixture.inputs,
                accountKey: fixture.accountKey,
                outputs: fixture.outputs,
                memoType: .unused,
                fee: fixture.fee,
                tombstoneBlockIndex: fixture.tombstoneBlockIndex,
                fogResolver: fixture.fogResolver,
                blockVersion: BlockVersion.legacy,
                rngSeed: testRngSeed()))
        }
    }

}
