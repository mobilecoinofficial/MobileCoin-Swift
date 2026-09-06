//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

extension SecCertificate {
    public func asPublicKey() -> Result<SecKey, SecurityError> {
        Self.publicKey(for: self)
    }

    public static func publicKey(for certificate: SecCertificate) -> Result<SecKey, SecurityError> {
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

    public var data: Data {
        SecCertificateCopyData(self) as Data
    }
}

extension Data {
    public func asSecCertificate() -> Result<SecCertificate, InvalidInputError> {
        Self.secCertificate(for: self)
    }

    public static func secCertificate(for data: Data) -> Result<SecCertificate, InvalidInputError> {
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

    public static func pinnedCertificateKeys(for data: [Data]) -> Result<[SecKey], Error> {
        do {
            let keys = try data.map { bytes in
                try bytes.asSecCertificate().get()
            }
            .compactMap { cert in
                try SecCertificate.publicKey(for: cert).get()
            }
            return .success(keys)
        } catch {
            return .failure(error)
        }
    }
}

extension SecTrust {
    private typealias ChainOfTrustKeyMatch = (match: Bool, index: Int, key: SecKey)
    private typealias ChainOfTrustKey = (index: Int, key: SecKey)

    public var certificateCount: Int {
        certificateTrustChain.count
    }

    public var certificateTrustChain: [SecCertificate] {
        if #available(iOS 15.0, macOS 12.0, *) {
            return SecTrustCopyCertificateChain(self) as? [SecCertificate] ?? []
        }
        return [Int](0..<SecTrustGetCertificateCount(self)).compactMap {
            SecTrustGetCertificateAtIndex(self, $0)
        }
    }

    public var publicKeyTrustChain: Result<[SecKey], Error> {
        do {
            let keys = try certificateTrustChain.map {
                try $0.asPublicKey().get()
            }
            return .success(keys)
        } catch {
            return .failure(error)
        }
    }

    /// Shared implementation of cert-pinning validation for HTTP and GRPC requesters.
    ///
    /// The `self` SecTrust object is the "server trust" certificate chain
    /// The `pinnedKeys` are `[SecKey]`s we get from the pinned certificates stored on the client
    func validateAgainst(
        pinnedKeys: [SecKey],
        completion: (Result<String, SSLTrustError>) -> Void
    ) {
        let matches: [ChainOfTrustKey]
        let serverTrust = self

        // Pinning narrows which system-trusted chains are acceptable. The system
        // error description quotes the server's own certificate, so the code
        // stands in for it and the line stays free of server text.
        var trustError: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &trustError) else {
            let code = trustError.map { "\(CFErrorGetCode($0))" } ?? "unknown"
            completion(.failure(SSLTrustError(
                Self.systemEvaluationFailure + code)))
            return
        }

        guard let trustChain = try? serverTrust.publicKeyTrustChain.get() else {
            completion(.failure(SSLTrustError(Self.unreadablePublicKey)))
            return
        }

        let trustChainEnumerated = trustChain.enumerated()
        matches = trustChainEnumerated
            .map { chain -> ChainOfTrustKeyMatch in
                let serverCertificateKey = chain.element
                let match = pinnedKeys.contains(serverCertificateKey)
                return (match: match, index: chain.offset, key: serverCertificateKey)
            }
            .filter { $0.match }
            .map { (index: $0.index, key: $0.key) }

        switch matches.isNotEmpty {
        case true:
            // The index says which certificate matched. The key itself is
            // material and stays out of the log.
            let indexes = matches.map { "\($0.index)" }
            let message = Self.pinnedKeyMatched + "[\(indexes.joined(separator: ", "))]"
            completion(.success(message))
        case false:
            /// Failing here means that the public key of the server does not match the stored one.
            /// This can either indicate a MITM attack, or that the backend certificate and the
            /// private key changed, most likely due to expiration.
            completion(.failure(SSLTrustError(Self.noPinnedKeyMatched)))
        }
    }

    // Named so a test can assert which refusal it read, rather than only that
    // the check refused.
    static let systemEvaluationFailure =
        "Failure: the server's chain of trust failed system evaluation, code "
    static let unreadablePublicKey =
        "Failure: the server's chain of trust holds a certificate with no readable public key"
    static let noPinnedKeyMatched =
        "Failure: no pinned certificate matched in the server's chain of trust"
    static let pinnedKeyMatched =
        "Success: pinned certificates matched with the server's chain of trust at index(es): "
}

extension SecKey {
    var data: Data? {
        SecKeyCopyExternalRepresentation(self, nil) as Data?
    }

}
