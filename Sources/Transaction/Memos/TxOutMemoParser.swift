//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

enum TxOutMemoParser {
    static func parse(decryptedPayload: Data, accountKey: AccountKey, txOut: TxOutProtocol) -> RecoverableMemo {
        guard let recoverableMemoPayload = Data66(decryptedPayload) else {
            logger.warning("Payload not the correct size for a recoverable memo")
            return .notset
        }
        return RecoverableMemo(decryptedMemo: recoverableMemoPayload, accountKey: accountKey, txOutKeys: txOut.keys)
    }
}
