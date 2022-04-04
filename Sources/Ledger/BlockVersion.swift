//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

enum BlockVersion : UInt32 {
    // TODO - Update static library with decremented code, then decrement raw values here
    case zero = 0
    case one = 1
}

extension BlockVersion {
    static func canEnableRecoverableMemos(version: BlockVersion) -> Bool {
        version >= one
    }
    
    static var legacy: BlockVersion {
        zero
    }
    
    static var minRTHEnabled: BlockVersion {
        one
    }
}

extension BlockVersion: Comparable {
    static func < (lhs: BlockVersion, rhs: BlockVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
