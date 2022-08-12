//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import Security

func securityRNG(context: UnsafeMutableRawPointer? = nil) -> UInt64 {
    var value: UInt64 = 0

    let numBytes = MemoryLayout.size(ofValue: value)
    let status = withUnsafeMutablePointer(to: &value) { valuePointer in
        SecRandomCopyBytes(kSecRandomDefault, numBytes, valuePointer)
    }

    guard status == errSecSuccess else {
        var message = ""
        if #available(iOS 11.3, *), let errorMessage = SecCopyErrorMessageString(status, nil) {
            message = ", message: \(errorMessage)"
        }
        // TODO: Handle this failure gracefully
        logger.fatalError("Failed to generate bytes. SecError: \(status)" + message)
    }

    return value
}

func mobileCoinRNG(context: UnsafeMutableRawPointer?) -> UInt64 {
    // get MobileCoinRng sub-class from context    
    guard let context = context else {
        logger.fatalError("Failed to obtain rng from context")
    }

    let rng = Unmanaged<MobileCoinRng>.fromOpaque(context).takeUnretainedValue()
    let val = rng.nextUInt64()

    return val
}
