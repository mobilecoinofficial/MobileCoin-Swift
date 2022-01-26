//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct EmptySSLCertificate {
    var trustRootsBytes : [Data]? = nil

    init?(trustRootBytes bytes: [Data]) throws {
        return nil
    }
}

