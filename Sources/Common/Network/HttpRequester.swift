//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import SwiftProtobuf
#if canImport(LibMobileCoin)
import LibMobileCoin
#endif
#if canImport(LibMobileCoinHTTP)
import LibMobileCoinHTTP
#endif

public protocol HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    )

    // Every requester answers for its own trust roots, so a requester that
    // stores none fails to compile against this protocol.
    @discardableResult
    func setFogTrustRoots(_ trustRoots: SecSSLCertificates?) -> Result<(), InvalidInputError>
    @discardableResult
    func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?) -> Result<(), InvalidInputError>
}
