//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinHTTP)
import LibMobileCoinCommon
import LibMobileCoinHTTP
#endif

// The pinning delegate is a separate object now, so the session is a `let`
// built in init rather than a racy `lazy var`.
public final class DefaultHttpRequester: NSObject, HttpRequester {
    private let pinningDelegate = CertificatePinningDelegate()
    let session: URLSession

    static let certPinningEnabled = true

    static let defaultConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 40
        config.timeoutIntervalForResource = 40
        return config
    }()

    private static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = .global()
        return queue
    }()

    override public init() {
        session = URLSession(
            configuration: DefaultHttpRequester.defaultConfiguration,
            delegate: pinningDelegate,
            delegateQueue: Self.operationQueue)
        super.init()
    }

    // A URLSession holds its delegate until it is invalidated, so without this
    // every requester that goes out of scope leaves its delegate behind.
    deinit {
        session.finishTasksAndInvalidate()
    }

    public func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        var request = URLRequest(url: url.absoluteURL)
        request.httpMethod = method.rawValue
        headers?.forEach({ key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })

        request.httpBody = body

        let task = session.dataTask(with: request) {data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ConnectionError.invalidServerResponse("No Response")))
                return
            }
            let httpResponse = HTTPResponse(httpUrlResponse: response, responseData: data)
            completion(.success(httpResponse))
        }
        task.resume()
    }

    public func setConsensusTrustRoots(_ trustRoots: SecSSLCertificates?) {
        pinningDelegate.setConsensusTrustRoots(trustRoots)
    }

    public func setFogTrustRoots(_ trustRoots: SecSSLCertificates?) {
        pinningDelegate.setFogTrustRoots(trustRoots)
    }
}

extension DefaultHttpRequester {

    public typealias URLAuthenticationChallengeCompletion = (
        URLSession.AuthChallengeDisposition,
        URLCredential?
    ) -> Void

}

// URLSession calls this back on its own queue while the SDK can be setting
// trust roots from another thread, so both roots sit behind one lock.
final class CertificatePinningDelegate: NSObject {
    private struct TrustRoots {
        var fog: SecSSLCertificates?
        var consensus: SecSSLCertificates?
    }

    private let trustRoots = ReadWriteDispatchLock(TrustRoots())

    private var pinnedKeys: [SecKey] {
        trustRoots.readSync { [$0.fog, $0.consensus] }
            .compactMap { $0?.publicKeys }
            .flatMap { $0 }
    }

    func setFogTrustRoots(_ certificates: SecSSLCertificates?) {
        trustRoots.writeSync { $0.fog = certificates }
    }

    func setConsensusTrustRoots(_ certificates: SecSSLCertificates?) {
        trustRoots.writeSync { $0.consensus = certificates }
    }

    func handle(
        challenge: URLAuthenticationChallenge,
        completionHandler: @escaping DefaultHttpRequester.URLAuthenticationChallengeCompletion
    ) {
        guard
            let trust = challenge.protectionSpace.serverTrust,
            SecTrustGetCertificateCount(trust) > 0
        else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let pinnedKeys = self.pinnedKeys
        guard DefaultHttpRequester.certPinningEnabled && pinnedKeys.isNotEmpty else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        trust.validateAgainst(pinnedKeys: pinnedKeys) { result in
            switch result {
            case .success(let message):
                logger.debug(message)
                completionHandler(.useCredential, URLCredential(trust: trust))
            case .failure(let error):
                logger.error(error.localizedDescription)
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
}

extension CertificatePinningDelegate: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping DefaultHttpRequester.URLAuthenticationChallengeCompletion
    ) {
        handle(challenge: challenge, completionHandler: completionHandler)
    }

}

extension CertificatePinningDelegate: URLSessionTaskDelegate {

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping DefaultHttpRequester.URLAuthenticationChallengeCompletion
    ) {
        handle(challenge: challenge, completionHandler: completionHandler)
    }

}
