//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public class MobileCoinRng {
    @available(*, unavailable)
    public func nextUInt64() -> UInt64 {
        fatalError("Subclass must override")
    }
}
