//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TokenId {
    public let value: UInt64
    public var name: String {
        Self.names[self] ?? "TokenId \(self.value)"
    }

    public var significantDigits: SIPrefix {
        guard let significantDigits = Self.significantDigits[self] else {
            assertionFailure(
                "Error: Expecting a significant digits value." +
                "add a SignificantsDigits case value for this TokenId."
            )
            return SIPrefix.pico
        }
        return significantDigits
    }

    public var siPrefix: String? {
        significantDigits.name
    }

    public init(_ value: UInt64) {
        self.value = value
    }
}

extension TokenId {
    public static var MOB = TokenId(0)
    public static var MOBUSD = TokenId(1)
    public static var TestToken = TokenId(8192)
}

extension TokenId: CustomStringConvertible {
    public var description: String {
        self.name
    }

    static var names: [TokenId: String] = {
        [
            .MOB: "MOB",
            .MOBUSD: "MOBUSD",
            .TestToken: "TestToken",
        ]
    }()

    static var significantDigits: [TokenId: SIPrefix] = {
        [
            .MOB: .pico,
            .MOBUSD: .micro,
            .TestToken: .micro,
        ]
    }()
}

extension TokenId: Equatable, Hashable {}

public enum SIPrefix: UInt8 {
    case deci = 1
    case centi = 2
    case milli = 3
    case micro = 6
    case nano = 9
    case pico = 12
//    case femto = 15
//    case atto = 18
//    case zepto = 21
//    case yocto = 24
}

extension SIPrefix {
    var name: String { String(describing: self) }
}

//enum SignificantDigits: UInt8 {
//    case deci = 1
//    case centi = 2
//    case milli = 3
//    case micro = 6
//    case nano = 9
//    case pico = 12
//    case femto = 15
//}
//
//extension SignificantDigits {
//    
//}
