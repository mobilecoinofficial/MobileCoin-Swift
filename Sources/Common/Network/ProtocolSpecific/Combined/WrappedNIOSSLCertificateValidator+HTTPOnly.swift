//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// The stand-in for Sources/GRPC/GRPC/WrappedNIOSSLCertificateValidator.swift,
// which declares the same class unconditionally. The guard is what keeps the
// two from colliding if Sources/GRPC is ever compiled alongside this file.
#if !canImport(GRPC) && !canImport(LibMobileCoinGRPC)
class WrappedNIOSSLCertificateValidator: SSLCertificateValidator {
    func validate(_ possibleCertificateData: [Data]) -> Result<SSLCertificates, InvalidInputError> {
        .failure(InvalidInputError("NIOSSLCertificates not supported with HTTP only target"))
    }
}
#endif
