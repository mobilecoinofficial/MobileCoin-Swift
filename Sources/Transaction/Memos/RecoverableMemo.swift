//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol RecoverableMemo {
    var memoData: Data64 { get }
    var addressHash: AddressHash { get }
}
