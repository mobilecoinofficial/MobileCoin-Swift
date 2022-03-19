//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol RecoverableMemo {
    var memoData: Data64 { get }
    var addressHash: AddressHash { get }
}

enum RecoveredMemo {
    case sender(SenderMemo)
    case destination(DestinationMemo)
    case senderWithPaymentRequest(SenderWithPaymentRequestMemo)
}

enum RecoverableMemo {
    case unused
    case sender(RecoverableMemoData)
    case destination(RecoverableMemoData)
    case senderWithPaymentRequest(RecoverableMemoData)
    
    init(_ data: Data66) {
        let typeBytes = data[..<2]
        switch typeBytes.hexEncodedString() {
        case Types.SENDER_WITH_PAYMENT_REQUEST:
            self = .senderWithPaymentRequest(<#T##RecoverableMemoData#>)
        }
    }
    
    struct Types {
        static let SENDER_WITH_PAYMENT_REQUEST = "0100"
        static let SENDER = "0101"
        static let DESTINATION = "0200"
        static let UNUSED = "0000"
    }
}

