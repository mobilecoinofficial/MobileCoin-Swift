//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct Amount {
    public let value: UInt64
    public let tokenId: TokenId
}

extension Amount {
    public init(value: UInt64, token: TokenId) {
        self.value = value
        self.tokenId = token
    }

    public init(_ value: UInt64, _ tokenId: TokenId) {
        self.value = value
        self.tokenId = tokenId
    }

    init(mob: UInt64) {
        self.init(value: mob, tokenId: .MOB)
    }
}

extension Amount: CustomStringConvertible {
    public var description: String {
        "\(value) \(tokenId.description)"
    }
}

extension Amount: Equatable, Hashable {}
