//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public class MobileCoinSeedableRng: MobileCoinRng {
    let _seed: Data32

    var seed: Data32 {
        _seed
    }

    init(seed: Data32) {
        self._seed = seed
    }

    var wordPos: Data {
        fatalError("Subclass must override wordPos setter")
    }
//        set {
//            fatalError("Subclass must override wordPos setter")
//        }
}
