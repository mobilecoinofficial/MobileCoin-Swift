# Create an account key

### User experience

In order for new users to create a MobileCoin wallet on their smartphone, they must add an [**account key**](../glossary.md) by importing an account or adding a QR Code using their device's photo library.

![Importing an account](../images/import-account.jpeg)

![Scanning a QR code](../images/scan-qr-code.jpeg)

### Implementation

As an iOS/SWIFT developer, you need the following code to enable the user to create/import the account key:

```swift
let rootEntropy = Data(/* bytes */)
let account = try Account(
rootEntropy: rootEntropy,
fogUrl: fogUrl)
```
