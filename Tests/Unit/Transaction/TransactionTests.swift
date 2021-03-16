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
            fee: fixture.fee,
            tombstoneBlockIndex: fixture.tombstoneBlockIndex,
            fogResolver: fixture.fogResolver))
    }

}
