//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class WrappedSSLCertificateValidator: SSLCertificateValidator {
    func validate(_ possibleCertificateData: [Data]) -> Result<PossibleSSLCertificates, InvalidInputError> {
        .failure(InvalidInputError("Standard SSLCertificate validation not supported with GRPC only target"))
    }
}
