//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
// `SecKey` is a CoreFoundation type with no Sendable conformance. It is only
// read after init here, and Security's own APIs take it across threads.
@preconcurrency import Security

public struct SecSSLCertificates: SSLCertificates, Sendable {
    public let trustRootsBytes: [Data]
    public let publicKeys: [SecKey]

    public init?(trustRootBytes bytes: [Data]) throws {
        switch Self.trustRoots(from: bytes) {
        case .success(let keys):
            self.publicKeys = keys
            self.trustRootsBytes = bytes
        case .failure(let error):
            throw error
        }
    }

    public static func trustRoots(from bytes: [Data]) -> Result<[SecKey], InvalidInputError> {
        Data.pinnedCertificateKeys(for: bytes).mapError {
            let errorMessage = "Error: \($0)"
            logger.error(errorMessage, logFunction: false)
            return InvalidInputError(errorMessage)
        }
    }
}
