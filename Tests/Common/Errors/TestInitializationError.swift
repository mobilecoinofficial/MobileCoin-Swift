//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct TestInitializationError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var localizedDescription: String {
        message
    }
}
