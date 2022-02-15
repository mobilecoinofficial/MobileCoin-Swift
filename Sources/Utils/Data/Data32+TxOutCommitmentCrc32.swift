//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

extension Data32 {
    var txOutCommitmentCrc32: UInt32? {
        self.asMcBuffer { commitmentPtr in
            var crc32: UInt32 = 0
            switch withMcError({ errorPtr in
                mc_tx_out_commitment_crc32(
                    commitmentPtr,
                    &crc32,
                    &errorPtr)
            }) {
            case .success:
                return crc32
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to mc_tx_out_commitment_crc32 are supplied incorrectly.
                    logger.warning("warning - unable to calculate crc32: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_tx_out_commitment_crc32 should not throw non-documented errors.
                    logger.warning("Unexpected LibMobileCoin error while calculating crc32: \(redacting: error)")
                    return nil
                }
            }
        }
    }
}
