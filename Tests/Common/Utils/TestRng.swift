//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable line_length

import Foundation

// From:
// https://github.com/mattgallagher/CwlUtils/blob/0bfc4587d01cfc796b6c7e118fc631333dd8ab33/Sources/CwlUtils/CwlRandom.swift
class Xoshiro: RandomNumberGenerator {
    typealias StateType = (UInt64, UInt64, UInt64, UInt64)

    private var state: StateType = (0, 0, 0, 0)

    init(seed: StateType = (12345678, 87654321, 10293847, 29384756)) {
        self.state = seed
    }

    func next() -> UInt64 {
        // Derived from public domain implementation of xoshiro256** here:
        // http://xoshiro.di.unimi.it
        // by David Blackman and Sebastiano Vigna
        let x = state.1 &* 5
        let result = ((x &<< 7) | (x &>> 57)) &* 9
        let t = state.1 &<< 17
        state.2 ^= state.0
        state.3 ^= state.1
        state.1 ^= state.2
        state.0 ^= state.3
        state.2 ^= t
        state.3 = (state.3 &<< 45) | (state.3 &>> 19)
        return result
    }
}

func testRngCallback(context: UnsafeMutableRawPointer!) -> UInt64 {
    context.assumingMemoryBound(to: Xoshiro.self).pointee.next()
}

typealias TestRng = Xoshiro
