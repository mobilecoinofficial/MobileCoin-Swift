//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct TxOutMembershipProof {
    let serializedData: Data

    /// - Returns: `nil` when the input is not deserializable.
    init?(serializedData: Data) {
        self.serializedData = serializedData
    }
}

extension TxOutMembershipProof: Equatable {}
extension TxOutMembershipProof: Hashable {}

extension TxOutMembershipProof {
    init?(_ txOutMembershipProof: External_TxOutMembershipProof) {
        let serializedData = txOutMembershipProof.serializedDataInfallible
        self.init(serializedData: serializedData)
    }
}
