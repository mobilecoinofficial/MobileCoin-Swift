//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
import LibMobileCoin
import LibMobileCoinCommon
import LibMobileCoinHTTP
@testable import MobileCoin
import XCTest

public final class MockFailingHttpRequester: NSObject, HttpRequester {

    override public init() { }

    public func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        completion(.failure(ConnectionError.invalidServerResponse("Mock Http Request set to fail")))
    }

    public func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?) {
    }

    public func setFogTrustRoots(_ trustRoots: SecSSLCertificates?) {
    }
}
