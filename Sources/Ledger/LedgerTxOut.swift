//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

struct LedgerTxOut: TxOutProtocol {
    private let txOut: PartialTxOut
    let globalIndex: UInt64
    let block: BlockMetadata

    init(_ txOut: PartialTxOut, globalIndex: UInt64, block: BlockMetadata) {
        self.txOut = txOut
        self.globalIndex = globalIndex
        self.block = block
    }

    var commitment: Data32 { txOut.commitment }
    
    /*
     public static RistrettoPublic getSharedSecret(
         @NonNull RistrettoPrivate viewPrivateKey,
         @NonNull RistrettoPublic txOutPublicKey
     ) throws TransactionBuilderException {
       Logger.i(TAG, "Retrieving shared secret", null, "txOut public:", txOutPublicKey);
       try {
         long rustObj = get_shared_secret(viewPrivateKey, txOutPublicKey);
         return RistrettoPublic.fromJNI(rustObj);
       } catch(Exception ex) {
         throw new TransactionBuilderException(ex.getLocalizedMessage(), ex);
       }
     }
     */
    var maskedValue: UInt64 { txOut.maskedValue }
    var targetKey: RistrettoPublic { txOut.targetKey }
    var publicKey: RistrettoPublic { txOut.publicKey }

    func decrypt(accountKey: AccountKey) -> KnownTxOut? {
        KnownTxOut(self, accountKey: accountKey)
    }
}

extension LedgerTxOut: Equatable {}
extension LedgerTxOut: Hashable {}

extension LedgerTxOut {
    init?(_ txOutRecord: FogView_TxOutRecord, viewKey: RistrettoPrivate) {
        guard let partialTxOut = PartialTxOut(txOutRecord, viewKey: viewKey) else {
            return nil
        }
        let globalIndex = txOutRecord.txOutGlobalIndex
        let block = BlockMetadata(
            index: txOutRecord.blockIndex,
            timestamp: txOutRecord.timestampDate)
        self.init(partialTxOut, globalIndex: globalIndex, block: block)
    }
}
