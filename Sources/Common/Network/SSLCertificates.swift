//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public protocol SSLCertificates {
    var trustRootsBytes: [Data] { get }

    init?(trustRootBytes: [Data]) throws
}

extension SSLCertificates {
    /// Parses `trustRootBytes` into the conforming certificate type. Answers with a
    /// failure when an element of `trustRootBytes` won't parse as a certificate. An
    /// empty `trustRootBytes` answers with a success.
    public static func make(trustRootBytes: [Data]) -> Result<Self, InvalidInputError> {
        do {
            let certificate = try Self(trustRootBytes: trustRootBytes)
            if let certificate = certificate {
                return .success(certificate)
            } else {
                return .failure(InvalidInputError("The trust root bytes carry no certificate"))
            }
        } catch {
            switch error {
            case let error as InvalidInputError:
                return .failure(error)
            default:
                return .failure(InvalidInputError("The trust root bytes carry no certificate"))
            }
        }
    }
}
