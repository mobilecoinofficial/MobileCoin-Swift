//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol FogSyncCheckable {
    var viewsHighestKnownBlock: UInt64 { get }
    var ledgersHighestKnownBlock: UInt64 { get }
    var consensusHighestKnownBlock: UInt64 { get }
    var currentBlockIndex: UInt64 { get }
    var fogSyncThreshold: UInt64 { get }
    
    func inSync() -> Result<(), FogSyncError>
    func setLedgersHighestKnownBlock(_:UInt64)
    func setViewsHighestKnownBlock(_:UInt64)
    func setConsensusHighestKnownBlock(_:UInt64)
}

extension FogSyncCheckable {
    func inSync() -> Result<(), FogSyncError> {
        guard viewLedgerOutOfSync == false else {
            return .failure(.viewLedgerOutOfSync(viewsHighestKnownBlock, ledgersHighestKnownBlock))
        }
        guard consensusOutOfSync == false else {
            return .failure(.consensusOutOfSync(consensusHighestKnownBlock, currentBlockIndex))
        }
        return .success(())
    }
    
    var currentBlockIndex: UInt64 {
        min(ledgersHighestKnownBlock, viewsHighestKnownBlock)
    }
    
    private var viewLedgerOutOfSync: Bool {
        abs(
            Int64(
                max(viewsHighestKnownBlock, ledgersHighestKnownBlock)
                &- min(viewsHighestKnownBlock, ledgersHighestKnownBlock)
            )
        ) >= fogSyncThreshold
    }
    
    private var consensusOutOfSync: Bool {
        consensusHighestKnownBlock > currentBlockIndex &&
            Int64(consensusHighestKnownBlock &- currentBlockIndex) >= fogSyncThreshold
    }
}

class FogSyncChecker: FogSyncCheckable {
    var viewsHighestKnownBlock: UInt64 = 0
    var ledgersHighestKnownBlock: UInt64 = 0
    var consensusHighestKnownBlock: UInt64 = 0
    
    let fogSyncThreshold: UInt64 = 10
    
    func setViewsHighestKnownBlock(_ value:UInt64) {
        viewsHighestKnownBlock = value
    }
    
    func setLedgersHighestKnownBlock(_ value:UInt64) {
        ledgersHighestKnownBlock = value
    }

    func setConsensusHighestKnownBlock(_ value:UInt64) {
        consensusHighestKnownBlock = value
    }
}

public enum FogSyncError: Error {
    case viewLedgerOutOfSync(UInt64, UInt64)
    case consensusOutOfSync(UInt64, UInt64)
}

extension FogSyncError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .viewLedgerOutOfSync(let viewBlockIndex, let ledgerBlockIndex):
            return "Fog view and ledger block indices are out of sync. " +
                "Try again later. View index: \(viewBlockIndex), Ledger index: \(ledgerBlockIndex)"
        case .consensusOutOfSync(let consensusBlockIndex, let currentBlockIndex):
            return "Fog has not finished syncing with Consensus. " +
                "Try again later (Block index \(currentBlockIndex) / \(consensusBlockIndex)."
        }
    }
}
