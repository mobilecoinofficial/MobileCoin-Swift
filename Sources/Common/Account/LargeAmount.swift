//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol LargeAmountPresentable {
    var amount: BigUInt { get }
    var significantDigits: UInt8 { get }
}

enum BigUIntInitErrors : Error {
    case overflowFromValues
}

public struct BigUInt {
    public let low: UInt64
    public let high: UInt64
    
    public init?(values: [UInt64]) {
        var low: UInt64 = 0
        var high: UInt64 = 0
        
        do {
            for value in values {
                let (partialValue, overflow) = low.addingReportingOverflow(value)
                low = partialValue
                if overflow {
                    let (newHigh, highOverflow) = high.addingReportingOverflow(1)
                    if highOverflow {
                        // Handles case where sum(values) > BigUInt.max
                        throw BigUIntInitErrors.overflowFromValues
                    }
                    high = newHigh
                }
            }
        } catch {
            return nil
        }
        
        self.low = low
        self.high = high
    }
    
    public init(low: UInt64, high: UInt64) {
        self.low = low
        self.high = high
    }
}

// public protocol FixedWidthInteger : BinaryInteger, LosslessStringConvertible where Self.Magnitude : FixedWidthInteger, Self.Magnitude : UnsignedInteger, Self.Stride : FixedWidthInteger, Self.Stride : SignedInteger {
extension BigUInt {
    
    /// Returns the sum of this value and the given value, along with a Boolean
    /// value indicating whether overflow occurred in the operation.
    ///
    /// - Parameter rhs: The value to add to this value.
    /// - Returns: A tuple containing the result of the addition along with a
    ///   Boolean value indicating whether overflow occurred. If the `overflow`
    ///   component is `false`, the `partialValue` component contains the entire
    ///   sum. If the `overflow` component is `true`, an overflow occurred and
    ///   the `partialValue` component contains the truncated sum of this value
    ///   and `rhs`.
    public func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool) {
        let lhs = self
        
        // Add LOW parts
        let (newLow, lowOverflow) = lhs.low.addingReportingOverflow(rhs.low)
        
        // Add LOW overflow
        let (workingHigh, highOverflowFromLowOverflow) = {
            if lowOverflow {
                // Found low overflow, add one to high.
                return lhs.high.addingReportingOverflow(1)
            } else {
                // No low overflow, high amount stays the same.
                return (lhs.high, false)
            }
        }()
        
        guard highOverflowFromLowOverflow == false else {
            // Overflowed, return partial amount w/ overflow true.
            // workingHigh is 0 because it overflowed adding 1.
            assert(workingHigh == 0)
            let partialBigUInt = BigUInt(
                low: newLow,
                high: workingHigh
            )
            return (
                partialValue: partialBigUInt,
                overflow: true
            )
        }
        
        // Add HIGH parts
        let (newHigh, highOverflow) = workingHigh.addingReportingOverflow(rhs.high)
        
        guard highOverflow == false else {
            // Overflowed, return partial amount w/ overflow true.
            let partialBigUInt = BigUInt(
                low: newLow,
                high: newHigh
            )
            return (
                partialValue: partialBigUInt,
                overflow: true
            )
        }
        
        // No overflow, safe to make a new BigUInt and return.
        let newBigUInt = BigUInt(
            low: newLow,
            high: newHigh
        )
        return (
            partialValue: newBigUInt,
            overflow: false
        )
    }

    /// Returns the difference obtained by subtracting the given value from this
    /// value, along with a Boolean value indicating whether overflow occurred in
    /// the operation.
    ///
    /// - Parameter rhs: The value to subtract from this value.
    /// - Returns: A tuple containing the result of the subtraction along with a
    ///   Boolean value indicating whether overflow occurred. If the `overflow`
    ///   component is `false`, the `partialValue` component contains the entire
    ///   difference. If the `overflow` component is `true`, an overflow occurred
    ///   and the `partialValue` component contains the truncated result of `rhs`
    ///   subtracted from this value.
    public func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool) {
        let lhs = self
        
        let (newLow, lowOverflow) = lhs.low.subtractingReportingOverflow(rhs.low)
        
        // subtract LOW overflow
        let (workingHigh, highOverflowFromLowOverflow) = {
            if lowOverflow {
                // Found low overflow, remove one from high.
                return lhs.high.subtractingReportingOverflow(1)
            } else {
                // No low overflow, high amount stays the same.
                return (lhs.high, false)
            }
        }()
        
        guard highOverflowFromLowOverflow == false else {
            // Overflowed, return partial amount w/ overflow true.
            // We know workingHigh is UInt64.max because it overflowed subtracting 1.
            assert(workingHigh == UInt64.max)
            let partialBigUInt = BigUInt(
                low: newLow,
                high: workingHigh
            )
            return (
                partialValue: partialBigUInt,
                overflow: true
            )
        }
        
        // Subtract HIGH parts
        let (newHigh, highOverflow) = workingHigh.subtractingReportingOverflow(rhs.high)
        
        guard highOverflow == false else {
            // Overflowed, return partial amount w/ overflow true.
            let partialBigUInt = BigUInt(
                low: newLow,
                high: newHigh
            )
            return (
                partialValue: partialBigUInt,
                overflow: true
            )
        }
        
        // No overflow, safe to make a new BigUInt and return.
        let newBigUInt = BigUInt(
            low: newLow,
            high: newHigh
        )
        return (
            partialValue: newBigUInt,
            overflow: false
        )
    }
}

