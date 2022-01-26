//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension Data {
    func asPinnedCertificate() -> Result<SecCertificate, InvalidInputError> {
        Self.pinnedCertificate(for: self)
    }
    
    static func pinnedCertificate(for data: Data) -> Result<SecCertificate, InvalidInputError> {
        let pinnedCertificateData = data as CFData
        if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData) {
            return .success(pinnedCertificate)
        } else {
            let errorMessage = "Error parsing trust root certificate: " +
                "\(data.base64EncodedString())"
            logger.error(errorMessage, logFunction: false)
            return .failure(InvalidInputError(errorMessage))
        }
    }
    
    static func pinnedCertificateKeys(for data: [Data]) -> Result<[SecKey], Error> {
        do {
            let keys = try data.map { bytes in
                try bytes.asPinnedCertificate().get()
            }.compactMap { cert in
                try SecCertificate.publicKey(for: cert).get()
            }
            return .success(keys)
        } catch {
            return .failure(error)
        }
    }
}

extension SecCertificate {
    func asPublicKey() -> Result<SecKey, SecurityError> {
        Self.publicKey(for: self)
    }
    
    static func publicKey(for certificate: SecCertificate) -> Result<SecKey, SecurityError> {
        var publicKey: SecKey?
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        let data = certificate.data

        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        } else {
            let message = "root certificate: \(data.base64EncodedString())"
            let error = SecurityError(trustCreationStatus, message: message)
            return .failure(error)
        }
        
        guard let key = publicKey else {
            let message = ", root certificate: \(data.base64EncodedString())"
            return .failure(SecurityError(nil, message: SecurityError.nilPublicKey + message))
        }
        
        return .success(key)
    }
    
    var data: Data {
        SecCertificateCopyData(self) as Data
    }
}
