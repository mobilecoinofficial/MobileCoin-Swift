//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct TxOut: TxOutProtocol {
    fileprivate let proto: External_TxOut

    let commitment: Data32
    let targetKey: RistrettoPublic
    let publicKey: RistrettoPublic

    /// - Returns: `nil` when the input is not deserializable.
    init?(serializedData: Data) {
        guard let proto = try? External_TxOut(serializedData: serializedData) else {
            logger.warning(
                "External_TxOut deserialization failed. serializedData: " +
                    "\(redacting: serializedData.base64EncodedString())",
                logFunction: false)
            return nil
        }
        self.init(proto)
    }

    var serializedData: Data {
        proto.serializedDataInfallible
    }

    var maskedValue: UInt64 { proto.amount.maskedValue }
    var encryptedFogHint: Data { proto.eFogHint.data }
}

extension TxOut: Equatable {}
extension TxOut: Hashable {}

extension TxOut {
    init?(_ proto: External_TxOut) {
        guard let commitment = Data32(proto.amount.commitment.data),
              let targetKey = RistrettoPublic(proto.targetKey.data),
              let publicKey = RistrettoPublic(proto.publicKey.data)
        else {
            return nil
        }
        self.proto = proto
        self.commitment = commitment
        self.targetKey = targetKey
        self.publicKey = publicKey
    }
}

extension External_TxOut {
    init(_ txOut: TxOut) {
        self = txOut.proto
    }
}
