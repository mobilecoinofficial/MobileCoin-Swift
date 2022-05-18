//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TxOutContext {
    let txOut: TxOut
    let receipt: Receipt
    let sharedSecret: RistrettoPublic
    
    var confirmation: TxOutConfirmationNumber {
        receipt.confirmationNumber
    }
}

extension TxOutContext: Equatable, Hashable {}

extension TxOutContext {
    init(
        _ txOut: TxOut,
        _ receipt: Receipt,
        _ sharedSecret: RistrettoPublic
    ) {
        self.init(txOut: txOut, receipt: receipt, sharedSecret: sharedSecret)
    }
}

/*
 /// Transaction output context is produced by add_output method
 /// Used for receipt creation
 #[allow(dead_code)]
 #[derive(Debug)]
 pub struct TxOutContext {
     /// TxOut that comes from a transaction builder add_output/add_change_output
     pub tx_out: TxOut,
     /// confirmation that comes from a transaction builder add_output/add_change_output
     pub confirmation: TxOutConfirmationNumber,
     /// Shared Secret that comes from a transaction builder add_output/add_change_output
     pub shared_secret: RistrettoPublic
 }


 */
