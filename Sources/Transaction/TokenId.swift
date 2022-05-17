//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TokenId {
    public let value: UInt64

    public init(_ value: UInt64) {
        self.value = value
    }
}

extension TokenId {
    public static var MOB = TokenId(0)
}

extension TokenId: CustomStringConvertible {
    public var description: String {
        Self.names[self] ?? "Token \(self.value)"
    }

    public static var names: [TokenId: String] = {
        [.MOB: "MOB"]
    }()
}

extension TokenId: Equatable, Hashable {}
