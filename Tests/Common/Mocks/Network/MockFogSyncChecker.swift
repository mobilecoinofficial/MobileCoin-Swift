//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

class MockFogSyncChecker: FogSyncCheckable {
    var viewsHighestKnownBlock: UInt64
    var ledgersHighestKnownBlock: UInt64
    var consensusHighestKnownBlock: UInt64

    let maxAllowedBlockDelta: PositiveUInt64
    
    static let delta: UInt64 = 10
    
    init(viewIndex: UInt64, ledgerIndex: UInt64, consensusIndex: UInt64) {
        viewsHighestKnownBlock = viewIndex
        ledgersHighestKnownBlock = ledgerIndex
        consensusHighestKnownBlock = consensusIndex
        
        guard let positiveDelta = PositiveUInt64(Self.delta) else {
            logger.fatalError("Should never be reached as 10 > 0")
        }
        maxAllowedBlockDelta = positiveDelta
    }
    
    func setViewsHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
    
    func setLedgersHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
    
    func setConsensusHighestKnownBlock(_: UInt64) {
        // Do nothing
    }
}
