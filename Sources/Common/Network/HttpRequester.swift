//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
import LibMobileCoinHTTP
import SwiftProtobuf

public protocol HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    )

    // `hosts` names the endpoints this set of roots pins.
    @discardableResult
    func setFogTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    @discardableResult
    func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
}
