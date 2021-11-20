# Create an account key

In order for new users to create a MobileCoin wallet on their smartphone, they must add an **account key** by importing an account or scan a QR Code from their camera’s library.

![Importing an account](images/import-account.jpeg)

![Scanning a QR code](images/scan-qr-code.jpeg)

As an iOS/SWIFT developer, you need the following code to enable the user to create/import the account key:

```SWIFT
let rootEntropy = Data(/* bytes */)
let account = try Account(
rootEntropy: rootEntropy,
fogUrl: fogUrl)
```
