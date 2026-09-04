//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TokenId: Sendable {
    public let value: UInt64
    public var name: String {
        Self.names[self] ?? "TokenId \(self.value)"
    }

    public var significantDigits: UInt8 {
        Self.significantDigits[self] ?? 12
    }

    public var siPrefix: String? {
        SIDecimalPrefix(rawValue: significantDigits)?.name
    }

    public init(_ value: UInt64) {
        self.value = value
    }
}

extension TokenId {
    public static let MOB = TokenId(0)
    public static let MOBUSD = TokenId(1)
    public static let TestToken = TokenId(8192)
}

extension TokenId: CustomStringConvertible {
    public var description: String {
        self.name
    }

    static let names: [TokenId: String] = {
        [
            .MOB: "MOB",
            .MOBUSD: "MOBUSD",
            .TestToken: "TestToken",
        ]
    }()

    static let significantDigits: [TokenId: UInt8] = {
        [
            .MOB: 12,
            .MOBUSD: 6,
            .TestToken: 6,
        ]
    }()
}

extension TokenId: Equatable, Hashable {}
