//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class EmptyNIOSSLCertificateValidator : NIOSSLCertificateValidator {
    func validate(_ possibleCertificateData: [Data]) -> Result<PossibleNIOSSLCertificate, InvalidInputError> {
        return .failure(InvalidInputError("NIOSSLCertificates not supported with HTTP"))
    }
}
