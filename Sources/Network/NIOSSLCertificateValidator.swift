//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol NIOSSLCertificateValidator {
    func validate(_ certificateData: [Data]) -> Result<PossibleNIOSSLCertificate, InvalidInputError>
}
