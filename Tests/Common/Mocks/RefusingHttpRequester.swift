//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
import LibMobileCoinHTTP
#endif
import Foundation
@testable import MobileCoin

// A requester that doesn't keep trust roots and says so.
final class RefusingHttpRequester: HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        completion(.failure(ConnectionError.invalidServerResponse("unused")))
    }

    func setFogTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    {
        .failure(InvalidInputError("This requester keeps no fog trust roots"))
    }

    func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    {
        .failure(InvalidInputError("This requester keeps no consensus trust roots"))
    }
}
