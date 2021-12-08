//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol NIOSSLCertificateValidator {
    func validate(_ possibleCertificateData: [Data]) -> Result<PossibleNIOSSLCertificate, InvalidInputError>
}
