//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct ReceiptStatusChecker {
    private let account: ReadWriteDispatchLock<Account>

    init(account: ReadWriteDispatchLock<Account>) {
        self.account = account
    }

    func status(_ receipt: Receipt) -> Result<ReceiptStatus, InvalidInputError> {
        account.readSync { $0.cachedReceivedStatus(of: receipt) }.map { ReceiptStatus($0) }
    }
}
