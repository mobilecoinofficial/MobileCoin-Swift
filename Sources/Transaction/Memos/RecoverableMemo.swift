//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation


enum RecoveredMemo {
    case sender(SenderMemo)
    case destination(DestinationMemo)
    case senderWithPaymentRequest(SenderWithPaymentRequestMemo)
}

enum RecoverableMemo {
    case unused
    case sender(RecoverableSenderMemo)
    case destination(RecoverableDestinationMemo)
    case senderWithPaymentRequest(RecoverableSenderWithPaymentRequestMemo)
    
    init?(_ data: Data66, accountKey: AccountKey, txOut: TxOutProtocol) {
        guard let memoData = Data64(data[2...]) else {
            return nil
        }
        let typeBytes = data[..<2]
        
        switch typeBytes.hexEncodedString() {
        case Types.SENDER_WITH_PAYMENT_REQUEST:
            let memo = RecoverableSenderWithPaymentRequestMemo(memoData, accountKey: accountKey, txOut: txOut)
            guard let memo = memo else {
                return nil
            }
            self = .senderWithPaymentRequest(memo)
        case Types.SENDER:
            let memo = RecoverableSenderMemo(memoData, accountKey: accountKey, txOut: txOut)
            guard let memo = memo else {
                return nil
            }
            self = .sender(memo)
        case Types.DESTINATION:
            let memo = RecoverableDestinationMemo(memoData, accountKey: accountKey, txOut: txOut)
            guard let memo = memo else {
                return nil
            }
            self = .destination(memo)
        case Types.UNUSED:
            self = .unused
        default:
            return nil
        }
    }
    
    struct Types {
        static let SENDER_WITH_PAYMENT_REQUEST = "0100"
        static let SENDER = "0101"
        static let DESTINATION = "0200"
        static let UNUSED = "0000"
    }
}

