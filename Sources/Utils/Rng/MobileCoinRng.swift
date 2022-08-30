//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// swiftlint:disable unavailable_function
public class MobileCoinRng: RandomNumberGenerator {
    public func next() -> UInt64 {
        fatalError("Subclass must override")
    }
}