extension BigUInt {
    static var max = BigUInt(low: UInt64.max, high: UInt64.max)
    static var zero = BigUInt(low: 0, high: 0)
}

public struct LargeAmount: LargeAmountPresentable {
    let amount: BigUInt
    let tokenId: TokenId
    var significantDigits: UInt8 {
        tokenId.significantDigits
    }
    
    init?(values: [UInt64], minusFee: UInt64, tokenId: TokenId) {
        // TODO
        guard let amount = BigUInt(values: values) else {
            return nil
        }
        self.amount = amount
        self.tokenId = tokenId
    }
    
    init?(values: [UInt64], tokenId: TokenId) {
        guard let amount = BigUInt(values: values) else {
            return nil
        }
        self.amount = amount
        self.tokenId = tokenId
    }
    
    init(amount: BigUInt, tokenId: TokenId) {
        self.amount = amount
        self.tokenId = tokenId
    }
}

extension LargeAmount {
    static func empty(tokenId: TokenId) -> Self {
        LargeAmount(amount: BigUInt(low: 0, high: 0), tokenId: tokenId)
    }
}

extension LargeAmountPresentable {
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
    public var amountParts: (int: UInt64, frac: UInt64) {
        //
        // >> Example math with significantDigits == 12 (MOB)
        //
        // amount (picoMOB) = low + high * 2^64
        //
        // >> Now expand low & high to "decimal" numbers
        //
        // lowMobDec = low / 10^12
        // highMobDec = high * 2^64 / 10^12
        //
        // >> where 10^12 is 10^(significantDigits)
        //
        // amountMobDec = lowMobDec + highMobDec
        //
        // >> Now expand lowDec & highDec to their Integer & Fractional parts
        //
        // >> lowDec = lowMobInt.lowPicoFrac
        //
        // lowMobInt = floor(low / 10^12)
        // lowPicoFrac = low % 10^12
        //
        // >> highDec = highMobInt.highPicoFrac
        //
        // highMobInt = floor((high * 2^64) / 10^12)
        //
        //                  >> factor out common 2^12 for now
        //                  = floor((high * (2^52 * 2^12)) / (5^12 * 2^12)
        //
        //                  >> bitshift by 52 (same as multiply by 2^52)
        //                  >> ... and bitshift number == (64 - significantDigits)
        //                  = floor((high << 52) / 5^12)
        //
        // highPicoFrac = (high * 2^64) % 10^12
        //
        //                  >> re-apply the 2^12
        //                  = ((high << 52) % 5^12) << 12
        //
        // amountPicoFracCarry = floor((lowPicoFrac + highPicoFrac) / 10^12)
        //
        // amountMobInt = lowMobInt + highMobInt + amountPicoFracCarry
        // amountPicoFrac = (lowPicoFrac + highPicoFrac) % 10^12

        let significantDigits = significantDigits

        let divideBy = UInt64(pow(Double(10), Double(significantDigits)))
        let (lowInt, lowFrac) = { () -> (UInt64, UInt64) in
            let parts = amount.low.quotientAndRemainder(dividingBy: divideBy)
            return (UInt64(parts.quotient), parts.remainder)
        }()

        let (highInt, highFrac) = { () -> (UInt64, UInt64) in
            let highIntermediary = UInt64(amount.high) << (64 - significantDigits)
            let factored = UInt64(pow(Double(5), Double(significantDigits)))
            let parts = highIntermediary.quotientAndRemainder(dividingBy: factored)
            return (UInt64(parts.quotient), parts.remainder << significantDigits)
        }()

        let amountFracParts = (lowFrac + highFrac).quotientAndRemainder(
            dividingBy: divideBy)

        let amountInt = lowInt + highInt + UInt64(amountFracParts.quotient)
        let amountFrac = amountFracParts.remainder

        return (amountInt, amountFrac)
    }

}
