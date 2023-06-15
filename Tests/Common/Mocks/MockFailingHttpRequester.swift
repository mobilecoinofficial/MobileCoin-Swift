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

public class MockFailingHttpRequester: NSObject, HttpRequester {

    private static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = .global()
        return queue
    }()

    private lazy var session: URLSession = {
       URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: self,
            delegateQueue: Self.operationQueue)
    }()

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

extension MockFailingHttpRequester {
    private typealias ChainOfTrustKeyMatch = (match: Bool, index: Int, key: SecKey)
    private typealias ChainOfTrustKey = (index: Int, key: SecKey)

    public typealias URLAuthenticationChallengeCompletion = (
        URLSession.AuthChallengeDisposition,
        URLCredential?
    ) -> Void

    func urlSession(
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping URLAuthenticationChallengeCompletion
    ) {
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

}

extension MockFailingHttpRequester: URLSessionDelegate {

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping URLAuthenticationChallengeCompletion
    ) {
        urlSession(didReceive: challenge, completionHandler: completionHandler)
    }

}

extension MockFailingHttpRequester: URLSessionTaskDelegate {

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping URLAuthenticationChallengeCompletion
    ) {
        urlSession(didReceive: challenge, completionHandler: completionHandler)
    }

}
