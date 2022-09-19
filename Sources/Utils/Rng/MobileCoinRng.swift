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

extension MobileCoinRng {
    func generateData32Seed() -> Data32? {
        Data32(Array([0...4])
            .map { _ in
                self.next()
            }
            .reduce(Data(), { ongoing, next in
                    let data = Data(from: next)
                    return ongoing + data
            })
        )
    }
}
