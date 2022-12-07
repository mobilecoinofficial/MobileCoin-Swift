//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

class MaskedAmount {
    var maskedAmount: UInt64
    var maskedTokenId: Data
    var version: McMaskedAmountVersion

    public init(_ maskedAmount: UInt64, maskedTokenId: Data, version: McMaskedAmountVersion) {
        self.maskedAmount = maskedAmount
        self.maskedTokenId = maskedTokenId
        self.version = version
    }
}

extension MaskedAmount: CustomStringConvertible {
    public var description: String {
        "\(maskedAmount) \(maskedTokenId.description)"
    }
}

extension MaskedAmount: Equatable {
    static func ==(lhs: MaskedAmount, rhs: MaskedAmount) -> Bool {
        return lhs.maskedAmount == rhs.maskedAmount
            && lhs.maskedTokenId == rhs.maskedTokenId
            && lhs.version == rhs.version
    }
}

extension McMaskedAmountVersion: Hashable {}

extension MaskedAmount: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(maskedAmount)
      hasher.combine(maskedTokenId)
      hasher.combine(version)
    }
}
