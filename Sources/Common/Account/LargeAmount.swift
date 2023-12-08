//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol LargeAmountPresentable {
    var amount: BigUInt { get }
    var significantDigits: SIPrefix { get }
}

public struct LargeAmount: LargeAmountPresentable {
    let amount: BigUInt
    let tokenId: TokenId
    var significantDigits: SIPrefix {
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

        let divideBy = UInt64.pow(x: .ten, y: significantDigits)
        let (lowInt, lowFrac) = { () -> (UInt64, UInt64) in
            let parts = amount.low.quotientAndRemainder(dividingBy: divideBy)
            return (UInt64(parts.quotient), parts.remainder)
        }()

        let (highInt, highFrac) = { () -> (UInt64, UInt64) in
            let highIntermediary = UInt64(amount.high) << (64 - significantDigits.rawValue)
            let factored = UInt64.pow(x: .five, y: significantDigits)
            let parts = highIntermediary.quotientAndRemainder(dividingBy: factored)
            return (UInt64(parts.quotient), parts.remainder << significantDigits.rawValue)
        }()

        let amountFracParts = (lowFrac + highFrac).quotientAndRemainder(
            dividingBy: divideBy)

        let amountInt = lowInt + highInt + UInt64(amountFracParts.quotient)
        let amountFrac = amountFracParts.remainder

        return (amountInt, amountFrac)
    }
}

extension UInt64 {
    /// This pow function accepts enum's with discrete values that will not overflow a UInt64.
    /// It has no error paths so we don't have to worry about overflow or float conversions.
    ///
    /// A solution that accepts arbitrary integers could be implemented if needed.
    static func pow(x: Denominator, y: SIPrefix) -> UInt64 {
        switch (x, y) {
        //
        // Denominator Five
        //
        case (.five, .deci):
            // 5 ^ 1
            return UInt64(5)
        case (.five, .centi):
            // 5 ^ 2
            return UInt64(25)
        case (.five, .milli):
            // 5 ^ 3
            return UInt64(125)
        case (.five, .micro):
            // 5 ^ 6
            return UInt64(3125)
        case (.five, .nano):
            // 5 ^ 9
            return UInt64(1953125)
        case (.five, .pico):
            // 5 ^ 12
            return UInt64(244140625)
        //
        // Denominator Ten
        //
        case (.ten, .deci):
            // 10 ^ 1
            return UInt64(10)
        case (.ten, .centi):
            // 10 ^ 2
            return UInt64(100)
        case (.ten, .milli):
            // 10 ^ 3
            return UInt64(1000)
        case (.ten, .micro):
            // 10 ^ 6
            return UInt64(1000000)
        case (.ten, .nano):
            // 10 ^ 9
            return UInt64(1000000000)
        case (.ten, .pico):
            // 10 ^ 12
            return UInt64(1000000000000)
        }
    }
    
    /// Ideally we use a UInt4 type here, because we could guarantee no overflow with a UInt64
    /// return type. The next best is to check for overflow and let the call-site handle the
    /// optional.
    static func pow(x: UInt8, y: UInt8) -> UInt64? {
        let initial = (partialValue: UInt64(1), overflow: false)
        let (partialValue, overflow) = Array(repeating: Int(x), count: Int(y))
            .reduce(initial, { partialResult, next in
                let partialValue = partialResult.partialValue
                let nextResult = partialValue.multipliedReportingOverflow(by: UInt64(next))
                return (
                    partialValue: nextResult.partialValue,
                    overflow: partialResult.overflow || nextResult.overflow
                )
            })
         
        guard overflow == false else {
            assertionFailure(
                "Should never overflow. " +
                "Use another way to calculate pow() with integers"
            )
            return nil
        }
                                                                    
        return partialValue
    }
}

enum Denominator: UInt8 {
    case five = 5
    case ten = 10
}
