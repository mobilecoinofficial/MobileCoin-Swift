//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class BalanceTests: XCTestCase {

    func testMaxBalance() {
        let maxBalance = Balance(values: Self.maxBalanceTxoAmounts, blockCount: 1, tokenId: .MOB)
        XCTAssertEqual(maxBalance.amountPicoMobHigh, 10)
        XCTAssertEqual(maxBalance.amountPicoMobLow, 15532559262904483840)
        XCTAssertEqual(maxBalance.amountMobParts.mobInt, 200_000_000)
        XCTAssertEqual(maxBalance.amountMobParts.picoFrac, 0)
    }

}

extension BalanceTests {
    static let maxBalanceMob: UInt32 = 200_000_000
    static let maxBalanceTxoAmountPico: UInt64 = 10_000_000__000_000_000_000
    static let maxBalanceNumTxos =
        Int(UInt64(maxBalanceMob) / (maxBalanceTxoAmountPico / 1_000_000_000_000))
    static let maxBalanceTxoAmounts =
        Array(repeating: maxBalanceTxoAmountPico, count: maxBalanceNumTxos)
}

// 18_446_744_073_709_551_615
