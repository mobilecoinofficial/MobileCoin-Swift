//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct PossibleTransaction {
    var outputs: [TransactionOutput]
    var changeAmount: Amount
}

extension PossibleTransaction: Equatable, Hashable { }

extension PossibleTransaction {
    init(_ outputs: [TransactionOutput], _ changeAmount: Amount) {
        self.outputs = outputs
        self.changeAmount = changeAmount
    }
}

extension PossibleTransaction: CustomStringConvertible {
    public var description: String {
        """
        PossibleTransaction:
        
        outputs:
        \(outputs.map({ output in
            output.description
        }).joined(separator: "\n"))
        
        changeAmount: \(changeAmount.description)
        """
    }
}
