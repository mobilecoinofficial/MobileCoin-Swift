//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import Foundation
import LibMobileCoin

enum FogViewUtils {
    static func encryptTxOutRecord(
        txOutRecord: FogView_TxOutRecord,
        publicAddress: PublicAddress,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> Result<Data, InvalidInputError> {
        let plaintext: Data
        do {
            plaintext = try txOutRecord.serializedData()
        } catch {
            // Safety: Protobuf binary serialization is no fail when not using proto2 or `Any`.
            logger.fatalError("Protobuf serialization failed: \(redacting: error)")
        }
        return VersionedCryptoBox.encrypt(
            plaintext: plaintext,
            publicKey: publicAddress.viewPublicKeyTyped,
            rng: rng,
            rngContext: rngContext)
    }

    static func decryptTxOutRecord(
        ciphertext: Data,
        accountKey: AccountKey
    ) -> Result<FogView_TxOutRecord, VersionedCryptoBoxError> {
        VersionedCryptoBox.decrypt(
            ciphertext: ciphertext,
            privateKey: accountKey.subaddressViewPrivateKey
        ).flatMap { decrypted in
            guard let txOutRecord = try? FogView_TxOutRecord(serializedData: decrypted) else {
                let errorMessage = "FogView_TxOutRecord deserialization failed. serializedData: " +
                    "\(redacting: decrypted.base64EncodedString())"
                logger.warning(errorMessage)
                return .failure(.invalidInput(errorMessage))
            }
            return .success(txOutRecord)
        }
    }
}
