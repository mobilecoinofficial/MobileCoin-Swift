# Get balance

### User experience

In order for users to receive transactions (that is, get their balance), they must be able to deposit funds from a [**request QR Code**](glossary.md).

![Users can get their balance or deposit funds from a transfer QR Code.](images/get-balance.jpeg)

### Implementation

As an iOS/SWIFT developer, you will need the following code to enable the user to get their balance:

```SWIFT
let accountOps = AccountOperations(
fogUrl: fogUrl,
consensusUrl: consensusUrl)
accountOps.updateBalance(
for: account
) {
let balance = try? $0.get()
}
```
