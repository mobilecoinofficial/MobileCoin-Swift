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

        let divideBy = UInt64.pow(x: .ten, y: significantDigits.uint4)
        let (lowInt, lowFrac) = { () -> (UInt64, UInt64) in
            let parts = amount.low.quotientAndRemainder(dividingBy: divideBy)
            return (UInt64(parts.quotient), parts.remainder)
        }()

        let (highInt, highFrac) = { () -> (UInt64, UInt64) in
            let highIntermediary = UInt64(amount.high) << (64 - significantDigits.rawValue)
            let factored = UInt64.pow(x: .five, y: significantDigits.uint4)
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
    /// Using a UInt4 enum here allows us to always return the partial value becuase
    /// Uint4.max ^ Uint4.max cannot overflow in a UInt64.
    static func pow(x: UInt4, y: UInt4) -> UInt64 {
        return pow(x: x.rawValue, y: y.rawValue).partialValue
    }
    
    /// Partial value behavior is undefined if overflow is true, making private to prevent misuse.
    private static func pow(x: UInt8, y: UInt8) -> (partialValue: Self, overflow: Bool) {
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
                "Partial value behavior undefined with overflow. " +
                "Use another way to calculate pow() with integers"
            )
            return (partialValue, true)
        }
                                                                    
        return (partialValue, false)
    }
}

enum UInt4: UInt8 {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case eleven = 11
    case twelve = 12
    case thirteen = 13
    case fourteen = 14
    case fifteen = 15
}
