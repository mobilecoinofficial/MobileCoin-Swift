//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct Balance {
    public let largeAmount: LargeAmount
    
    public var amountLow: UInt64 {
        largeAmount.amount.low
    }
    public var amountHigh: UInt64 {
        largeAmount.amount.high
    }

    @available(*, deprecated, message: "Use the new SI prefix & token agnostic `.amountLow`")
    public var amountPicoMobLow: UInt64 { amountLow }

    @available(*, deprecated, message: "Use the new SI prefix & token agnostic `.amountHigh`")
    public var amountPicoMobHigh: UInt64 { amountHigh }

    public var tokenId: TokenId {
        largeAmount.tokenId
    }
    
    let blockCount: UInt64

    init(values: [UInt64], blockCount: UInt64, tokenId: TokenId) {
        let largeAmount = LargeAmount(values: values, tokenId: tokenId)
        guard let largeAmount = largeAmount else {
            fatalError("LargeAmount init should never be nil, this indicates overflow past" +
                       "BigUInt.max a 128-bit number unsigned int. MobileCoin network does not " +
                       "support values this large.")
        }
        
        self.largeAmount = largeAmount
        self.blockCount = blockCount
    }

    init(amountLow: UInt64, amountHigh: UInt64, blockCount: UInt64, tokenId: TokenId) {
        let bigUInt = BigUInt(low: amountLow, high: amountHigh)
        let largeAmount = LargeAmount(amount: bigUInt, tokenId: tokenId)
        self.largeAmount = largeAmount
        self.blockCount = blockCount
    }

    /// - Returns: `nil` when the amount is too large to fit in a `UInt64`.
    @available(*, deprecated, message: "Use the new SI prefix & token agnostic `.amount()`")
    public func amountPicoMob() -> UInt64? {
        guard amountHigh == 0 else {
            return nil
        }
        return amountLow
    }

    public func amount() -> UInt64? {
        guard amountHigh == 0 else {
            return nil
        }
        return amountLow
    }

    @available(*, deprecated, message: "Use the new token agnostic `.amountParts`")
    public var amountMobParts: (mobInt: UInt64, picoFrac: UInt64) {
        (mobInt: amountParts.int, picoFrac: amountParts.frac)
    }

    /// Convenience accessor for balance value. `int` is the integer part of the value when
    /// represented in `.tokenId`. `frac` is the fractional part of the value when represented in 
    /// `.tokenId`. However, rather than reprenting the fractional part as a decimal fraction,
    /// it is represented in the tokens fundamental unit. MOB uses 12 significant digits so its
    /// fundamental unit is a picoMOB, thus allowing both parts to be integer values.
    ///
    /// The purpose of this representation is to facilitate presenting the balance to the user in
    /// a readable form for each token.
    ///
    /// To illustrate, given an amount in the form of XXXXXXXXX.YYYYYYYYYYYY MOB,
    /// - `int`: XXXXXXXXX (denominated in MOB)
    /// - `frac`: YYYYYYYYYYYY (denominated in picoMOB)
    ///
    /// It is necessary to break apart the values into 2 parts because the total max possible
    /// balance is too large to fit in a single `UInt64`, when denominated in picoMOB, assuming 250
    /// million MOB in circulation and assuming a base unit of 1 picoMOB as the smallest indivisible
    /// unit of MOB.
    ///
    /// > Note: Implementation of amountParts has move to LargeAmount
    public var amountParts: (int: UInt64, frac: UInt64) {
        largeAmount.amountParts
    }
}

extension Balance: Equatable {}
extension Balance: Hashable {}

extension Balance: CustomStringConvertible {
    public var description: String {
        let amount = amountParts
        return String(
                format: "%llu.%0\(tokenId.significantDigits.rawValue)llu \(tokenId.name)",
                amount.int,
                amount.frac)
    }
}

extension Balance {
    static func empty(blockCount: UInt64, tokenId: TokenId) -> Balance {
        Balance(amountLow: 0, amountHigh: 0, blockCount: blockCount, tokenId: tokenId)
    }
}
