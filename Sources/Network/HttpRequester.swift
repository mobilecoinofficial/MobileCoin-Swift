//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

import Foundation
import SwiftProtobuf

public protocol HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void)
    
    func setFogTrustRoots(_ trustRoots: SSLCertificates?)
    func setConsensusTrustRoots(_ trustRoots: SSLCertificates?)
}

extension HttpRequester {
    func setFogTrustRoots(_ trustRoots: SSLCertificates?) {
        logger.debug("setting fog trust roots not implemented")
    }
    func setConsensusTrustRoots(_ trustRoots: SSLCertificates?) {
        logger.debug("setting consensus trust roots not implemented")
    }
}
