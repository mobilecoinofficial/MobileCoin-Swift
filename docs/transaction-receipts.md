# Transaction receipts (for recipient)

### User experience

Similar to checking [transaction statuses](check-transaction-status.md), users can check the status of sent payments by looking up their balance history in their app's *Settings*:

![Locate the balance history in the Settings.](images/balance-history.jpeg) ![Users can check their recipients’ sent transaction statuses of impending received payments on their smartphone’s MobileCoin wallet app by looking up their balance history in their Settings.](images/transaction-receipts.jpeg)

### Implementation

As an iOS/SWIFT developer, you will need the following code to enable the user to check their recipients’ transaction statuses:

```SWIFT
let bytes = transactionReceipt
.serializedProtoBytes
/* ------------------------- */
let receipt = TransactionReceipt(
serializedProtoBytes: bytes)
let status = accountOps.status(
account: account,
transactionReceipt: receipt)
```
