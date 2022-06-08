//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class WrappedNIOSSLCertificateValidator: SSLCertificateValidator {
    func validate(_ bytes: [Data]) -> Result<SSLCertificates, InvalidInputError> {
         WrappedNIOSSLCertificate.make(trustRootBytes: bytes)
    }
}
