//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct PartialTxOut: TxOutProtocol {
    let encryptedMemo: Data66
    let commitment: Data32
    let maskedValue: UInt64
    let maskedTokenId: Data
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
            maskedValue: txOut.maskedValue,
            maskedTokenId: txOut.maskedTokenId,
            targetKey: txOut.targetKey,
            publicKey: txOut.publicKey)
    }
}

extension PartialTxOut {
    init?(_ txOut: External_TxOut) {
        guard let commitment = Data32(txOut.maskedAmount.commitment.data),
              let targetKey = RistrettoPublic(txOut.targetKey.data),
              let publicKey = RistrettoPublic(txOut.publicKey.data)
        else {
            return nil
        }
        guard [0,4,8].contains(txOut.maskedAmount.maskedTokenID.count) else {
            return nil
        }
        
        self.init(
            encryptedMemo: txOut.encryptedMemo,
            commitment: commitment,
            maskedValue: txOut.maskedAmount.maskedValue,
            maskedTokenId: txOut.maskedAmount.maskedTokenID,
            targetKey: targetKey,
            publicKey: publicKey)
    }

    init?(_ txOutRecord: FogView_TxOutRecord, viewKey: RistrettoPrivate) {
        guard let targetKey = RistrettoPublic(txOutRecord.txOutTargetKeyData),
              let publicKey = RistrettoPublic(txOutRecord.txOutPublicKeyData),
              let commitment = TxOutUtils.reconstructCommitment(
                                                    maskedValue: txOutRecord.txOutAmountMaskedValue,
                                                    maskedTokenId: txOutRecord.txOutAmountMaskedTokenID,
                                                    publicKey: publicKey,
                                                    viewPrivateKey: viewKey),
              Self.isCrc32Matching(commitment, txOutRecord: txOutRecord)
        else {
            return nil
        }
        guard [0,4,8].contains(txOutRecord.txOutAmountMaskedTokenID.count) else {
            return nil
        }
        
        self.init(
            encryptedMemo: txOutRecord.encryptedMemo,
            commitment: commitment,
            maskedValue: txOutRecord.txOutAmountMaskedValue,
            maskedTokenId: txOutRecord.txOutAmountMaskedTokenID,
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

// TODO find better home
extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    func toUInt64() -> UInt64? {
        switch self.count {
        case 0:
            return 0
        case 4:
            guard let value = self.to(type: UInt32.self) else { return nil }
            return UInt64(value)
        case 8:
            return self.to(type: UInt64.self)
        default:
            return nil
        }
    }
}
