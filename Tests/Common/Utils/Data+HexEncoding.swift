//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension Data {
    init?(hexEncoded hexEncodedString: String) {
        guard let data = HexEncoding.data(fromHexEncodedString: hexEncodedString) else {
            return nil
        }
        self = data
    }

    func hexEncodedString() -> String {
        HexEncoding.hexEncodedString(fromData: self)
    }
}
