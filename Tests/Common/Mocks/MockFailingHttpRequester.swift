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

    public private(set) var consensusTrustRoots: SecSSLCertificates?
    public private(set) var consensusHosts: [String] = []
    public private(set) var fogTrustRoots: SecSSLCertificates?
    public private(set) var fogHosts: [String] = []
    public private(set) var mistyswapTrustRoots: SecSSLCertificates?
    public private(set) var mistyswapHosts: [String] = []

    @discardableResult
    public func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    {
        consensusTrustRoots = trustRoots
        consensusHosts = hosts
        return .success(())
    }

    @discardableResult
    public func setFogTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    {
        fogTrustRoots = trustRoots
        fogHosts = hosts
        return .success(())
    }

    @discardableResult
    public func setMistyswapTrustRoots(_ trustRoots: SecSSLCertificates?, hosts: [String])
        -> Result<(), InvalidInputError>
    {
        mistyswapTrustRoots = trustRoots
        mistyswapHosts = hosts
        return .success(())
    }
}
