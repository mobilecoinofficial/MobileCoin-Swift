//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct PartialTxOut: TxOutProtocol {
    let encryptedMemo: Data66
    let commitment: Data32
    let maskedAmount: MaskedAmount
    let targetKey: RistrettoPublic
    let publicKey: RistrettoPublic
}

extension PartialTxOut: Equatable {}
extension PartialTxOut: Hashable {}

extension PartialTxOut {
    init(_ txOut: TxOut) {
        self.init(
            encryptedMemo: txOut.encryptedMemo,
            commitment: txOut.commitment,
            maskedAmount: txOut.maskedAmount,
            targetKey: txOut.targetKey,
            publicKey: txOut.publicKey)
    }
}

extension PartialTxOut {
    init?(_ txOut: External_TxOut) {

        var commitment: Data32
        var maskedAmount: MaskedAmount
        switch txOut.maskedAmount {
        case .maskedAmountV1(let m):
            maskedAmount = MaskedAmount(m.maskedValue, maskedTokenId: m.maskedTokenID, version: V1)
            guard let commitmentV1 = Data32(txOut.maskedAmountV1.commitment.data) else {
                return nil
            }
            commitment = commitmentV1
        case .maskedAmountV2(let m):
            maskedAmount = MaskedAmount(m.maskedValue, maskedTokenId: m.maskedTokenID, version: V2)
            guard let commitmentV2 = Data32(txOut.maskedAmountV2.commitment.data) else {
                return nil
            }
            commitment = commitmentV2
        case .none:
            return nil
        }

        guard
            let targetKey = RistrettoPublic(txOut.targetKey.data),
            let publicKey = RistrettoPublic(txOut.publicKey.data),
            [0, 4, 8].contains(maskedAmount.maskedTokenId.count)
        else {
            return nil
        }

        self.init(
            encryptedMemo: txOut.encryptedMemo,
            commitment: commitment,
            maskedAmount: maskedAmount,
            targetKey: targetKey,
            publicKey: publicKey)
    }

    init?(_ txOutRecord: FogView_TxOutRecord, viewKey: RistrettoPrivate) {
        var maskedAmount: MaskedAmount
        switch txOutRecord.txOutAmountMaskedTokenID {
        case .txOutAmountMaskedV1TokenID(let tokenData):
            maskedAmount = MaskedAmount(
                txOutRecord.txOutAmountMaskedValue,
                maskedTokenId: tokenData,
                version: V1)
        case .txOutAmountMaskedV2TokenID(let tokenData):
            maskedAmount = MaskedAmount(
                txOutRecord.txOutAmountMaskedValue,
                maskedTokenId: tokenData,
                version: V2)
        case .none:
            maskedAmount = MaskedAmount(
                txOutRecord.txOutAmountMaskedValue,
                maskedTokenId: McConstants.LEGACY_MOB_MASKED_TOKEN_ID,
                version: V1)
        }

        guard
            let targetKey = RistrettoPublic(txOutRecord.txOutTargetKeyData),
            let publicKey = RistrettoPublic(txOutRecord.txOutPublicKeyData),
            [0, 4, 8].contains(maskedAmount.maskedTokenId.count),
            let commitment = TxOutUtils.reconstructCommitment(
                maskedAmount: maskedAmount,
                publicKey: publicKey,
                viewPrivateKey: viewKey),
            Self.isCrc32Matching(commitment, txOutRecord: txOutRecord)
        else {
            return nil
        }

        self.init(
            encryptedMemo: txOutRecord.encryptedMemo,
            commitment: commitment,
            maskedAmount: maskedAmount,
            targetKey: targetKey,
            publicKey: publicKey)
    }

    static func isCrc32Matching(_ reconstructed: Data32, txOutRecord: FogView_TxOutRecord) -> Bool {
        let reconstructedCrc32 = reconstructed.commitmentCrc32
        let txIsSentWithCrc32 = (txOutRecord.txOutAmountCommitmentDataCrc32 != .emptyCrc32)

        // Older code may not set the crc32 value for the tx record,
        // so it must be calculated off the data of the record itself
        // until that code is deprecated.
        //
        // once it is required that crc32 be set, remove the 'else' below
        // and add a guard check for the
        if txIsSentWithCrc32 {
            return reconstructedCrc32 == txOutRecord.txOutAmountCommitmentDataCrc32
        } else {
            return reconstructedCrc32 == txOutRecord.txOutAmountCommitmentData.commitmentCrc32
        }
    }
}
