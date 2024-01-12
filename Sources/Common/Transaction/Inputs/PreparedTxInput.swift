//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct PreparedTxInput {
    /// - Returns: `.failure` when `knownTxOut` isn't in `ring`.
    static func make(knownTxOut: KnownTxOut, ring: [(TxOut, TxOutMembershipProof)])
        -> Result<PreparedTxInput, InvalidInputError>
    {
        let ring = ring.sorted { $0.0.publicKey.lexicographicallyPrecedes($1.0.publicKey) }

        guard let realInputIndex =
                ring.firstIndex(where: { $0.0.publicKey == knownTxOut.publicKey })
        else {
            let errorMessage = "PreparedTxInput.make: TxOut not found in ring"
            logger.error(errorMessage, logFunction: false)
            return .failure(InvalidInputError(errorMessage))
        }

        return .success(
            PreparedTxInput(knownTxOut: knownTxOut, ring: ring, realInputIndex: realInputIndex))
    }

    let knownTxOut: KnownTxOut
    let ring: [(TxOut, TxOutMembershipProof)]
    let realInputIndex: Int

    var subaddressIndex: UInt64 {
        knownTxOut.subaddressIndex
    }

    private init(knownTxOut: KnownTxOut, ring: [(TxOut, TxOutMembershipProof)], realInputIndex: Int)
    {
        self.knownTxOut = knownTxOut
        self.ring = ring
        self.realInputIndex = realInputIndex
    }
}

extension PreparedTxInput: CustomStringConvertible {
    public var description: String {
        """
        PreparedTxInput:
        
        knownTxOut:
        \(knownTxOut.description)
        
        ring:
        \(ring.map({ (txOut, txOutMembershipProof) in
            """
            txOut serializedData base64:
            \(txOut.serializedData.base64EncodedString())
            
            membershipProof base64:
            \(txOutMembershipProof.serializedData.base64EncodedString())
            """
        }).joined(separator: "\n"))
        """
    }
}
