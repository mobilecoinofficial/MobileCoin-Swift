//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class AccountTests: XCTestCase {

    func testNoTxOuts() throws {
        let accountKey = try Self.accountKey()
        let testFogService = ViewTestFogService(accountKey: accountKey, txOuts: [])
        let balanceUpdater = try Self.balanceUpdater(fogService: testFogService)

        let expect = expectation(description: "Checking account balance")
        balanceUpdater.updateBalances {
            guard let balances = $0.successOrFulfill(expectation: expect) else { return }
            let balance = balances.mobBalance
            if let balancePicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                XCTAssertEqual(balancePicoMob, 0)
            }
            XCTAssertEqual(balance.blockCount, 1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testViewTxOuts() throws {
        let accountKey = try Self.accountKey()
        let txOutFixture = try TxOut.Fixtures.Default(accountKey: accountKey)
        let testFogService = ViewTestFogService(
            accountKey: accountKey,
            txOuts: [txOutFixture.txOut])
        let balanceUpdater = try Self.balanceUpdater(fogService: testFogService)

        let expect = expectation(description: "Checking account balance")
        balanceUpdater.updateBalances {
            guard
                let balances = $0.successOrFulfill(expectation: expect)?.balances,
                let balance = balances[.MOB] else { return }
            if let balancePicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                XCTAssertEqual(balancePicoMob, txOutFixture.value)
            }
            XCTAssertEqual(balance.blockCount, 1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

    func testMissedBlocks() throws {
        let accountKey = try Self.accountKey()
        let txOutFixture = try TxOut.Fixtures.Default(accountKey: accountKey)
        let testFogService = MissedBlockTestFogService(
            accountKey: accountKey,
            txOuts: [txOutFixture.txOut])
        let balanceUpdater = try Self.balanceUpdater(fogService: testFogService)

        let expect = expectation(description: "Checking account balance")
        balanceUpdater.updateBalances {
            guard
                let balances = $0.successOrFulfill(expectation: expect)?.balances,
                let balance = balances[.MOB] else { return }
            if let balancePicoMob = try? XCTUnwrap(balance.amountPicoMob()) {
                XCTAssertEqual(balancePicoMob, txOutFixture.value)
            }
            XCTAssertEqual(balance.blockCount, 1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

}

extension AccountTests {
    static func accountKey() throws -> AccountKey {
        try AccountKey.Fixtures.Default().accountKey
    }

    static func balanceUpdater(
        fogService: FogBlockService & FogKeyImageService & FogViewService
    ) throws -> Account.BalanceUpdater {
        let accountKey = try self.accountKey()
        let fixture = try Account.Fixtures.Default(accountKey: accountKey)
        return Account.BalanceUpdater(
            account: .init(fixture.account),
            fogViewService: fogService,
            fogKeyImageService: fogService,
            fogBlockService: fogService,
            fogQueryScalingStrategy: DefaultFogQueryScalingStrategy(),
            targetQueue: DispatchQueue.main)
    }
}

private class ViewTestFogService: MockFogService {
    let txOuts: [TxOut]

    init(accountKey: AccountKey, txOuts: [TxOut]) {
        self.txOuts = txOuts
        super.init(accountKey: accountKey)
    }

    override var viewServiceRngKeys: [FogRngKey] {
        [FogRngKey.Fixtures.Default().fogRngKey]
    }

    override var viewServiceTxOuts: [[PartialTxOut]] {
        [txOuts.map { PartialTxOut($0) }]
    }
}

private class MissedBlockTestFogService: MockFogService {
    let txOuts: [TxOut]

    init(accountKey: AccountKey, txOuts: [TxOut]) {
        self.txOuts = txOuts
        super.init(accountKey: accountKey)
    }

    override var viewServiceMissedBlockRanges: [Range<UInt64>] {
        [0..<1]
    }

    override var blockServiceTxOuts: [[TxOut]] {
        [txOuts]
    }
}
