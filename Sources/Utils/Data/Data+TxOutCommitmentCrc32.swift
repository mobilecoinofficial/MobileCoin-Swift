//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Data {
    // this function is only valid in the following case:
    //  - the Data instance is also a valid Data32
    //  - the Data instance represents the data from a TxOutCommitment
    var txOutCommitmentCrc32:UInt32? {
        return Data32(self)?.txOutCommitmentCrc32
    }
}
