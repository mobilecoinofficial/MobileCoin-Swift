//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public struct TransactionOutput {
    let recipient: PublicAddress
    let amount: Amount
}

extension TransactionOutput: Equatable, Hashable {}

extension TransactionOutput {
    init(_ recipient: PublicAddress, _ amount: Amount) {
        self.recipient = recipient
        self.amount = amount
    }
}

extension TransactionOutput: CustomStringConvertible {
    public var description: String {
        """
        TransactionOutput:
        
        recipient publicAddress base64 \(recipient.serializedData.base64EncodedString())
        amount: \(amount.description)
        """
    }
}
