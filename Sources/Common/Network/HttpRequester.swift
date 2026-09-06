//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

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
        completion: @escaping (Result<HTTPResponse, Error>) -> Void)
    
    @discardableResult
    func setFogTrustRoots(_ trustRoots: SecSSLCertificates?) -> Result<(), InvalidInputError>
    @discardableResult
    func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?) -> Result<(), InvalidInputError>
}

// A requester that does not store trust roots answers with a failure, so a
// caller cannot read a discarded root as a root that is pinned.
extension HttpRequester {
    public func setFogTrustRoots(_ trustRoots: SecSSLCertificates?)
        -> Result<(), InvalidInputError>
    {
        .failure(InvalidInputError("This HttpRequester does not store fog trust roots"))
    }

    public func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?)
        -> Result<(), InvalidInputError>
    {
        .failure(InvalidInputError("This HttpRequester does not store consensus trust roots"))
    }
}
