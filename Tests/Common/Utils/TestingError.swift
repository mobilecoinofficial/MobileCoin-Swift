//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct TestingError: Error {
    let reason: String

    init(_ reason: String) {
        self.reason = reason
    }
}

extension TestingError: CustomStringConvertible {
    var description: String {
        "Testing error: \(reason)"
    }
}
