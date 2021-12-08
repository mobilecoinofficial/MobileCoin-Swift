//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class WrappedNIOSSLCertificateValidator : NIOSSLCertificateValidator {
    func validate(_ bytes: [Data]) -> Result<PossibleNIOSSLCertificate, InvalidInputError> {
         WrappedNIOSSLCertificate.make(trustRootBytes: bytes)
    }
}
