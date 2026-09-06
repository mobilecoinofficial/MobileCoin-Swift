//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
import LibMobileCoinHTTP
#endif
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

    // The roots are kept, so a success here names a root this mock can answer
    // for, and a test can read which root arrived.
    public private(set) var consensusTrustRoots: SecSSLCertificates?
    public private(set) var fogTrustRoots: SecSSLCertificates?

    @discardableResult
    public func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?)
        -> Result<(), InvalidInputError>
    {
        consensusTrustRoots = trustRoots
        return .success(())
    }

    @discardableResult
    public func setFogTrustRoots(_ trustRoots: SecSSLCertificates?)
        -> Result<(), InvalidInputError>
    {
        fogTrustRoots = trustRoots
        return .success(())
    }
}
