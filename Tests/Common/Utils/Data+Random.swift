//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Data {
    public init(randomOfLength length: Int) throws {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        if status == errSecSuccess {
            self.init(bytes: bytes)
        } else {
            throw SecurityError()
        }
    }
}
