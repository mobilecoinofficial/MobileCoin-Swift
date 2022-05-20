//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

/// TODO Document, add extra hooks as needed
public struct Amount {
    public let value: UInt64
    public let tokenId: TokenId
}

extension Amount {
    // TODO - deprecate and switch naming
    public init(value: UInt64, tokenId: UInt64) {
        self.value = value
        self.tokenId = TokenId(tokenId)
    }
    
    public init(_ value: UInt64, _ token: TokenId) {
        self.value = value
        self.tokenId = token
    }
    
    public init(value: UInt64, token: TokenId) {
        self.value = value
        self.tokenId = token
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
