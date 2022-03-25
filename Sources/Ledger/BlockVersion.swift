//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

enum BlockVersion : UInt32 {
    case one = 1
    case two = 2
}

extension BlockVersion {
    static func canEnableRecoverableMemos(version: BlockVersion) -> Bool {
        version >= two
    }
    
    static var minRTHEnabled: BlockVersion {
        two
    }
}

extension BlockVersion: Comparable {
    static func < (lhs: BlockVersion, rhs: BlockVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
