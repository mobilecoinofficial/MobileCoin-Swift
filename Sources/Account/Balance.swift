//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct Balance {
    public let amountPicoMobLow: UInt64
    public let amountPicoMobHigh: UInt8
    public let tokenId: TokenId
    let blockCount: UInt64
    
    init(values: [UInt64], blockCount: UInt64, tokenId: TokenId) {
        var amountLow: UInt64 = 0
        var amountHigh: UInt8 = 0
        // 18446744073709551615
        // 1553255926290448384
        
        // 18446744073709551615
        // 10000000000000000000
        for (index, value) in values.enumerated() {
            print("\(index < 10 ? "0" + String(index) : String(index)) \(value)")
            let (partialValue, overflow) = amountLow.addingReportingOverflow(value)
            print("overflow: \(overflow ? "Y" : "N") \(partialValue)")
            amountLow = partialValue
            if overflow {
                amountHigh += 1
            }
        }
        self.init(
            amountLow: amountLow,
            amountHigh: amountHigh,
            blockCount: blockCount,
            tokenId: tokenId)
    }

    init(amountLow: UInt64, amountHigh: UInt8, blockCount: UInt64, tokenId: TokenId) {
        self.amountPicoMobLow = amountLow
        self.amountPicoMobHigh = amountHigh
        self.blockCount = blockCount
        self.tokenId = tokenId
    }

    /// - Returns: `nil` when the amount is too large to fit in a `UInt64`.
    public func amountPicoMob() -> UInt64? {
        guard amountPicoMobHigh == 0 else {
            return nil
        }
        return amountPicoMobLow
    }

    /// Convenience accessor for balance value. `mobInt` is the integer part of the value when
    /// represented in MOB. `picoFrac` is the fractional part of the value when represented in MOB.
    /// However, rather than reprenting the fractional part as a decimal fraction, it is represented
    /// in picoMOB, thus allowing both parts to be integer values.
    ///
    /// The purpose of this representation is to facilitate presenting the balance to the user in
    /// MOB form.
    ///
    /// To illustrate, given an amount in the form of XXXXXXXXX.YYYYYYYYYYYY MOB,
    /// - `mobInt`: XXXXXXXXX (denominated in MOB)
    /// - `picoFrac`: YYYYYYYYYYYY (denominated in picoMOB)
    ///
    /// It is necessary to break apart the values into 2 parts because the total max possible
    /// balance is too large to fit in a single `UInt64`, when denominated in picoMOB, assuming 250
    /// million MOB in circulation and assuming a base unit of 1 picoMOB as the smallest indivisible
    /// unit of MOB.
    public var amountMobParts: (mobInt: UInt32, picoFrac: UInt64) {
        //
        // > Example math with significant digits == 12
        //
        // amount (picoMOB) = amountLow + amountHigh * 2^64
        //
        // amountLowMobDec = amountLow / 10^12
        // amountHighMobDec = amountHigh * 2^64 / 10^12
        //
        // amountMobDec = amountLowMobDec + amountHighMobDec
        //
        // amountLowMobInt = floor(amountLow / 10^12)
        // amountLowPicoFrac = amountLow % 10^12

        // amountHighMobInt = floor((amountHigh * 2^64) / 10^12)
        //                  = floor((amountHigh * (2^52 * 2^12)) / (5^12 * 2^12)
        //
        //                  // factor out the (2^12), for now
        //                  = floor((amountHigh << 52) / 5^12)
        //
        // amountHighPicoFrac = (amountHigh * 2^64) % 10^12
        
        //                  // re-apply the 2^12
        //                   = ((amountHigh << 52) % 5^12) << 12
        //
        // amountPicoFracCarry = floor((amountLowPicoFrac + amountHighPicoFrac) / 10^12)
        //
        // amountMobInt = amountLowMobInt + amountHighMobInt + amountPicoFracCarry
        // amountPicoFrac = (amountLowPicoFrac + amountHighPicoFrac) % 10^12

        
        //
        // > Example math with significant digits == 6
        //
        // amount (picoMOB) = amountLow + amountHigh * 2^64
        //
        // amountLowMobDec = amountLow / 10^6
        // amountHighMobDec = amountHigh * 2^64 / 10^6
        //
        // amountMobDec = amountLowMobDec + amountHighMobDec
        //
        // amountLowMobInt = floor(amountLow / 10^6)
        // amountLowPicoFrac = amountLow % 10^6

        // amountHighMobInt = floor((amountHigh * 2^64) / 10^6)
        //                  = floor((amountHigh * (2^52 * 2^6)) / (5^6 * 2^6)
        //
        //                  // factor out the (2^6), for now
        //                  = floor((amountHigh << 58) / 5^6)
        //
        // amountHighPicoFrac = (amountHigh * 2^64) % 10^6
        
        //                  // re-apply the 2^6
        //                   = ((amountHigh << 58) % 5^6) << 6
        //
        // amountPicoFracCarry = floor((amountLowPicoFrac + amountHighPicoFrac) / 10^6)
        //
        // amountMobInt = amountLowMobInt + amountHighMobInt + amountPicoFracCarry
        // amountPicoFrac = (amountLowPicoFrac + amountHighPicoFrac) % 10^6

        
        // Significant Digits varies based on the the TokenId, examples:
        // 10^12 = 1_000_000_000_000
        // 10^6 = 1_000_000
        let significantDigits = tokenId.significantDigits
        
        let divideBy = UInt64(pow(Double(10), Double(significantDigits)))
        let (amountLowMobInt, amountLowPicoFrac) = { () -> (UInt32, UInt64) in
            // 10^12 = 1_000_000_000_000
            let mobParts = amountPicoMobLow.quotientAndRemainder(dividingBy: divideBy)
            return (UInt32(mobParts.quotient), mobParts.remainder)
        }()

        let (amountHighMobInt, amountHighPicoFrac) = { () -> (UInt32, UInt64) in
            // Intermediary = base of 5^(64-12) MOB
            let amountHighIntermediary = UInt64(amountPicoMobHigh) << (64 - significantDigits)
            // 5^12 = 244_140_625
            // 5^6 = 15_625
            let factored = UInt64(pow(Double(5), Double(significantDigits)))
            let mobParts = amountHighIntermediary.quotientAndRemainder(dividingBy: factored)
            return (UInt32(mobParts.quotient), mobParts.remainder << significantDigits)
        }()

        let amountPicoFracParts = (amountLowPicoFrac + amountHighPicoFrac).quotientAndRemainder(
            dividingBy: divideBy)

        let amountMobInt = amountLowMobInt + amountHighMobInt + UInt32(amountPicoFracParts.quotient)
        let amountPicoFrac = amountPicoFracParts.remainder

        return (amountMobInt, amountPicoFrac)
    }
}

extension Balance: Equatable {}
extension Balance: Hashable {}

extension Balance: CustomStringConvertible {
    public var description: String {
        let amountMob = amountMobParts
        return String(format: "%u.%0\(tokenId.significantDigits)llu \(tokenId.name)", amountMob.mobInt, amountMob.picoFrac)
    }
}
