//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct PartialTxOut: TxOutProtocol {
    let commitment: Data32
    let maskedValue: UInt64
    let targetKey: RistrettoPublic
    let publicKey: RistrettoPublic
}

extension PartialTxOut: Equatable {}
extension PartialTxOut: Hashable {}

extension PartialTxOut {
    init(_ txOut: TxOut) {
        self.init(
            commitment: txOut.commitment,
            maskedValue: txOut.maskedValue,
            targetKey: txOut.targetKey,
            publicKey: txOut.publicKey)
    }
}

extension PartialTxOut {
    init?(_ txOut: External_TxOut) {
        guard let commitment = Data32(txOut.amount.commitment.data),
              let targetKey = RistrettoPublic(txOut.targetKey.data),
              let publicKey = RistrettoPublic(txOut.publicKey.data)
        else {
            return nil
        }
        self.init(
            commitment: commitment,
            maskedValue: txOut.amount.maskedValue,
            targetKey: targetKey,
            publicKey: publicKey)
    }

    init?(_ txOutRecord: FogView_TxOutRecord, viewKey: RistrettoPrivate) {
        guard let targetKey = RistrettoPublic(txOutRecord.txOutTargetKeyData),
              let publicKey = RistrettoPublic(txOutRecord.txOutPublicKeyData),
              let commitment = TxOutUtils.reconstructCommitment(
                                                    maskedValue: txOutRecord.txOutAmountMaskedValue,
                                                    publicKey: publicKey,
                                                    viewPrivateKey: viewKey),
              Self.isCrc32Matching(commitment, txOutRecord: txOutRecord)
        else {
            return nil
        }

        self.init(
            commitment: commitment,
            maskedValue: txOutRecord.txOutAmountMaskedValue,
            targetKey: targetKey,
            publicKey: publicKey)
    }

    static func isCrc32Matching(_ reconstructed: Data32, txOutRecord: FogView_TxOutRecord) -> Bool {
        let sentCommitment = txOutRecord.txOutAmountCommitmentData
        let sentCrc32 = txOutRecord.txOutAmountCommitmentDataCrc32
        let sentCommitmentCrc32: UInt32 = {
            guard let sentCommitment32 = Data32(sentCommitment) else { return nil }
            return TxOutUtils.calculateCrc32(from: sentCommitment32)
        }() ?? .emptyCrc32

        let reconstructedCrc32 = TxOutUtils.calculateCrc32(from: reconstructed)
        
        return reconstructedCrc32 == sentCrc32 || reconstructedCrc32 == sentCommitmentCrc32
    }
}

extension UInt32 {
    static var emptyCrc32: UInt32 = 0
}
