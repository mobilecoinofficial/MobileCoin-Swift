//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

import Foundation

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt64>.size)
    }
}
