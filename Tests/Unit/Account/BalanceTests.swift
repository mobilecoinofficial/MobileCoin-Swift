//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class BalanceTests: XCTestCase {

    func testMaxBalance() {
        let fixture = BalanceTests.Fixtures.MaxMob()
        let maxBalance = Balance(values: fixture.maxBalanceTxoAmounts, blockCount: 1, tokenId: .MOB)
        XCTAssertEqual(maxBalance.amountPicoMobHigh, 10)
        XCTAssertEqual(maxBalance.amountPicoMobLow, 15532559262904483840)
        XCTAssertEqual(maxBalance.amountMobParts.mobInt, fixture.maxBalanceMob)
        XCTAssertEqual(maxBalance.amountMobParts.picoFrac, 0)
    }

    func testMaxBalanceMOBUSD() {
        let fixture = BalanceTests.Fixtures.MaxMobUSD()
        let maxBalance = Balance(
            values: fixture.maxBalanceTxoAmounts,
            blockCount: 1,
            tokenId: .MOBUSD)
        XCTAssertEqual(maxBalance.amountHigh, 10)
        XCTAssertEqual(maxBalance.amountLow, 15532559262904483840)
        XCTAssertEqual(maxBalance.amountParts.int, 200_000_000_000_000)
        XCTAssertEqual(maxBalance.amountParts.frac, 0)
    }

}

extension BalanceTests {
    enum Fixtures {}
}

extension BalanceTests.Fixtures {
    struct MaxMob {
        let divideBy: UInt64 = 1_000_000_000_000
        let maxBalanceMob: UInt64 = 200_000_000
        let maxBalanceTxoAmountPico: UInt64 = 10_000_000__000_000_000_000
        let maxBalanceNumTxos: Int
        let maxBalanceTxoAmounts: Array<UInt64>

        init() {
            self.maxBalanceNumTxos =
                Int(UInt64(maxBalanceMob) / (maxBalanceTxoAmountPico / divideBy))
            self.maxBalanceTxoAmounts =
                Array(repeating: maxBalanceTxoAmountPico, count: maxBalanceNumTxos)
        }
    }

    struct MaxMobUSD {
        let divideBy: UInt64 = 1_000_000
        let maxBalanceMobUSD: UInt64 = 200_000_000_000_000
        let txoAmountMicro: UInt64 = 10_000_000_000_000__000_000
        let maxBalanceNumTxos: Int
        let maxBalanceTxoAmounts: Array<UInt64>
        
        init() {
            self.maxBalanceNumTxos =
                Int(UInt64(maxBalanceMobUSD) / (txoAmountMicro / divideBy))
            self.maxBalanceTxoAmounts =
                Array(repeating: txoAmountMicro, count: maxBalanceNumTxos)
            
        }
    }
}
