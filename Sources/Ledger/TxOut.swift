//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable function_body_length

import Foundation
import LibMobileCoin

struct TxOut: TxOutProtocol {
    typealias Keys = (publicKey: RistrettoPublic, targetKey: RistrettoPublic)

    fileprivate let proto: External_TxOut

    let commitment: Data32
    let targetKey: RistrettoPublic
    let publicKey: RistrettoPublic
    let eMemo: Data66
    public let maskedAmount: MaskedAmount

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

        var commitment: Data32
        var maskedAmount: MaskedAmount
        switch proto.maskedAmount {
        case .maskedAmountV1(let m):
            maskedAmount = MaskedAmount(m.maskedValue, maskedTokenId: m.maskedTokenID, version: V1)
            guard let commitmentV1 = Data32(proto.maskedAmountV1.commitment.data) else {
                return .failure(
                    InvalidInputError("Failed parsing External_TxOut: invalid commitment format"))
            }
            commitment = commitmentV1
        case .maskedAmountV2(let m):
            maskedAmount = MaskedAmount(m.maskedValue, maskedTokenId: m.maskedTokenID, version: V2)
            guard let commitmentV2 = Data32(proto.maskedAmountV2.commitment.data) else {
                return .failure(
                    InvalidInputError("Failed parsing External_TxOut: invalid commitment format"))
            }
            commitment = commitmentV2
        case .none:
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid masked amount version"))
        }

        guard let targetKey = RistrettoPublic(proto.targetKey.data) else {
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid target key format"))
        }
        guard let publicKey = RistrettoPublic(proto.publicKey.data) else {
            return .failure(
                InvalidInputError("Failed parsing External_TxOut: invalid public key format"))
        }
        guard [0, 4, 8].contains(maskedAmount.maskedTokenId.count) else {
            return .failure(
                InvalidInputError("Masked Token ID should be 0, 4, or 8 bytes"))
        }

        var eMemo = Data66()
        if proto.hasEMemo {
            guard let memo = Data66(proto.eMemo.data) else {
                return .failure(
                    InvalidInputError("Failed parsing External_TxOut: invalid e_memo format"))
            }
            eMemo = memo
        }
        return .success(
            TxOut(
                proto: proto,
                commitment: commitment,
                maskedAmount: maskedAmount,
                targetKey: targetKey,
                publicKey: publicKey,
                eMemo: eMemo))
    }

    private init(
        proto: External_TxOut,
        commitment: Data32,
        maskedAmount: MaskedAmount,
        targetKey: RistrettoPublic,
        publicKey: RistrettoPublic,
        eMemo: Data66
    ) {
        self.proto = proto
        self.commitment = commitment
        self.maskedAmount = maskedAmount
        self.targetKey = targetKey
        self.publicKey = publicKey
        self.eMemo = eMemo
    }
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
