//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol MixinSelectionStrategy {
    func selectMixinIndices(
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64],
        ringSize: Int
    ) -> [Set<UInt64>]
}

extension MixinSelectionStrategy {
    func selectMixinIndices(
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64] = []
    ) -> [Set<UInt64>] {
        selectMixinIndices(
            forRealTxOutIndices: realTxOutIndices,
            selectionRange: selectionRange,
            excludedTxOutIndices: excludedTxOutIndices,
            ringSize: McConstants.RING_SIZE)
    }
}

protocol CustomRNGMixinSelectionStrategy: MixinSelectionStrategy {
    func selectMixinIndices(
        rng: MobileCoinRng,
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64],
        ringSize: Int
    ) -> [Set<UInt64>]
}

extension CustomRNGMixinSelectionStrategy {
    func selectMixinIndices(
        rng: MobileCoinRng,
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64] = []
    ) -> [Set<UInt64>] {
        selectMixinIndices(
            rng: rng,
            forRealTxOutIndices: realTxOutIndices,
            selectionRange: selectionRange,
            excludedTxOutIndices: excludedTxOutIndices,
            ringSize: McConstants.RING_SIZE)
    }

    func selectMixinIndices(
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64] = []
    ) -> [Set<UInt64>] {
        selectMixinIndices(
            rng: MobileCoinDefaultRng(),
            forRealTxOutIndices: realTxOutIndices,
            selectionRange: selectionRange,
            excludedTxOutIndices: excludedTxOutIndices,
            ringSize: McConstants.RING_SIZE)
    }

    func selectMixinIndices(
        forRealTxOutIndices realTxOutIndices: [UInt64],
        selectionRange: PartialRangeUpTo<UInt64>?,
        excludedTxOutIndices: [UInt64],
        ringSize: Int
    ) -> [Set<UInt64>] {
        selectMixinIndices(
            rng: MobileCoinDefaultRng(),
            forRealTxOutIndices: realTxOutIndices,
            selectionRange: selectionRange,
            excludedTxOutIndices: excludedTxOutIndices,
            ringSize: McConstants.RING_SIZE)
    }
}
