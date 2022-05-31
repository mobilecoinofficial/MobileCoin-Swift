//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

class TxOutProcessingPerfTests : PerformanceTestCase {
    
    func testPerformanceTxOutTokenIdsSet() throws {
        let fixture = try TxOut.Fixtures.RandomTxOuts(number: 10_000)
        measure {
            let tokenIds = Set(fixture.txOuts.map { $0.tokenId })
            print("number of tokens \(tokenIds.count)")
        }
    }
    
    func testPerformanceTxOutTokenIdsSetXL() throws {
        let fixture = try TxOut.Fixtures.RandomTxOuts(number: 1_000_000)
        measure {
            let tokenIds = Set(fixture.txOuts.map { $0.tokenId })
            print("number of tokens \(tokenIds.count)")
        }
    }
    
    func testPerformanceTxOutBalancesExtreme() throws {
        // The slowest part of this process is creating the Balance struct,
        // the filtering and creating the Set<TokenId> is fast.
        // This essentially creates 5000 Balances.
        let fixture = try TxOut.Fixtures.RandomTxOuts(number: 5000)
        let knowableBlockCount = fixture.knowableBlockCount
        
        measure {
            let balances = Self.cachedBalances(
                txOuts: fixture.txOuts,
                knowableBlockCount: knowableBlockCount)
            print("number of balances \(balances.balances.count)")
        }
    }
    
    func testPerformanceTxOutBalancesRealWorldExtreme() throws {
        // This is a more real-world test where the user may have 1_000_000 txOuts but spread over
        // 10 possible tokens.
        let fixture = try TxOut.Fixtures.RealWorldTxOuts(number: 1_000_000, possibleTokens: 10)
        let knowableBlockCount = fixture.knowableBlockCount
        
        measure {
            let balances = Self.cachedBalances(
                txOuts: fixture.txOuts,
                knowableBlockCount: knowableBlockCount)
            print("number of balances \(balances.balances.count)")
        }
    }
}

extension TxOutProcessingPerfTests {
    static func cachedTokenIds(txOuts: [MockOwnedTxOut]) -> Set<TokenId> {
        return Set(txOuts.map { $0.tokenId })
    }

    static func cachedBalance(
        for tokenId: TokenId,
        txOuts: [MockOwnedTxOut],
        knowableBlockCount: UInt64
    ) -> Balance {
        let txOutValues = txOuts
            .filter { $0.tokenId == tokenId }
            .map { $0.value }
        return Balance(values: txOutValues, blockCount: knowableBlockCount, tokenId: tokenId)
    }

    static func cachedBalances(txOuts: [MockOwnedTxOut], knowableBlockCount: UInt64) -> Balances {
        let balances = cachedTokenIds(txOuts: txOuts).map {
            cachedBalance(for: $0, txOuts: txOuts, knowableBlockCount: knowableBlockCount)
        }
        .reduce(into: [TokenId: Balance](), { result, balance in
            result[balance.tokenId] = balance
        })
        return Balances(balances: balances, blockCount: knowableBlockCount)
    }
}
