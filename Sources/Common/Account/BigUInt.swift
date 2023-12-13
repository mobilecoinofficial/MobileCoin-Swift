//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

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

/// Partial implementation of `protocol FixedWidthInteger`
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
        
        // Handle LOW overflow, by adding to HIGH component.
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

extension BigUInt: Equatable {}
extension BigUInt: Hashable {}
