//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct TxOut: TxOutProtocol {
    typealias Keys = (publicKey: RistrettoPublic, targetKey: RistrettoPublic)
    
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

        switch TxOut.make(proto) {
        case .success(let txOut):
            self = txOut
        case .failure(let error):
            logger.warning(
                "External_TxOut deserialization failed. serializedData: " +
                    "\(redacting: serializedData.base64EncodedString()), error: \(error)",
                logFunction: false)
            return nil
        }
    }

    var serializedData: Data {
        proto.serializedDataInfallible
    }

    var maskedValue: UInt64 { proto.amount.maskedValue }
    var encryptedFogHint: Data { proto.eFogHint.data }
    var encryptedMemo: Data66 {
        guard proto.hasEMemo else {
            return Data66()
        }
        return Data66(proto.eMemo.data) ?? Data66()
    }
}

extension TxOut: Equatable {}
extension TxOut: Hashable {}

extension TxOut {
    static func make(_ proto: External_TxOut) -> Result<TxOut, InvalidInputError> {
        guard let commitment = Data32(proto.amount.commitment.data) else {
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid commitment format"))
        }
        guard let targetKey = RistrettoPublic(proto.targetKey.data) else {
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid target key format"))
        }
        guard let publicKey = RistrettoPublic(proto.publicKey.data) else {
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid public key format"))
        }
        return .success(
            TxOut(proto: proto, commitment: commitment, targetKey: targetKey, publicKey: publicKey))
    }

    private init(
        proto: External_TxOut,
        commitment: Data32,
        targetKey: RistrettoPublic,
        publicKey: RistrettoPublic
    ) {
        self.proto = proto
        self.commitment = commitment
        self.targetKey = targetKey
        self.publicKey = publicKey
    }
}

extension TxOut {
//    // TODO use result type or optional ?
//    func decryptEMemoPayload(accountKey: AccountKey) -> Data66 {
//        guard proto.hasEMemo else {
//            return Data66()
//        }
//        // TxOutUtils.decryptMemoPayload(proto.eMemo,
//        return Data66()
//    }
}

extension External_TxOut {
    init(_ txOut: TxOut) {
        self = txOut.proto
    }
}

extension External_TxOut {
    var encryptedMemo: Data66 {
        Data66(self.eMemo.data) ?? Data66()
    }
}

extension FogView_TxOutRecord {
    var encryptedMemo: Data66 {
        Data66(self.txOutEMemoData.data) ?? Data66()
    }
}
