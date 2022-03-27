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
    case notset
    case unused
    case sender(RecoverableSenderMemo)
    case destination(RecoverableDestinationMemo)
    case senderWithPaymentRequest(RecoverableSenderWithPaymentRequestMemo)
    
    init(decryptedMemo data: Data66, accountKey: AccountKey, txOutKeys: TxOut.Keys) {
        guard let memoData = Data64(data[2...]) else {
            logger.warning("Memo data type unavailable")
            self = .notset
            return
        }
        let typeBytes = data[..<2]
        
        switch typeBytes.hexEncodedString() {
        case Types.SENDER_WITH_PAYMENT_REQUEST:
            let memo = RecoverableSenderWithPaymentRequestMemo(memoData, accountKey: accountKey, txOutPublicKey: txOutKeys.publicKey)
            self = .senderWithPaymentRequest(memo)
        case Types.SENDER:
            let memo = RecoverableSenderMemo(memoData, accountKey: accountKey, txOutPublicKey: txOutKeys.publicKey)
            self = .sender(memo)
        case Types.DESTINATION:
            let memo = RecoverableDestinationMemo(memoData, accountKey: accountKey, txOutKeys: txOutKeys)
            self = .destination(memo)
        case Types.UNUSED:
            self = .unused
        default:
            logger.warning("Memo data type unknown")
            self = .notset
        }
    }
    
    struct Types {
        static let SENDER = "0100"
        static let SENDER_WITH_PAYMENT_REQUEST = "0101"
        static let DESTINATION = "0200"
        static let UNUSED = "0000"
    }
}

extension RecoverableMemo: Hashable { }

extension RecoverableMemo: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notset, .notset):
            return true
        case (.unused, .unused):
            return true
        case (.sender(let lhsMemo), .sender(let rhsMemo)):
            return lhsMemo == rhsMemo
        case (.destination(let lhsMemo), .destination(let rhsMemo)):
            return lhsMemo == rhsMemo
        case (.senderWithPaymentRequest(let lhsMemo), .senderWithPaymentRequest(let rhsMemo)):
            return lhsMemo == rhsMemo
        default:
            return false
        }
    }
}
