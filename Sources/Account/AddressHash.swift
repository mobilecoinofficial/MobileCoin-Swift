//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct AddressHash {
    let data16: Data16
    
    var hexBytes: String {
        return data16.hexEncodedString()
    }

    init(_ data: Data16) {
        self.data16 = data
    }
}

extension AddressHash: DataConvertibleImpl {
    typealias Iterator = Data.Iterator

    init?(_ data: Data) {
        guard let data16 = Data16(data.data) else {
            return nil
        }
        self.init(data16)
    }

    var data: Data { data16.data }
}

extension AddressHash: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hexBytes == rhs.hexBytes
    }
}

//extension AddressHash: Hashable {
//
//}
//
extension AddressHash: CustomStringConvertible {
    var description: String {
        return hexBytes
    }
}
