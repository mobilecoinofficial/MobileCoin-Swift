//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct KnownTxOut: TxOutProtocol {
    private let ledgerTxOut: LedgerTxOut
    let value: UInt64
    let keyImage: KeyImage
    let subaddressIndex: UInt64
    let recoverableMemo: RecoverableMemo

    init?(_ ledgerTxOut: LedgerTxOut, accountKey: AccountKey) {
        guard let value = ledgerTxOut.value(accountKey: accountKey),
              let (subaddressIndex, keyImage) = ledgerTxOut.keyImage(accountKey: accountKey),
              let commitment = TxOutUtils.reconstructCommitment(
                                                    maskedValue: ledgerTxOut.maskedValue,
                                                    publicKey: ledgerTxOut.publicKey,
                                                    viewPrivateKey: accountKey.viewPrivateKey)
        else {
            return nil
        }

        self.recoverableMemo = TxOutMemoParser.parse(
                                            encryptedPayload: ledgerTxOut.encryptedMemo,
                                            accountKey: accountKey,
                                            txOutKeys: ledgerTxOut.keys)

        self.commitment = commitment
        self.ledgerTxOut = ledgerTxOut
        self.value = value
        self.keyImage = keyImage
        self.subaddressIndex = subaddressIndex
        
        print("KnownTxOut \(keyImage.data.base64EncodedString()) | index = \(subaddressIndex) | value = \(value)")
    }

    var encryptedMemo: Data66 { ledgerTxOut.encryptedMemo }
    var commitment: Data32
    var maskedValue: UInt64 { ledgerTxOut.maskedValue }
    var targetKey: RistrettoPublic { ledgerTxOut.targetKey }
    var publicKey: RistrettoPublic { ledgerTxOut.publicKey }
    var block: BlockMetadata { ledgerTxOut.block }
    var globalIndex: UInt64 { ledgerTxOut.globalIndex }
}

extension KnownTxOut: Equatable {}
extension KnownTxOut: Hashable {}
